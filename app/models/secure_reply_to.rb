require 'openssl'

class SecureReplyTo
  attr_reader :object_type, :object_id, :user_id

  def initialize(object_type, object_id, user_id)
    @object_type, @object_id, @user_id = object_type.to_s, object_id, user_id
    @object_type = @object_type.underscore # it gets downcased somewhere in the pipe
    @user_id = @user_id.downcase
    @secret = ENV.fetch('REPLY_SECRET', 'r3ply_secr3t')
  end

  def self.parse(address)
    _, object_type, object_id, signature, user_id = address.split(/[@\+]/)
    address = new(object_type, object_id, user_id)
    raise 'Invalid Signature' if address.signature != signature
    address
  end

  def signature
    digest = OpenSSL::Digest.new('sha1')
    data = [object_id, user_id].join
    OpenSSL::HMAC.hexdigest(digest, @secret, data)
  end

  def find_thread!
    object_type.camelcase.constantize.find(object_id)
  end

  def to_s
    "reply+#{@object_type}+#{@object_id}+#{signature}+#{@user_id}@m.coderwall.com"
  end
end
