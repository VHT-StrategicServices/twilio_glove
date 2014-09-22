require 'twilio-ruby'
require_relative 'register'
require_relative 'data_table'
require_relative 'domain_helper'

class TwilioMessage

  def initialize params, settings
    @params = params
    @settings = settings
  end

  def sms_success_message
    DataTable.add_record_to_data(@params)
    send_mentions
    twilio_response = Twilio::TwiML::Response.new do |response|
      response.Message @settings.sms_success if @settings.send_success_message
    end.text
    log twilio_response
    twilio_response
  end

  def sms_users_message
    users = Register.all_users
    Twilio::TwiML::Response.new do |response|
      response.Message users.join(" ")
    end.text
  end

  def sms_failed_message
    log "#{@params[:From]} - not registered or not activated"
    twilio_response = Twilio::TwiML::Response.new do |response|
      response.Message @settings.sms_failure
    end.text
    log twilio_response
    twilio_response
  end

  def voice_reject_message
    Twilio::TwiML::Response.new do |response|
      response.Reject :reason => "busy"
    end.text
  end

  private

  def send_mentions
    if @settings.mentions
      mentioned_by = Register.mentioned_by(@params[:From])
      mentions = retrieve_mentions @params[:Body]
      if (not mentions.index("@vht").nil?) and Register.can_user_broadcast?(@params[:From])
        active_users = Register.all_active_users_except @params[:From]
        active_users.each {|user|
          mention_sms mentioned_by, user
        }
      else
        mentions.each { |mention|
          mentioned_phone_number = Register.mentioned_phone_number(mention)
          mention_sms mentioned_by, mentioned_phone_number
        }
      end
    end
  end

  def mention_sms mentioned_by, mentioned_phone_number
    unless mentioned_phone_number.nil?
      @client = Twilio::REST::Client.new @settings.account_sid, @settings.auth_token
      mentions_sms = "@#{mentioned_by} said - #{@params[:Body]}"
      medias = Media.where(message_sid: @params[:MessageSid])
      urls = []
      medias.each do |media|
        urls << media.url
      end
      @client.account.messages.create(
          :body => mentions_sms,
          :to => mentioned_phone_number,
          :from => @settings.sms_from_number,
          :media_url => urls
      )
    end
  end

  def get_sms_messages message
    messages = []
    while message.length > 0
      if message.length > 160
        messages << message[0..159]
        message = message[160..message.length]
      else
        messages << message
        break
      end
    end
    messages
  end

  def retrieve_mentions body
    mentions = []
    while body.include? '@'
      index_of_at = body.index('@')
      mention_termination = body.index(/\W/, index_of_at + 1)
      if mention_termination.nil?
        length_of_mention = body.length - index_of_at
        mention_termination = body.length
      else
        length_of_mention = mention_termination - index_of_at
      end
      mentions << body[index_of_at, length_of_mention].downcase
      body = body[mention_termination..body.length]
    end
    mentions
  end
end