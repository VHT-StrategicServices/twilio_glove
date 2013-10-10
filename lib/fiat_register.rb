require 'active_record'

class FiatRegister < ActiveRecord::Base
  CONNECTION_NAME = 'twilio_glove'

  def self.establish_sqlserver_connection(host, database, username, password, opts = {})
    options = {
        :adapter => 'sqlserver',
        :mode => 'dblib',
        :host => host,
        :database => database,
        :username => username,
        :password => password
    }.merge(opts)
    ActiveRecord::Base.configurations[CONNECTION_NAME] = options
    ActiveRecord::Base.establish_connection(CONNECTION_NAME)
  end
end