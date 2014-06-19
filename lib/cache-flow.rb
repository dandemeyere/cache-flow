require 'active_support'
require 'active_support/time'

class CacheFlow
  # Put all these constants into a configurable setting hash
  TIME_ZONE = "Pacific Time (US & Canada)"
  # Hour based on 24 hour clock
  HOUR_RANGE_START = 1
  HOUR_RANGE_END = 4
  attr_accessor :frequency

  def initialize(frequency = "daily")
    self.frequency = frequency
  end

  def generate_expiry
    # Rails :expires_in accepts seconds from now to expire the key in
    case frequency
    when "daily"
      random_time_in_range(24.hours.from_now)
    end
  end

  def random_time_in_range(day_to_bust)
    time_to_bust = day_to_bust.in_time_zone(TIME_ZONE).beginning_of_day
    range_start = time_to_bust + HOUR_RANGE_START.hours
    range_end = time_to_bust + HOUR_RANGE_END.hours
    rand(range_start.to_i..range_end.to_i) - Time.now.to_i
  end
end
