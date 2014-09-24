require './glove.rb'

map "/images" do
  run Rack::Directory.new("./public/images")
end

map "/stylesheets" do
  run Rack::Directory.new("./public/stylesheets")
end

map "/javascripts" do
  run Rack::Directory.new("./public/javascripts")
end

map "/fonts" do
  run Rack::Directory.new("./public/fonts")
end

run Glove.new