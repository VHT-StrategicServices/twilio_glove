require 'active_record'

class Register < ActiveRecord::Base
  self.table_name  = "Register"
  #self.primary_key = "username"
  CONNECTION_NAME = 'twilio_glove'

  # this should be moved out of here
  def self.establish_connection(opts)
    ActiveRecord::Base.configurations[CONNECTION_NAME] = opts
    ActiveRecord::Base.establish_connection(CONNECTION_NAME)
  end

  def self.establish_sqlserver_connection(host, database, username, password, opts = {})
    establish_connection({
                             :adapter => 'sqlserver',
                             :mode => 'dblib',
                             :host => host,
                             :database => database,
                             :username => username,
                             :password => password
                         }.merge(opts))
  end

  def self.is_activated?(phone_number)
    register = Register.find(:first, :conditions => [ "phone = ?", phone_number])
    if register.nil?
      false
    else
      register.Activated.strip == "1"
    end
  end

  def self.mentioned_by(from)
    record = Register.find(:first, :conditions => [ "phone = ?", from])
    unless record.nil?
      record.username
    end
  end

  def self.mentioned_phone_number(mention)
    record = Register.find(:first, :conditions => [ "username = ?", "#{mention[1..mention.length]}"])
    if record.nil?
      nil
    else
      record.phone
    end
  end

  def self.can_user_broadcast?(phone_number)
    record = Register.find(:all, :conditions => ["phone = ? AND Activated = '1' AND broadcast = '1'", phone_number])
    record != []
  end

  def self.all_users
    records = Register.find(:all, :conditions => ["Activated = '1'"])
    active_users = []
    records.each {|record|
      active_users << "@#{record.username}"
    }
    active_users
  end

  def self.all_active_users_except(phone_number)
    records = Register.find(:all, :conditions => ["Activated = '1' AND NOT phone = ?", phone_number])
    registered_users = []
    records.each {|record|
      registered_users << record.phone
    }
    registered_users
  end

end