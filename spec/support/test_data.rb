class FakeNewsItem
  def name
    Faker::Lorem.sentences(2).join(' ')
  end

  def title
    Faker::Lorem.sentences(5).join(' ')
  end

  def link_url 
    Faker::Internet.url
  end
end

