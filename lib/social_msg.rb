require 'social_msg/version'

class SocialMsg
  attr_accessor :str

  MAX_LEN = 140
  REQUIRED_METHODS = [ :name, :title, :link_url ]

  def initialize(item)
    @item = item
    raise TypeError, "Argument must have: #{REQUIRED_METHODS.join(', ')}" if not valid?
  end

  def to_s
    self.str ||= socialized_msg
  end

  def hashtag

    self
  end

  def short_url

      Bitly::Url.new(APP_CONFIG[:bitly_username], APP_CONFIG[:bitly_api_key], long_url: url).shorten
    self
  end

  def trimmed_title

    self
  end

  def valid?
    @item && has_required_methods && required_methods_return_str
  end

  private

  def has_required_methods
    REQUIRED_METHODS.all? { |meth| @item.respond_to? meth }
  end

  def required_methods_return_str
    REQUIRED_METHODS.all? { |meth| @item.send(meth).kind_of? String }
  end

  def name
    @name ||= @item.name
  end

  def title
    @title ||= @item.title
  end

  def link_url
    @link_url ||= @item.link_url
  end

  def socialized_msg
    "#{name}: #{title} #{link_url}"
  end

end

