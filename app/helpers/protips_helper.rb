module ProtipsHelper
  def protips_view_breadcrumbs
    @breadcrumbs ||= begin
      breadcrumbs = [["Protips", popular_path]]
      if params[:order_by] == :created_at
        breadcrumbs << ["Fresh", fresh_path]
         if topic_name
           breadcrumbs << [
               t(Category.parent(params[:topic]), scope: :categories),
               fresh_topic_path(topic: Category.parent(params[:topic]))
           ] if Category.parent(params[:topic])
           breadcrumbs << [topic_name, fresh_topic_path(topic:params[:topic])]
         end
      end
      if params[:order_by] == :score
        breadcrumbs << ["Hot", trending_path]
        if topic_name
          breadcrumbs << [
              t(Category.parent(params[:topic]), scope: :categories),
              popular_topic_path(topic: Category.parent(params[:topic]))
          ] if Category.parent(params[:topic])
          breadcrumbs << [topic_name, popular_topic_path(topic:params[:topic])]
        end
      end
      breadcrumbs << ["Page #{params[:page]}", nil] if params[:page].to_i > 1
      breadcrumbs = [] if breadcrumbs.size <= 1
      breadcrumbs
    end
  end

  def first_page?
    params[:page].to_i < 2
  end

  def on_fresh?
    params[:order_by] == :created_at
  end

  def on_trending?
    params[:order_by] == :score
  end

  def protips_heading
    default = params[:topic] ? "#{protips_list_type} protips tagged #{params[:topic]}" : "#{protips_list_type} protips"
    t(params[:topic], scope: :categories, default: default).html_safe
  end

  def topic_short_name
    return nil if params[:topic].blank?
    t(params[:topic], scope: [:categories, :short])
  end

  def protips_list_type
    case params[:order_by].to_sym
      when :created_at  then 'Newest'
      when :score       then 'Trending'
      when :views_count then 'Popular'
    end
  end

  def protips_description
    t(params[:topic], scope: [:categories, :descriptions], default: '') unless on_fresh?
  end

  def protips_popular_topic_path
    if params[:topic]
      popular_topic_path(topic: params[:topic])
    else
      popular_path
    end
  end

  def protips_fresh_topic_path
    if params[:topic]
      fresh_topic_path(topic: params[:topic])
    else
      fresh_path
    end
  end

  def recently_viewed_protips
    if params[:topic]
      Protip.recently_most_viewed.with_any_tagged(topic_tags)
    else
      Protip.recently_most_viewed
    end
  end

  def recently_created_protips
    if params[:topic]
      Protip.recently_created.with_any_tagged(topic_tags)
    else
      Protip.recently_created
    end
  end

  def topic_tags
    tags = Category.children(params[:topic])
    tags.empty? ? [params[:topic]] : tags
  end

  def topic_name
    if params[:topic]
      if Category.parent(params[:topic])
         "tagged #{params[:topic]}"
      else
        t(params[:topic], scope: :categories)
      end
    end
  end

  def hide_on_protip_exploration
    return 'hide' if protips_view_breadcrumbs.present?
  end

  def protip_summary
    tags = @protip.tags
    tags << 'programming' if tags.empty?
    "A protip by #{@protip.user.username} about #{tags.to_sentence}."
  end

  def sort_expiry
    case params[:order_by]
      when :score       then 5.minutes
      when :views_count then 1.hour
      else 15.seconds
    end
  end

  def protip_list_cache_key
    ['v2', 'protips#index', params[:order_by], params[:topic], params[:page], current_user]
  end

end
