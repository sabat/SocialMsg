require 'social_msg/version'
require 'social_msg/object'
require 'ostruct'
require 'bitly'

class SocialMsg
  MAX_LENGTH = 140
  REQUIRED_METHODS = [ :name, :title, :link_url ]
  OBJECT_ATTRS = %w{ hashtag_words bitly_auth msg_length name title link_url }

  attr_reader :item, :title

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
    @item = item.kind_of?(Hash) ? OpenStruct.new(item) : item
    raise ArgumentError, "Argument must have: #{REQUIRED_METHODS.join(', ')}, got: #{item.inspect}" if not valid?
  end

  def clone
    Marshal.load Marshal.dump(self)
  end

  def to_s
    name_out = self.name.present? ? "#{self.name}:" : ''
    [ name_out, self.title, self.link_url ].select { |str| str.present? }.join(' ')
  end

  alias :string :to_s

  def empty?
    self.to_s.empty?
  end

  def hashtag!(words=nil)
    words ||= SocialMsg.hashtag_words

    if words.kind_of?(Array)
      words.each do |word|
        self.title.sub!(/(\b)(#{word})(\b)/i, '\1#\2\3') unless self.title.match(/\##{word}/i)
      end
    end
    self
  end

  def short_url!(opts={})
    SocialMsg.bitly_auth = opts[:bitly_auth] if opts[:bitly_auth]
    if valid_bitly_auth?
      begin
        Bitly.use_api_version_3
        @link_url = bitly.shorten(self.link_url).short_url
      rescue BitlyError, ArgumentError => e
        warn "WARNING: could not shorten link URL #{self.link_url}: #{e}"
      end
    end

    self
  end

  def trimmed_title!(len=nil)
    max_length = len || SocialMsg.max_length
    size = self.to_s.size
    ellipses = '..'

    if size > max_length
      subtract = size - max_length + ellipses.size + 1
      @title = @title[0..(@title.size - subtract)] + ellipses
    end

    self
  end

  def shorten!
    self.hashtag!.short_url!.trimmed_title!
  end

  def reset!
    OBJECT_ATTRS.each { |a| self.instance_variable_set("@#{a}".to_sym, nil) }
    self
  end

  def name=(v)
    @name = v
  end

  def name
    @name ||= @item.name.clone
  end

  def title=(v)
    @title = v
  end

  def title
    @title ||= @item.title.clone
  end

  def link_url=(v)
    @link_url = v
  end

  def link_url
    @link_url ||= @item.link_url.clone
  end

  def valid?
    @item && has_required_methods && required_methods_return_str
  end

  def ==(obj)
    self.to_s == obj.to_s
  end

  def bitly_auth=(b)
    SocialMsg.bitly_auth = b
  end

  def bitly_auth
    SocialMsg.bitly_auth
  end

  private

  def has_required_methods
    REQUIRED_METHODS.all? { |meth| @item.respond_to? meth }
  end

  def required_methods_return_str
    REQUIRED_METHODS.all? { |meth| @item.send(meth).kind_of? String }
  end

  def bitly
    @bitly ||= Bitly.new(bitly_auth[0], bitly_auth[1])
  end

  def self.valid_bitly_auth?
    bitly_auth.kind_of?(Array) && bitly_auth.size == 2
  end

  def valid_bitly_auth?
    SocialMsg.valid_bitly_auth?
  end
end

