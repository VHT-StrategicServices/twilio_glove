require 'active_record'

class DataTable < ActiveRecord::Base
  self.table_name="data"

  def self.add_record_to_data(parameters)
    log "add_record_to_data"
    DataTable.create(
        :smsdatetime => Time.now,
        :accountsid => parameters[:AccountSid],
        :body => parameters[:Body],
        :tozip => parameters[:ToZip],
        :fromstate => parameters[:FromState],
        :tocity => parameters[:ToCity],
        :smssid => parameters[:SmsSid],
        :tostate => parameters[:ToState],
        :to => parameters[:To],
        :tocountry => parameters[:ToCountry],
        :fromcountry => parameters[:FromCountry],
        :smsmessagesid => parameters[:SmsMessageSid],
        :apiversion => parameters[:ApiVersion],
        :fromcity => parameters[:FromCity],
        :smsstatus => parameters[:SmsStatus],
        :from => parameters[:From],
        :fromzip => parameters[:FromZip]
    )
  end
end