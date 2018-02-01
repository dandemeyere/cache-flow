require 'spec_helper.rb'

describe CacheFlow do
  context '#initialize' do
    it "should initialize with the frequency" do
      expect(subject.frequency).to eql 'daily'
    end

    it "should have the correct default options set" do
      expect(subject.options).to eql({
        time_zone: "Pacific Time (US & Canada)",
        hour_range_start: 1,
        hour_range_end: 4
      })
    end
  end

  context " configuration " do
    it "should be configurable" do
      CacheFlow.configure do |config|
        config.default_options = {
          time_zone: "Eastern Time (US & Canada)",
          hour_range_start: 17,
          hour_range_end: 20
        }
      end

      expect(subject.options).to eql({
        time_zone: "Eastern Time (US & Canada)",
        hour_range_start: 17,
        hour_range_end: 20
      })
    end
  end

  context '#generate_expiry' do
    it "should return seconds" do
      expect(subject.generate_expiry.class).to eql Integer
    end

    it "should return seconds in the future" do
      expect(subject.generate_expiry).to be > 0
    end
  end
end
