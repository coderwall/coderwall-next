Sponsor = Struct.new(:id, :title, :cta, :text, :click_url, :image_url, :pixel_urls) do
  HOST = "srv.buysellads.com"
  PATH = "/ads/#{ENV['BSA_IDENTIFIER']}.json"

  class << self
    def ads_for(ip)
      return [] unless ENV['BSA_IDENTIFIER'].present?
      params = { forwardedip: ip }
      params.merge!( testMode: true, ignore: true ) if Rails.env.development?
      uri      = URI::HTTPS.build(host: HOST, path: PATH, query: params.to_query)

      results = begin
        start = Time.now
        response = Faraday.new(url: uri).get do |req|
          req.options.timeout = 2           # open/read timeout in seconds
          req.options.open_timeout = 1      # connection open timeout in seconds
        end
        logger.info "sponsor=success seconds=#{"%.2f" % (Time.now - start)}"

        JSON.parse(response.body) rescue nil
      rescue Faraday::TimeoutError
        logger.info "sponsor=timeout seconds=#{"%.2f" % (Time.now - start)}"
        nil
      end

      return [] if results.nil?
      results['ads'].select{|a| a['creativeid'] }.collect{ |data| build_sponsor(data) }
    end

    def build_sponsor(data)
      Sponsor.new(
        data['creativeid'],
        data['title'],
        data['callToAction'],
        data['description'],
        data['statlink'],
        data['image'],
        (data['pixel'] || '').split('||')
      )
    end
  end
end
