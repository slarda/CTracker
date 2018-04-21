require 'dalli'

class Caching

  # Only retrieve the weather if it has been cached for less than 4 hours
  def retrieve_weather(location)
    result = nil
    Rails.cache.dalli.with do |client|
      result = client.get("weather_#{location.split(',').map(&:strip).join('_')}")
    end
    (result and result[:retrieval_time] >= 4.hours.ago) ? result : nil

  rescue Dalli::RingError => re
    Rails.logger.warn re.message
    raise re unless re.message =~ /No server available/
    nil
  end

  def store_weather(location, results)
    Rails.cache.dalli.with do |client|
      client.set("weather_#{location.split(',').map(&:strip).join('_')}", results)
    end

  rescue Dalli::RingError => re
    Rails.logger.warn re.message
    raise re unless re.message =~ /No server available/
  end

end
