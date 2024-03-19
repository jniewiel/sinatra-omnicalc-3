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
  @location = params.fetch("user_location").to_s

  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=Merchandise%20Mart%20Chicago&key=#{ENV["GMAPS_KEY"]}"

  @raw_response = HTTP.get(gmaps_url).to_s

  @parsed_response = JSON.parse(@raw_response)

  erb(:umbrella_results)
end

# --------------------------------------- #
