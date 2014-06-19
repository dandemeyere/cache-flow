require 'spec_helper.rb'

describe CacheFlow do
  context '#initialize' do
    it "should initialize with the frequency" do
      expect(subject.frequency).to eql 'daily'
    end
  end

  context '#generate_expiry' do
    it "should return seconds" do
      expect(subject.generate_expiry.class).to eql Fixnum
    end

    it "should return seconds in the future" do
      expect(subject.generate_expiry).to be > 0
    end
  end
end
