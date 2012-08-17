require 'social_msg/version'

class SocialMsg
  MAX_LENGTH = 140
  REQUIRED_METHODS = [ :name, :title, :link_url ]

  def self.hashtag_words=(w)
    @hashtag_words = w if w.kind_of?(Array)
  end

  def self.hashtag_words
    @hashtag_words || []
  end

  def self.bitly_auth=(b)
    @bitly_auth = b
  end

  def self.bitly_auth
    @bitly_auth || {}
  end

  def self.max_length=(s)
    @msg_length = s
  end

  def self.max_length
    @msg_length || MAX_LENGTH
  end

  #

  def initialize(item)
    @item = item
    raise TypeError, "Argument must have: #{REQUIRED_METHODS.join(', ')}" if not valid?
  end

  def to_s
    "#{self.name}: #{self.title} #{self.link_url}"
  end

  def hashtag(words=nil)
    words ||= SocialMsg.hashtag_words

    if words.kind_of?(Array)
      words.each do |word|
        self.title.sub!(/(\b)(#{word})(\b)/i, '\1#\2\3') unless self.title.match(/\##{word}/i)
      end
    end
    self
  end

  def short_url(opts={})
    bitly_auth = opts[:bitly_auth] || SocialMsg.bitly_auth
    if valid_bitly_auth(bitly_auth)
      bitly_username = bitly_auth[:username]
      bitly_api_key = bitly_auth[:api_key]

      begin
        @link_url = Bitly::Url.new(bitly_username, bitly_api_key, long_url: self.link_url).shorten
      rescue BitlyError, ArgumentError => e
        warn "WARNING: could not shorten link URL #{self.link_url}: #{e}"
      end
    end

    self
  end

  def trimmed_title(len=nil)
    max_length = len || SocialMsg.max_length
    size = self.to_s.size
    ellipses = '..'

    if size > max_length
      subtract = size - max_length + ellipses.size + 1
      @title = @title[0..(@title.size - subtract)] + ellipses
    end

    self
  end

  def name=(v)
    @name = v
  end

  def name
    @name ||= @item.name
  end

  def title=(v)
    @title = v
  end

  def title
    @title ||= @item.title
  end

  def link_url=(v)
    @link_url = v
  end

  def link_url
    @link_url ||= @item.link_url
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

  def self.valid_bitly_auth(b)
    b.kind_of?(Hash) && b.has_key?(:username) && b.has_key?(:api_key)
  end

  def valid_bitly_auth(b)
    SocialMsg.valid_bitly_auth b
  end

end

