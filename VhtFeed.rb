require 'win32/daemon'
#require './glove.rb'
begin

def log(text)
  File.open('C:\\log.txt', 'a') { |f| f.puts "#{Time.now}: #{text}" }
end

  require_relative 'glove'


  include Win32

  class VhtFeed < Daemon
    def service_main
      log 'started'
      begin
        Glove.run! :bind => '0.0.0.0', :port => 3000, :server => 'thin'
      rescue Exception => err
        log err
      end
    end

    def service_stop
      log 'ended'
      exit!
    end

  end

  VhtFeed.mainloop

rescue Exception => err
  log err
end
