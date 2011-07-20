require 'rubygems'
require 'sinatra'
require 'erb'
require 'json-schema'

get '/' do
  erb :index
end

post '/test' do
  begin
    json = JSON::parse request.body.read
  rescue JSON::ParserError => err
    status 400
    return {"error" => "Invalid JSON"}.to_json
  end

  schema = json["schema"]
  sample = json["sample"]

  begin
    JSON::Validator.validate2(schema, sample)
  rescue JSON::ValidationError => err
  rescue Errno::ENOENT => err
    #If the first argument to validate2 is invalid json, the validator will assume
    #it's a filename, and go try and load it. Since it probably doesn't exist,
    #json-schema will throw an Errno::ENOENT
    err = "Invalid Schema JSON"
  rescue => err
    err = "Unexpected server error:\n #{err.class}: #{err.message}\n #{err.backtrace.join('\n')}"
  end

  if err
    status 400
    {"error" => err}.to_json
  else
    {}.to_json
  end
end
