class CacheFlow
  class Configuration
    attr_accessor :default_options
    # Put all these constants into a configurable setting hash
    # Hour range based on 24 hour clock

    def initialize
      @default_options = {
        time_zone: "Pacific Time (US & Canada)",
        hour_range_start: 1,
        hour_range_end: 4
      }
    end
  end

  class << self
    attr_accessor :configuration
  end

  # Configure CacheFlow in your initializers:
  # example file location: config/initializers/cache_flow.rb
  # example code:
  # CacheFlow.configure do |config|
  #   config.default_options = {
  #     time_zone: "Eastern Time (US & Canada)",
  #     hour_range_start: 17,
  #     hour_range_end: 20
  #   }
  # end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
