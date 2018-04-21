require 'net/http'

class Weather

  WEATHER_ENDPOINT = 'http://api.worldweatheronline.com/free/v2/weather.ashx'
  WEATHER_API_KEY = '86475d1931fd1d75195ef3b94dac3'
  TIMEZONE = '+10:00'
  TIMEZONE_NAME = 'Melbourne'
  DAILY_WEATHER = true

  # Get the forecast for a suburb (and cache it for up to 4 hours)
  def forecast(suburb, state = 'Victoria', country = 'Australia')
    location = "#{suburb}, #{state}, #{country}"
    cache = Caching.new
    weather = cache.retrieve_weather(location)
    return weather if weather

    weather = get_hourly_forecast_data(location)
    cache.store_weather(location, weather)
    weather
  end

  def for_game_day(weather, game_start)

    # TODO: timezone
    game_start = game_start.in_time_zone(TIMEZONE_NAME)

    if game_start >= 4.days.from_now
      dates = weather.keys.delete_if{|k| k == :retrieval_time}.sort
      last_day = dates.last
      last_day_weather = weather[last_day]

      if DAILY_WEATHER
        best_time = '24'
      else
        best_time = '1300' # Best weather forecast is 1pm (middle of day)
      end
      unless last_day_weather[best_time]
        best_time = middle_key(last_day_weather)
      end
      map_weather_to_forecast(last_day_weather[best_time], last_day, best_time, :too_far_ahead)

    elsif game_start < DateTime.current
      return {result: :in_past}

    else
      best_day = game_start.strftime('%Y-%m-%d')
      unless weather[best_day]
        # Rails.logger.warn "Weather: day not valid - #{best_day}"
        # return {}
        best_day = weather.keys.select {|k| k.instance_of? String }.last
      end
      best_day_weather = weather[best_day]

      if DAILY_WEATHER
        best_time = '24'
      else
        best_time = game_start.strftime('%H%M')
        unless best_day_weather[best_time]
          best_time = closest_time(best_day_weather, best_time)
        end
      end
      map_weather_to_forecast(best_day_weather[best_time], best_day, best_time, :forecasted)
    end
  end

  # hourly['2015-04-08']['1000'] gives you the temperatures, visibility, weather code, etc for 10:00am on 8/4/2015
  def get_hourly_forecast_data(locality)
    hourly = {}
    json = for_location(locality)
    json['data']['weather'].each do |day|
      date = day['date']
      hours = {}
      day['hourly'].each do |hour|
        sliced = hour.slice('tempC', 'tempF', 'time', 'visibility', 'weatherCode', 'weatherDesc', 'weatherIconUrl').symbolize_keys
        hours[sliced[:time]] = sliced
      end
      hourly[date] = hours
    end
    hourly[:retrieval_time] = DateTime.current
    hourly
  end

  # locality = in the form "Suburb, State, Country" perhaps
  # Details here: http://www.worldweatheronline.com/api/docs/local-city-town-weather-api.aspx
  def for_location(locality)

    # Build the request
    uri = URI(WEATHER_ENDPOINT)
    params = { q: locality, key: WEATHER_API_KEY, format: 'json', tp: DAILY_WEATHER ? 24 : 3 } # tp=24 means 24-hour interval, or daily summary
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get(uri)
    raise response unless response.is_a?(String) or response.is_a?(Net::HTTPSuccess)
    JSON.parse(response)
  end

private

  def map_weather_to_forecast(time_data, date, time, result)
    forecast = {result: result}
    forecast[:temperature] = time_data[:tempC].to_i
    forecast[:weather_code] = time_data[:weatherCode].to_i
    forecast[:description] = time_data[:weatherDesc][0]['value']
    # TODO: Map to our own internal UI weather icons
    forecast[:icon] = time_data[:weatherIconUrl][0]['value']
    forecast[:icon_class] = map_weather_icons(forecast[:weather_code])
    hour = time.to_i / 100
    forecast[:date] = DateTime.parse("#{date} #{hour}:00 #{TIMEZONE}")
    forecast
  end

  def map_weather_icons(code)
    # See http://www.worldweatheronline.com/feed/wwoConditionCodes.txt
    case code
      #cticon-cloud-snow
      #cticon-cloud-snow-alt
        # 395	Moderate or heavy snow in area with thunder
        # 392	Patchy light snow in area with thunder
        # 368	Light snow showers
        # 371	Moderate or heavy snow showers
        # 338	Heavy snow
        # 335	Patchy heavy snow
        # 332	Moderate snow
        # 329	Patchy moderate snow
        # 326	Light snow
        # 323	Patchy light snow
        # 227	Blowing snow
        # 182	Patchy sleet nearby
        # 179	Patchy snow nearby
      when 179,182,227,323,326,329,332,335,338,371,368,392,295 then 'cticon-cloud-snow'

      #cticon-wind
        # 230	Blizzard
      when 230 then 'cticon-wind'

      #cticon-cloud-lightning
        # 389	Moderate or heavy rain in area with thunder
        # 386	Patchy light rain in area with thunder
        # 200	Thundery outbreaks in nearby
      when 200,386,389 then 'cticon-cloud-lightning'

      #cticon-cloud-rain
        # 377	Moderate or heavy showers of ice pellets
        # 374	Light showers of ice pellets
        # 365	Moderate or heavy sleet showers
        # 362	Light sleet showers
        # 359	Torrential rain shower
        # 356	Moderate or heavy rain shower
        # 350	Ice pellets
        # 320	Moderate or heavy sleet
        # 317	Light sleet
        # 314	Moderate or Heavy freezing rain
        # 308	Heavy rain
        # 305	Heavy rain at times
      when 305,308,314,317,320,350,356,359,362,365,374,377 then 'cticon-cloud-rain'

      #cticon-cloud-drizzle
        # 353	Light rain shower
        # 311	Light freezing rain
        # 302	Moderate rain
        # 284	Heavy freezing drizzle
        # 281	Freezing drizzle
        # 185	Patchy freezing drizzle nearby
      when 185,281,284,302,311,353 then 'cticon-cloud-drizzle'

      #cticon-cloud-rain-sun
        # 299	Moderate rain at times
        # 296	Light rain
        # 293	Patchy light rain
        # 266	Light drizzle
        # 263	Patchy light drizzle
        # 176	Patchy rain nearby
      when 176,263,266,293,296,299 then 'cticon-cloud-rain-sun'

      #cticon-cloud
        # 260	Freezing fog
        # 248	Fog
        # 122	Overcast
        # 119	Cloudy
      when 119,122,248,260 then 'cticon-cloud'

      #cticon-cloud-sun
        # 143	Mist
        # 116	Partly Cloudy
      when 116,143 then 'cticon-cloud-sun'

      #cticon-sun
        # 113	Clear/Sunny
      when 113 then 'cticon-sun'

      else
        Rails.logger.warn "Unknown weather code: #{code}"
        'cticon-cloud-snow'
    end

  end

  def middle_key(hash)
    middle = hash.keys.size / 2 + 1
    middle = (hash.keys.size - 1) if middle >= hash.keys.size
    hash[hash.keys[middle]]
  end

  def closest_time(hash, best_time)
    # NOTE: We assume all hash keys are "hh00" (e.g. "100" for 1am, "1000" for 10am)
    hours = hash.keys.map{|s| s.to_i / 100 }.sort
    size = hours.size
    best_hour = best_time.to_i / 100
    next_smallest_index = 0
    next_largest_index = size - 1
    found = nil

    # Search for next smallest hour
    hours.each_with_index do |hour,i|
      next_smallest_index = i if hour <= best_hour
      found = i if hour == best_hour
    end

    # Search for next largest hour
    hours.reverse.each_with_index do |hour,i|
      next_largest_index = (size - i - 1) if hour >= best_hour
      found = i if hour == best_hour
    end

    # Return the best match as a string "hh00"
    return "#{hours[found]}00" if found
    ((best_hour - hours[next_smallest_index]) < (-best_hour + hours[next_largest_index])) ?
        "#{hours[next_smallest_index]}00" :
        "#{hours[next_largest_index]}00"

  end

  def sample_data

    json = get_weather_for_location('Forbes, NSW, Australia')
    json['data']['current_condition'] # {"cloudcover"=>"88", "FeelsLikeC"=>"8", "FeelsLikeF"=>"47", "humidity"=>"78", "observation_time"=>"10:57 PM", "precipMM"=>"0.1", "pressure"=>"1017", "temp_C"=>"11", "temp_F"=>"52", "visibility"=>"10", "weatherCode"=>"176", "weatherDesc"=>[{"value"=>"Patchy rain nearby"}], "weatherIconUrl"=>[{"value"=>"http://cdn.worldweatheronline.net/images/wsymbols01_png_64/wsymbol_0009_light_rain_showers.png"}], "winddir16Point"=>"WSW", "winddirDegree"=>"239", "windspeedKmph"=>"28", "windspeedMiles"=>"17"}
    json['data']['request'] # [{"query"=>"Forbes, NSW, Australia", "type"=>"City"}]

    # 5 day forecast
    json['data']['weather'][0] # keys => ["astronomy", "date", "hourly", "maxtempC", "maxtempF", "mintempC", "mintempF", "uvIndex"]
          # astronomy - [{"moonrise"=>"08:24 PM", "moonset"=>"09:29 AM", "sunrise"=>"06:24 AM", "sunset"=>"05:55 PM"}]
          # date - "2015-04-08"
          # maxtempC, maxtempF, mintempC, mintempF, unIndex - single value
    json['data']['weather'][0]['hourly'][0] # {"chanceoffog"=>"0", "chanceoffrost"=>"0", "chanceofhightemp"=>"0", "chanceofovercast"=>"99", "chanceofrain"=>"99", "chanceofremdry"=>"0", "chanceofsnow"=>"0", "chanceofsunshine"=>"0", "chanceofthunder"=>"0", "chanceofwindy"=>"0", "cloudcover"=>"100", "DewPointC"=>"9", "DewPointF"=>"48", "FeelsLikeC"=>"9", "FeelsLikeF"=>"49", "HeatIndexC"=>"12", "HeatIndexF"=>"54", "humidity"=>"81", "precipMM"=>"0.3", "pressure"=>"1014", "tempC"=>"12", "tempF"=>"54", "time"=>"100", "visibility"=>"2", "weatherCode"=>"266", "weatherDesc"=>[{"value"=>"Light drizzle"}], "weatherIconUrl"=>[{"value"=>"http://cdn.worldweatheronline.net/images/wsymbols01_png_64/wsymbol_0033_cloudy_with_light_rain_night.png"}], "WindChillC"=>"9", "WindChillF"=>"49", "winddir16Point"=>"W", "winddirDegree"=>"268", "WindGustKmph"=>"38", "WindGustMiles"=>"24", "windspeedKmph"=>"28", "windspeedMiles"=>"18"}

  end

end
