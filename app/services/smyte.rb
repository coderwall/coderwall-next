class Smyte
  def spam?(action, data, request, session)
    # TODO: this is duped in controllers
    remote_ip = (request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip).split(",").first

    data = {
      name: action,
      timestamp: Time.now.iso8601,
      data: data,
      session: session,
      http_request: {
        headers: request.headers,
        network: {
          remote_address: remote_ip,
        }
      }
    }.to_json

    resp = Excon.post('https://api.smyte.com/v2/action/classify',
      user: '3b3a4db2',
      password: '8347a1e07f914ab2202455014e356aed',
      headers: {
        'Content-Type' => 'application/json'
      },
      body: data
    )
  end
end
