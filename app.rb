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
  #location
  @user_location = params.fetch("user_location")
  url_encoded_string = @user_location.gsub(" ", "+")

  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{url_encoded_string}&key=#{ENV["GMAPS_KEY"]}"
  @raw_response_gmaps = HTTP.get(gmaps_url).to_s
  @parsed_response_gmaps = JSON.parse(@raw_response_gmaps)

  @lat = @parsed_response_gmaps["results"][0]["geometry"]["location"]["lat"]
  @lng = @parsed_response_gmaps["results"][0]["geometry"]["location"]["lng"]

  # weather
  pirate_key = (ENV.fetch("PIRATE_WEATHER_KEY"))
  pirate_key = pirate_key.gsub(/\s+/, "")
  @pirate_url = "https://api.pirateweather.net/forecast/#{pirate_key}/48.856614,2.3522219"
  @raw_response_pirate = HTTP.get(@pirate_url)
  @parsed_response_pirate = JSON.parse(@raw_response_pirate)

  @current_temp = @parsed_response_pirate["currently"]["temperature"]
  @current_summary = @parsed_response_pirate["currently"]["summary"]

  #umbrella
  request_headers_hash = {
    "Authorization" => "Bearer #{ENV.fetch("SINATRA_OPENAI_KEY")}",
    "content-type" => "application/json",
  }

  request_body_hash = {
    "model" => "gpt-3.5-turbo",
    "messages" => [
      {
        "role" => "system",
        "content" => "You are a helpful weather assistant.",
      },
      {
        "role" => "user",
        "content" => "Will I need an umbrella currently for #{@user_location}?",
      },
    ],
  }

  request_body_json = JSON.generate(request_body_hash)

  raw_response = HTTP.headers(request_headers_hash).post(
    "https://api.openai.com/v1/chat/completions",
    :body => request_body_json,
  ).to_s

  @parsed_response_umbrella = JSON.parse(raw_response)

  @umbrella = @parsed_response_umbrella["choices"][0]["message"]["content"]

  erb(:umbrella_results)
end

# --------------------------------------- #
