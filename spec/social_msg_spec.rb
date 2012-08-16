require 'spec_helper'

describe SocialMsg do
  let(:news_item) { FakeNewsItem.new }
  before          { news_item }

  it "should have a VERSION constant" do
    expect( SocialMsg::VERSION ).to_not be_empty
    expect( SocialMsg::VERSION ).to match(/^[\w\d\.\-\_\/]+$/)
  end

  it "can create a valid new instance if a valid obj is passed to it" do
    expect( SocialMsg.new(news_item) ).to be_valid
  end

  it "does not create a new instance if an invalid obj is passed in" do
    expect { SocialMsg.new(String.new) }.to raise_error(TypeError)
  end

  it "can print its output as a string" do
    expect( SocialMsg.new(news_item).to_s ).to be_kind_of(String)
    
  end

  it "can add hashtags if they are passed in as an array"
  it "does not add hashtags if the arg is invalid"
  it "can shorten the link_url"
  it "can trim the title if the max len is passed in"
  it "can trim the title to a default if the max len is not passed in"
end
