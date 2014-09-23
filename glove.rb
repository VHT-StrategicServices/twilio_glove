require 'rubygems'
require 'sinatra/base'
require 'sinatra/config_file'
require 'builder'
require_relative 'lib/register'
require_relative 'lib/fiat_register'
require_relative 'lib/domain_helper'
require_relative 'lib/twilio_message'

class Glove < Sinatra::Base
  set :public_folder => "public"
  set :static => true
  set :root => File.dirname(__FILE__)
  register Sinatra::ConfigFile
  config_file 'config.yml'

  def initialize
    begin
      super
      log "Establishing connection to database..."
      FiatRegister.establish_sqlserver_connection(settings.server_name, settings.database_name, settings.database_user, settings.database_password)
      Dir.chdir "/home/fiat/TwilioGlove"
      log Dir.pwd
      log "Glove has been initialized"
    rescue Exception => err
      log_exception err
    end
  end
  
  before do
    log_request "Before", request, status
    log Dir.pwd
    log File.dirname(__FILE__)
    log settings.public_folder
    log settings.root
  end

  helpers do
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['feed', 'B1sCu1t']
    end
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

  get '/feed/rss' do
    @posts = DataTable.all + DataArchiveTable.all
    builder :rss
  end

  get '/posts/:id' do
    protected!
    @post = DataTable.where(smssid: params[:id]).first
    @post = DataArchiveTable.where(smssid: params[:id]).first if @post.nil?
    @images = Media.where(message_sid: @post.smssid)
    erb :post
  end

  get '/slideshow' do
    erb :slide_show
  end

  after do
    log_request "After", request, status
  end
end