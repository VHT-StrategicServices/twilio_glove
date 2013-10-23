require 'rubygems'
require 'sinatra/base'
require 'sinatra/config_file'
require_relative 'lib/register'
require_relative 'lib/fiat_register'
require_relative 'lib/domain_helper'
require_relative 'lib/twilio_message'

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
      twilio_message = TwilioMessage.new params, settings
      if Register.is_activated?(params[:From])
        if params[:Body].downcase.include?(settings.retrieve_all_users_tag)
          twilio_message.sms_users_message
        else
          twilio_message.sms_success_message
        end
      else
        twilio_message.sms_failed_message
      end
    rescue Exception => err
      log_exception err
    end
  end

  get '/glove/reject' do
    begin
      twilio_message = TwilioMessage.new params, settings
      twilio_message.voice_reject_message
    rescue Exception => err
      log_exception err
    end
  end
  
  after do
    log_request "After", request, status
  end
end