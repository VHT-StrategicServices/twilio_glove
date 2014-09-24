xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "VHT Feed"
    xml.description "VHT Internal news, announcements, and general fun"
    xml.link "http://www.virtualhold.com"
    xml.image do
      xml.url "#{request.url.chomp request.path_info}/images/vht_black.png"
      xml.title "VHT Feed"
      xml.link "http://www.virtualhold.com"
    end
    xml.atom :link do
      xml.href "#{request.url.chomp request.path_info}/rss"
      xml.rel "self"
      xml.type "application/rss+xml"
    end

    @posts.each do |post|
      xml.item do
        xml.title post.smssid
        xml.link "#{request.url.chomp request.path_info}/post/#{post.smssid}"
        xml.description post.smssid
        xml.pubDate Time.parse(post.smsdatetime.to_s).rfc822()
        xml.guid "#{request.url.chomp request.path_info}/post/#{post.smssid}"
      end
    end
  end
end