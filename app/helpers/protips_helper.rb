module ProtipsHelper

  def protip_summary
    tags = @protip.tags
    tags << 'programming' if tags.empty?
    "A protip by #{@protip.user.username} about #{tags.to_sentence}."
  end

end
