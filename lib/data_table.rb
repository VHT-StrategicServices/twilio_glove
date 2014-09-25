require 'active_record'

class DataTable < ActiveRecord::Base
  self.primary_key = :smssid
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
        :fromzip => parameters[:FromZip],
        :nummedia => parameters[:NumMedia]
    )
    Media.add_media_records(parameters)
  end
end

class DataArchiveTable < ActiveRecord::Base
  self.primary_key = :smssid
  self.table_name="data_archive"
end

class Media < ActiveRecord::Base
  self.primary_key = :url
  self.table_name = "media"

  def self.add_media_records(parameters)
    log "add_media_records"
    num_media = parameters[:NumMedia].to_i
    for i in 0..(num_media - 1) do
      Media.create(
        :message_sid => parameters[:MessageSid],
        :content_type => parameters["MediaContentType" + i.to_s],
        :url => parameters["MediaUrl" + i.to_s]
      )
    end
  end
end