require './glove.rb'

map "/images" do
  run Rack::Directory.new("./public/images")
end

map "/stylesheets" do
  run Rack::Directory.new("./public/stylesheets")
end

run Glove.new