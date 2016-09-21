Sponsor = Struct.new(:id, :title, :cta, :text, :click_url, :image_url, :pixel_url) do

  class << self
    def ads_for(ip)
      return [] unless ENV['BSA_IDENTIFIER'].present?
      url      = "https://srv.buysellads.com/ads/#{ENV['BSA_IDENTIFIER']}.json"
      response = Faraday.get(url) do |request|
        request.params['testMode'] = true if Rails.env.development?
        request.params['ignore']   = true if Rails.env.development?
        request.params['ip']       = ip
      end
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
