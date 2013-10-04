require 'win32/service'
include Win32

SERVICE_NAME = 'VhtFeed'

Service.create({
  service_name: SERVICE_NAME,
  host: nil,
  service_type: Service::WIN32_OWN_PROCESS,
  description: 'VHT Feed',
  start_type: Service::AUTO_START,
  error_control: Service::ERROR_NORMAL,
  binary_path_name: "ruby #{File.expand_path(File.join(File.dirname(__FILE__), '../', 'VhtFeed.rb'))}",
  load_order_group: 'Network',
  dependencies: nil,
  display_name: 'VhtFeed'
})


begin
  Service.start(SERVICE_NAME)
rescue Exception => err
  puts err
end