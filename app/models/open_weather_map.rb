require 'open-uri'
require 'json'

class OpenWeatherMap
  OPEN_WEATHER_MAP_URL = "https://api.openweathermap.org/data/2.5/forecast"  

  def self.fetch_5days_3hours_forecast
    response = URI.open(OPEN_WEATHER_MAP_URL + "?q=Naha,jp&appid=#{ENV.fetch("OPEN_WEATHER_MAP_API_KEY")}")
    JSON.parse(response.read, symbolize_names: true)
  end

  def self.latest_forcasts
    @@latest_forcasts ||= fetch_5days_3hours_forecast[:list].first(10)
  end

  def self.latest_forcasts_message
    message = ""
    latest_forcasts.each do |forcast|
      message = message + forcast[:dt_txt] + " " + forcast[:weather][0][:main] + "\n"
    end
    message
  end
end
