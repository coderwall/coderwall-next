class CloudfrontConstraint
  def matches?(request)
    request.env['HTTP_USER_AGENT'] == 'Amazon CloudFront'
  end
end
