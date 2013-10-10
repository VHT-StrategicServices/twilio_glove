require 'active_record'

class Register < ActiveRecord::Base
  self.table_name  = "Register"
  #self.primary_key = "username"

  def self.is_activated?(phone_number)
    log "is_activated?"
    register = Register.find(:first, :conditions => [ "phone = ?", phone_number])
    if register.nil?
      false
    else
      register.Activated.strip == "1"
    end
  end

  def self.mentioned_by(from)
    log "mentioned_by"
    record = Register.find(:first, :conditions => [ "phone = ?", from])
    unless record.nil?
      record.username
    end
  end

  def self.mentioned_phone_number(mention)
    log "mentioned_phone_number"
    record = Register.find(:first, :conditions => [ "username = ?", "#{mention[1..mention.length]}"])
    if record.nil?
      nil
    else
      record.phone
    end
  end

  def self.can_user_broadcast?(phone_number)
    log "can_user_broadcast?"
    record = Register.find(:all, :conditions => ["phone = ? AND Activated = '1' AND broadcast = '1'", phone_number])
    record != []
  end

  def self.all_users
    log "all_users"
    records = Register.find(:all, :conditions => ["Activated = '1'"])
    active_users = []
    records.each {|record|
      active_users << "@#{record.username}"
    }
    active_users
  end

  def self.all_active_users_except(phone_number)
    log "all_active_users_except"
    records = Register.find(:all, :conditions => ["Activated = '1' AND NOT phone = ?", phone_number])
    registered_users = []
    records.each {|record|
      registered_users << record.phone
    }
    registered_users
  end

end