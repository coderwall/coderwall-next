class Smyte
  def spam?(action, data, request)
    # TODO: this is duped in controllers
    remote_ip = (request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip).split(",").first
    headers = request.headers.env.select{|k, _| k.in?(ActionDispatch::Http::Headers::CGI_VARIABLES) || k =~ /^HTTP_/}

    payload = {
      name: action,
      timestamp: Time.now.iso8601,
      data: data,
      session: request.session,
      http_request: {
        headers: headers,
        network: {
          remote_address: remote_ip,
        }
      }
    }.to_json

    resp = Excon.post(ENV.fetch('SMYTE_URL'),
      headers: {
        'Content-Type' => 'application/json'
      },
      body: payload
    )

    Rails.logger.info "[SMYTE] #{resp.body}"
    result = JSON.parse(resp.body) rescue nil
    return false if result.nil? # assume smyte API is down

    result['verdict'] != 'ALLOW'
  end
end
