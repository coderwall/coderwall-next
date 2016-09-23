Sponsor = Struct.new(:id, :title, :cta, :text, :click_url, :image_url, :pixel_url) do
  HOST = "srv.buysellads.com"
  PATH = "/ads/#{ENV['BSA_IDENTIFIER']}.json"

  class << self
    def ads_for(ip)
      return [] unless ENV['BSA_IDENTIFIER'].present?
      params = { ip: ip }
      params.merge!( testMode: true, ignore: true ) if Rails.env.development?
      uri      = URI::HTTPS.build(host: HOST, path: PATH, query: params.to_query)
      response = Faraday.get(uri)
      results  = JSON.parse(response.body)
      results['ads'].collect{ |data| build_sponsor(data) }
    end

    def build_sponsor(data)
      Sponsor.new(
        data['creativeid'],
        data['title'],
        data['callToAction'],
        data['description'],
        data['statlink'],
        data['image'],
        data['pixel']
      )
    end
  end
end
