namespace :marketing do
  def sendgrid_client
    Excon.new(
      'https://api.sendgrid.com',
      headers: {
        "Authorization" => "Bearer #{ENV.fetch('SENDGRID_KEY')}",
        "Content-Type" => "application/json"
      },
    )
  end

  def sendgrid(method, path, body=nil, options={})
    params = { method: method, path: "v3/#{path}" }
    params[:body] = body.to_json if body
    response = sendgrid_client.request(params)
    if options[:check_status] != false && ![200, 201, 204].include?(response.status)
      puts response.body
      puts response.headers
      raise "sendgrid #{path} #{response.status}"
    end

    JSON.parse(response.body) unless response.body.blank?
  end

  def upsert_list(name)
    resp = sendgrid('GET', 'contactdb/lists')
    resp['lists'].find{|l| l['name'] == name } ||
      sendgrid('POST', 'contactdb/lists', { name: name })
  end

  task :sync_lists => :environment do
    list_name = ENV.fetch('MARKETING_LIST')
    list = upsert_list(list_name)

    %w(username full_name).each do |field|
      sendgrid('POST', 'contactdb/custom_fields', { name: field, type: 'text' }, check_status: false)
    end

    # add users to marketing list
    User.where(marketing_list: nil, email_invalid_at: nil, receive_newsletter: true).find_in_batches(batch_size: 1000) do |group|
      entries = group.map do |u|
        {
          email: u.email,
          username: u.username,
          full_name: u.name,
        }
      end

      puts "creating #{entries.size} recipients"
      response = sendgrid('POST', 'contactdb/recipients', entries)
      puts response.slice('new_count', 'updated_count')
      (response['errors'] || []).each do |error|
        puts error['message']
        puts (error['error_indices'] || []).map{|i| puts entries[i] }
        if error['message'] =~ /email.*is invalid/i
          error['error_indices'].map{|i| group[i] }.each do |u|
            u.update! email_invalid_at: Time.now
          end
        end
      end

      recipients = response['persisted_recipients']
      persisted_users = group.select.with_index{ |u, idx|
        !response['error_indices'].include?(idx)
      }.map.with_index{|u, idx| [u, recipients[idx]] }

      puts "adding #{persisted_users.size} recipients to list #{list}"
      persisted_users.each do |user, recipient_id|
        sendgrid('POST', "contactdb/lists/#{list['id']}/recipients/#{recipient_id}", entries)
        user.update!(marketing_list: list['id'])
        puts "  #{user.email}"
      end

      sleep 1 # sendgrid rate limits
    end

    # remove users from marketing list
    User.where.not(marketing_list: nil).where(receive_newsletter: false).find_each do |u|
      response = sendgrid('GET', "contactdb/recipients/search?email=#{u.email}")
      response['recipients'].each do |r|
        sendgrid("DELETE", "contactdb/lists/#{list['id']}/recipients/#{r['id']}")
        u.update!(marketing_list: nil)
        puts "unsubscribed #{r['email']}"
      end
    end
  end
end
