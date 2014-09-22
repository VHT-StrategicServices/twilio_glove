require 'active_record'

class Register < ActiveRecord::Base
  self.table_name  = "Register"

  def self.is_activated?(phone_number)
    log "is_activated?"
    register = Register.where(phone: phone_number).first
    if register.nil?
      false
    else
      register.Activated.strip == "1"
    end
  end

  def self.mentioned_by(from)
    log "mentioned_by"
    record = Register.where(phone: from).first
    unless record.nil?
      record.username
    end
  end

  def self.mentioned_phone_number(mention)
    log "mentioned_phone_number"
    record = Register.where(username: "#{mention[1..mention.length]}").first
    if record.nil?
      nil
    else
      record.phone
    end
  end

  def self.can_user_broadcast?(phone_number)
    log "can_user_broadcast?"
    record = Register.where("phone = ? AND Activated = '1' AND broadcast = '1'", phone_number).all
    record != []
  end

  def self.all_users
    log "all_users"
    records = Register.where(Activated: '1').all
    active_users = []
    records.each {|record|
      active_users << "@#{record.username}"
    }
    active_users
  end

  def self.all_active_users_except(phone_number)
    log "all_active_users_except"
    records = Register.where("Activated = '1' AND NOT phone = ?", phone_number).all
    registered_users = []
    records.each {|record|
      registered_users << record.phone
    }
    registered_users
  end

end