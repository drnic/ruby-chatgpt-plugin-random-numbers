require "sinatra"
require "json"

domain = ENV.fetch("DOMAIN")

get "/.well-known/ai-plugin.json" do
  content_type "application/json"

  file_path = File.join(settings.root, ".well-known", "ai-plugin.json")
  # Load file, replace domain, and send it back
  file = File.read(file_path)
  file.gsub!(/DOMAIN/, domain)
  file
end

get "/.well-known/openapi.yaml" do
  content_type "application/yaml"

  file_path = File.join(settings.root, ".well-known", "openapi.yaml")
  # Load file, replace domain, and send it back
  file = File.read(file_path)
  file.gsub!(/DOMAIN/, domain)
  file
end

# Serve files from the .well-known folder
get "/.well-known/*" do
  filename = params[:splat].first
  file_path = File.join(settings.root, ".well-known", filename)

  if File.exist?(file_path)
    send_file file_path
  else
    status 404
    "File not found #{file_path}"
  end
end

post "/random" do
  content_type :json

  begin
    request_data = JSON.parse(request.body.read)

    # pp request_data
    # pp request.env
    # HTTP_OPENAI_CONVERSATION_ID
    # HTTP_OPENAI_EPHEMERAL_USER_ID
    puts "HTTP_OPENAI_SUBDIVISION_1_ISO_CODE: #{request.env["HTTP_OPENAI_SUBDIVISION_1_ISO_CODE"]}"

    min = request_data["min"] || 0
    max = request_data["max"] || 100

    if min > max
      status 400
      {message: "Invalid range: min cannot be greater than max"}.to_json
    else
      random_number = rand(min..max)
      {random_number: random_number}.to_json
    end
  rescue JSON::ParserError
    status 400
    {message: "Invalid JSON: Please provide a valid JSON object with min and max properties"}.to_json
  end
end
