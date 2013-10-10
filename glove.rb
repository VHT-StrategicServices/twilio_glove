require 'rubygems'
require 'sinatra/base'
require 'sinatra/config_file'
require 'twilio-ruby'
require_relative 'register'
require_relative 'data_table'
require_relative 'lib/fiat_register'

class Glove < Sinatra::Base
  register Sinatra::ConfigFile
  config_file 'config.yml'

  def initialize
    begin
      super
      log "Establishing connection to database..."
      FiatRegister.establish_sqlserver_connection(settings.server_name, settings.database_name, settings.database_user, settings.database_password)
      log "Glove has been initialized"
    rescue Exception => err
      log_exception err
    end
  end
  
  before do
    log_request "Before", request, status
  end

  get '/test' do
    message = "the glove is ready to catch"
    log message
    body message
  end

  get '/glove/accept' do
    begin
      if Register.is_activated?(params[:From])
        if params[:Body].downcase.include?(settings.retrieve_all_users_tag)
          sms_users_message
        else
          sms_success_message
        end
      else
        sms_failed_message
      end
    rescue Exception => err
      log_exception err
    end
  end
  
  after do
    log_request "After", request, status
  end

  private
  
  def log(text)
    File.open('C:\\TwilioGlove\\log.txt', 'a') { |f| f.puts "#{Time.now}: #{text}" }
  end
  
  def log_exception(exception)
    log exception.message
    log exception.backtrace
  end

  def log_request where, request, status
    begin
      log "#{where} - #{request.ip} - #{request.request_method} #{request.path_info}?#{request.query_string} - #{params[:Body]} - #{status}"
    rescue Exception => err
      log_exception err
    end
  end

  def sms_success_message
    DataTable.add_record_to_data(params)
    twilio_response = Twilio::TwiML::Response.new do |response|
      response = mentions(response)
      response.Sms settings.sms_success unless settings.send_success_message == false
    end.text
    log twilio_response
    twilio_response
  end

  def sms_users_message
    users = Register.all_users
    twilio_response = Twilio::TwiML::Response.new do |response|
      response.Sms users.join("\r\n")
    end.text
    log twilio_response
    twilio_response
  end

  def sms_failed_message
    log "#{params[:From]} - not registered or not activated"
    twilio_response = Twilio::TwiML::Response.new do |r|
      r.Sms settings.sms_failure
    end.text
    log twilio_response
    twilio_response
  end

  def mentions response
    if settings.mentions == true
      mentioned_by = Register.mentioned_by(params[:From])
      mentions = retrieve_mentions params[:Body]
      if (not mentions.index("@vht").nil?) and Register.can_user_broadcast?(params[:From])
        active_users = Register.all_active_users_except params[:From]
        active_users.each {|user|
          mention_sms response, mentioned_by, user
        }
      else
        mentions.each { |mention|
          mentioned_phone_number = Register.mentioned_phone_number(mention)
          mention_sms response, mentioned_by, mentioned_phone_number
        }
      end
    end
    response
  end

  def mention_sms response, mentioned_by, mentioned_phone_number
    mentions_sms = "@#{mentioned_by} said - #{params[:Body]}"
	  get_sms_messages(mentions_sms).each {|message|
	    response.Sms message, :to => mentioned_phone_number unless mentioned_phone_number.nil?
	  }
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