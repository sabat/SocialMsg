require 'spec_helper'

describe SocialMsg do
  let(:words)       { %w{ UFO bigfoot } }
  let(:bitly_auth)  { { username: 'test', api_key: '02934uhsdfsdkjh23_32jn' } }
  let(:news_item)   { FakeNewsItem.new }
  let(:social_msg)  { SocialMsg.new news_item }
  let(:bitly) do
    b = double('bitly')
    b.stub(:shorten).and_return('http://bit.ly/NGx5IN')
    b
  end

  before do
    news_item
    social_msg
    bitly
  end

  it "has a VERSION constant" do
    expect( SocialMsg::VERSION ).to_not be_empty
    expect( SocialMsg::VERSION ).to match(/^[\w\d\.\-\_\/]+$/)
  end

  context "validation when initializing" do
    it "can create a valid new instance if an obj with expected methods is passed to it" do
      expect( SocialMsg.new(news_item) ).to be_valid
    end
  
    it "does not create a new instance if an invalid obj type is passed in" do
      expect { SocialMsg.new(String.new) }.to raise_error(ArgumentError)
    end
  
    it "can create a new instance if passed a valid hash" do
      expect( 
          SocialMsg.new( name: 'bar', title: 'foo', link_url: 'http://baz.com' )
      ).to be_valid
    end
  
    it "does not create a new instance if passed a hash without expected keys" do
      expect { SocialMsg.new( foo: 'bar' ) }.to raise_error(ArgumentError)
    end

    it "does not create a new instance if passed an obj with nil values" do
      expect {
        SocialMsg.new( name: nil, title: nil, link_url: nil )
      }.to raise_error(ArgumentError)
    end
  end

  context "an instance" do
    it "can change its name" do
      social_msg.name = 'Not the Original Name'
      social_msg.name.should eq('Not the Original Name')
    end
  
    it "can change its title" do
      social_msg.title = 'Not the Original Title'
      social_msg.title.should eq('Not the Original Title')
    end
  
    it "can change its link_url" do
      social_msg.link_url = 'http://not.the.original.com'
      social_msg.link_url.should eq('http://not.the.original.com')
    end
  
    it "can print its output as a string" do
      expect( social_msg.to_s ).to be_kind_of(String)
    end

    it "can reset itself to its original state" do
      SocialMsg.hashtag_words = words
      SocialMsg.bitly_auth = bitly_auth
      Bitly::Url.should_receive(:new).and_return(bitly)
      orig = social_msg.clone

      expect { social_msg.shorten }.to change { social_msg.to_s }
      social_msg.reset!.should eq(orig)
    end

    context "when compared with ==" do
      it "returns true if equal" do
        social_msg2 = social_msg.clone
        social_msg.should eq(social_msg2)
      end
  
      it "returns false if not equal" do
        social_msg2 = social_msg.clone
        social_msg2.title = 'Something Different'
        social_msg.should_not eq(social_msg2)
      end
    end

    it "can do all modifications (hashtag, short URL, shorten text) with one method" do
      SocialMsg.hashtag_words = words
      SocialMsg.bitly_auth = bitly_auth
      Bitly::Url.should_receive(:new).and_return(bitly)
  
      expect { social_msg.shorten }.to change { social_msg.to_s }
      social_msg.to_s.should_not be_empty
      social_msg.to_s.should have_at_most(140).characters
    end

    it "can be cloned as a full deep copy" do
      clone = social_msg.clone
      clone.title = 'Different'
      clone.to_s.should_not eq(social_msg)
    end
  end

  context "doing hashtagging" do
    it "can have hashtag keywords set at the class level" do
      SocialMsg.hashtag_words = words
      SocialMsg.hashtag_words.should eq(words)
    end
  
    it "can add hashtags to the title if keywords are passed in as an array" do
      SocialMsg.hashtag_words = []
      expect( social_msg.hashtag(words).to_s ).to match(/\#Bigfoot/)
    end
  
    it "can add hashtags to the title if keywords are set at the class level" do
      SocialMsg.hashtag_words = words
      expect( social_msg.hashtag.to_s ).to match(/\#Bigfoot/)
    end
  
    it "does not add hashtags if the keywords obj is invalid" do
      SocialMsg.hashtag_words = []
      expect { social_msg.hashtag(900) }.to_not change { social_msg.to_s }
    end
  
    it "does not add a hashtag if a keyword already has one" do
      SocialMsg.hashtag_words = words
      social_msg.title = '#Bigfoot #UFO sightings in the same place!'
      expect { social_msg.hashtag }.to_not change { social_msg.to_s }
    end
  end

  context "using Bitly URL shortening" do
    it "can have Bitly auth set at the class level" do
      SocialMsg.bitly_auth = bitly_auth
      SocialMsg.bitly_auth.should eq(bitly_auth)
    end
  
    it "can shorten the link_url if Bitly args are passed in" do
      Bitly::Url.should_receive(:new).and_return(bitly)
      expect { social_msg.short_url(bitly_auth) }.to change { social_msg.to_s }
    end
  
    it "can shorten the link_url if Bitly args are set at the class level" do
      Bitly::Url.should_receive(:new).and_return(bitly)
      SocialMsg.bitly_auth = bitly_auth
      expect { social_msg.short_url }.to change { social_msg.to_s }
    end
  
    it "will not shorten the URL if it has an empty Bitly auth pair" do
      Bitly::Url.stub(:new).and_return(bitly)
      SocialMsg.bitly_auth = {}
      expect { social_msg.short_url }.to_not change { social_msg.to_s }
    end
  
    it "will not shorten the URL if it has a badly formed Bitly auth pair" do
      Bitly::Url.should_receive(:new).and_raise(ArgumentError)
      SocialMsg.bitly_auth = { username: nil, api_key: '123' }
      expect { social_msg.short_url }.to_not change { social_msg.to_s }
    end
  
    it "will not shorten the URL if it has Bitly auth that bitly.com won't recognize" do
      Bitly::Url.should_receive(:new).and_raise(BitlyError)
      SocialMsg.bitly_auth = { username: 'bogus_user', api_key: '123' }
      expect { social_msg.short_url }.to_not change { social_msg.to_s }
    end
  end

  context "when shortening the text" do
    it "can have the max message length set at the class level" do
      SocialMsg.max_length = 129
      SocialMsg.max_length.should eq(129)
    end
  
    it "can trim the title if the max len is passed in" do
      expect { social_msg.trimmed_title(140) }.to change { social_msg.to_s }
      social_msg.to_s.should_not be_empty
      social_msg.to_s.should have_at_most(140).characters
    end
  
    it "can trim the title if the max len is set at the class level" do
      SocialMsg.max_length = 110
      expect { social_msg.trimmed_title }.to change { social_msg.to_s }
      social_msg.to_s.should_not be_empty
      social_msg.to_s.should have_at_most(110).characters
    end
  
    it "can trim the title to a default if the max len is not set" do
      SocialMsg.max_length = nil
      expect { social_msg.trimmed_title }.to change { social_msg.to_s }
      social_msg.to_s.should_not be_empty
      social_msg.to_s.should have_at_most(140).characters
    end
  
    it "can trim the title after having hashtags and URL shortening" do
      SocialMsg.hashtag_words = words
      SocialMsg.bitly_auth = bitly_auth
      Bitly::Url.should_receive(:new).and_return(bitly)
  
      expect { social_msg.hashtag.short_url.trimmed_title }.to change { social_msg.to_s }
      social_msg.to_s.should_not be_empty
      social_msg.to_s.should have_at_most(140).characters
    end
  end

end

