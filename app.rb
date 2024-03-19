require "sinatra"
require "sinatra/reloader"
require "http"
require "json"

# --------------------------------------- #

get("/") do
  redirect(:process_umbrella)
end

# --------------------------------------- #

get("/umbrella") do
  erb(:umbrella)
end

# --------------------------------------- #

post("/process_umbrella") do
  @location = params.fetch("user_location").to_s

  require "http"
  require "json"

  request_headers_hash = {
    "Authorization" => "Bearer #{ENV.fetch("SINATRA_OPENAI_KEY")}",
    "content-type" => "application/json",
  }

  request_body_hash = {
    "model" => "gpt-3.5-turbo",
    "messages" => [
      {
        "role" => "system",
        "content" => "You are a helpful assistant who talks like Shakespeare.",
      },
      {
        "role" => "user",
        "content" => "Hello! What are the best spots for pizza in Chicago?",
      },
    ],
  }

  request_body_json = JSON.generate(request_body_hash)

  raw_response = HTTP.headers(request_headers_hash).post(
    "https://api.openai.com/v1/chat/completions",
    :body => request_body_json,
  ).to_s

  @parsed_response = JSON.parse(raw_response)

  erb(:process_umbrella)
end

# --------------------------------------- #
