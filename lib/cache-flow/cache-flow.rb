class CacheFlow
  attr_accessor :frequency
  attr_reader :options

  def initialize(frequency = "daily", options = {})
    @options = CacheFlow.configuration.default_options.merge(options)
    @frequency = frequency
  end

  def generate_expiry
    # Rails :expires_in accepts seconds from now to expire the key in
    case frequency
    when "daily"
      random_time_in_range(24.hours.from_now)
    end
  end

  def random_time_in_range(day_to_bust)
    time_to_bust = day_to_bust.in_time_zone(options[:time_zone]).beginning_of_day
    range_start = time_to_bust + options[:hour_range_start].hours
    range_end = time_to_bust + options[:hour_range_end].hours
    rand(range_start.to_i..range_end.to_i) - Time.now.to_i
  end
end
