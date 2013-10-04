require 'win32/service'
include Win32

SERVICE_NAME = 'VhtFeed'

begin
  Service.stop(SERVICE_NAME) if Service.status(SERVICE_NAME).controls_accepted.include? "stop"
rescue
end

Service.delete(SERVICE_NAME)