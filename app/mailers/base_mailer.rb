class BaseMailer < ActionMailer::Base
  def prevent_delivery
    mail.perform_deliveries = false
  end

  def list_headers(object_type, object_id, username, thread_parts, message_parts, archive_url)
    reply_address = SecureReplyTo.new(object_type, object_id, username).to_s

    thread_id = thread_parts.join('/')
    thread_address = "<#{thread_id}@assembly.com>"
    message_id = "<#{message_parts.join('/')}@assembly.com>"

    {
      "Reply-To" => "#{thread_parts.join('/')} <#{reply_address}>",

      "Message-ID" => message_id,
      "In-Reply-To" => thread_address,
      "References"  => thread_address,

      "List-ID" => "#{thread_id} <#{thread_parts.join('.')}.assembly.com>",
      "List-Archive" => archive_url,
      "List-Post"  => "<mailto:#{reply_address}>",
      "Precedence" => "list",
    }
  end
end
