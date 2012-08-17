class FakeNewsItem
  def name=(v)
    @name = v
  end

  def name
    @name ||= [ 'Sasquatch', Faker::Lorem.words(2) ].join(' ')
  end

  def title=(v)
    @title = v
  end

  def title
    @title ||= [ 'UFO', Faker::Lorem.sentence, 'aliens', Faker::Lorem.sentences(5), 'Bigfoot'].join(' ')
  end

  def link_url=(v)
    @link_url = v
  end

  def link_url 
    @link_url ||= Faker::Internet.url
  end
end

