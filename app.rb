require "sinatra"
require "sinatra/reloader"
require "http"
require "json"

# --------------------------------------- #

get("/") do
  redirect(:umbrella)
end

# --------------------------------------- #

get("/umbrella") do
  erb(:umbrella)
end

# --------------------------------------- #

post("/process_umbrella") do
  @user_location = params.fetch("user_location")

  url_encoded_string = @user_location.gsub(" ", "+")

  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{url_encoded_string}&key=#{ENV["GMAPS_KEY"]}"

  @raw_response_gmaps = HTTP.get(gmaps_url).to_s

  @parsed_response_gmaps = JSON.parse(@raw_response)

  @lat = @parsed_response_gmaps["results"][0]["geometry"]["location"]["lat"]

  @lng = @parsed_response_gmaps["results"][0]["geometry"]["location"]["lng"]

  pirate_url = "https://api.pirateweather.net/forecast/#{ENV["PIRATE_WEATHER_KEY"]}/#{@lat},#{@lng}"

  @raw_response_pirate = HTTP.get(pirate_url).to_s

  @parsed_response_pirate = JSON.parse(@raw_response_pirate)

  erb(:umbrella_results)
end

# --------------------------------------- #
