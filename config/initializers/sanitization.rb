Rails.application.config.after_initialize do
  # Allow links to have rel=nofollow to discourage spam
  ActionView::Base.sanitized_allowed_attributes << 'rel'
end
