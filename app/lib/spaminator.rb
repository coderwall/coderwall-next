URLS = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix

class Spaminator
  def bad_links?(text, urls)
    text.scan(/shurll.com|shorl.com/i).size > 1
  end

  def recognized_format?(text)
    text.match(/^\[\!\[Foo\]/)
  end

  def customer_support?(text)
    text.scan(/customer|support|phonenumber|phonesupport/i).size > 10
  end

  def download_links?(text, urls, title)
    title.match(/serial key|free download/i) ||
      text.scan(/download|crack|serial|torrent/i).size > 10
  end

  def many_spaces?(text, urls, title)
    title.scan(/ /).size > 2
  end

  def mostly_url?(text, urls)
    urls.join.size / text.size.to_f > 0.5
  end

  def weird_characters?(text)
    text.scan(/[\.]/).size / text.size.to_f > 0.10
  end

  def protip_flags(protip)
    flags = []
    text = [protip.title, protip.body, protip.tags].flatten.join("\n")
    urls = URI.extract(text).compact

    flags << 'bad_user' if protip.user.bad_user
    flags << 'bad_links' if bad_links?(text, urls)
    flags << 'customer_support' if customer_support?(text)
    flags << 'download_spam' if download_links?(text, urls, protip.title)
    flags << 'recognized_format' if recognized_format?(text)
    flags << 'mostly_url' if mostly_url?(text, urls)
    flags << 'weird_characters' if weird_characters?(text)

    flags
  end

  def user_flags(user)
    flags = []
    text = [user.title, user.username, user.about].flatten.join("\n")
    urls = URI.extract(text).compact

    flags << 'bad_links' if bad_links?(text, urls)
    flags << 'customer_support' if customer_support?(text)
    flags << 'download_spam' if download_links?(text, urls, user.username)
    flags << 'recognized_format' if recognized_format?(text)
    flags << 'many_spaces' if many_spaces?(text, urls, user.username)
    flags << 'mostly_url' if mostly_url?(text, urls)
    flags << 'weird_characters' if weird_characters?(text)

    flags
  end

end

