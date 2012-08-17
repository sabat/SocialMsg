require 'spec_helper'

describe Object do
  context "with a nil object" do
    subject { nil }
    it { should be_blank }
    it { should_not be_present }
  end

  context "with an empty string" do
    subject { '' }
    it { should be_blank }
    it { should_not be_present }
  end

  context "with a non-empty string" do
    subject { 'foo' }
    it { should_not be_blank }
    it { should be_present }
  end
end

