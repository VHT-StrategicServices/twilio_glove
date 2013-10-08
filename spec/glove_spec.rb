require_relative '../glove'
require 'test/unit'
require 'rack/test'

describe 'The Glove App' do
  include Rack::Test::Methods

  def app
    Glove
  end

  FROM_PHONE_NUMBER = "+13306702200"

  before :each do
    file = double("File")
    File.stub(:open).and_yield(file)
    file.stub(:puts)
  end

  it "has a test endpoint" do
    get '/test'

    expect(last_response).to be_ok
    expect(last_response.body).to eq('the glove is ready to catch')
  end

  it "returns a failed sms message when not activated" do
    Register.stub(:is_activated?).with(FROM_PHONE_NUMBER).and_return(false)

    get '/glove/accept', params={:From => FROM_PHONE_NUMBER}

    expect(last_response).to be_ok
    expect(last_response.body).to include("Something bad happened. Message not posted :(")
  end

  it "returns a list of users sms message" do
    Register.stub(:is_activated?).with(FROM_PHONE_NUMBER).and_return(true)
    Register.stub(:all_users).and_return(["@jcron", "@roverfield"])

    get '/glove/accept', params={:From => FROM_PHONE_NUMBER, :Body => "@@users"}

    expect(last_response).to be_ok
    expect(last_response.body).to include("@jcron\r\n@roverfield")
  end

  describe 'success messages' do

    before :each do
      Register.stub(:is_activated?).with(FROM_PHONE_NUMBER).and_return(true)
      DataTable.stub(:add_record_to_data)
      Register.stub(:mentioned_by).with(FROM_PHONE_NUMBER).and_return("jcron")
      Register.stub(:can_user_broadcast?).with(FROM_PHONE_NUMBER).and_return(false)
    end

    it "returns a success sms message" do
      get '/glove/accept', params={:From => FROM_PHONE_NUMBER, :Body => "Hello"}

      expect(last_response).to be_ok
      expect(last_response.body).to include("Ok. Got it!")
    end

    describe 'mention sms messages' do
      it "sends a mention sms message" do
        Register.stub(:mentioned_phone_number).with("@roverfield").and_return("+13307772200")

        get '/glove/accept', params={:From => FROM_PHONE_NUMBER, :Body => "@roverfield - Hello"}

        expect(last_response).to be_ok
        expect(last_response.body).to include("to=\"+13307772200\"")
        expect(last_response.body).to include("@jcron said - @roverfield - Hello")
        expect(last_response.body).to include("Ok. Got it!")
      end

      it 'finds multiple mentions separated by a space' do
        Register.stub(:mentioned_phone_number).with("@roverfield").and_return("+13307772200")
        Register.stub(:mentioned_phone_number).with("@nkennedy").and_return("+12167770022")

        get '/glove/accept', params={:From => FROM_PHONE_NUMBER, :Body => "@roverfield @nkennedy - Hello"}

        expect(last_response).to be_ok
        expect(last_response.body).to include("to=\"+13307772200\"")
        expect(last_response.body).to include("to=\"+12167770022\"")
        expect(last_response.body).to include("@jcron said - @roverfield @nkennedy - Hello")
        expect(last_response.body).to include("Ok. Got it!")
      end

      it 'finds multiple mentions separated by punctuation' do
        Register.stub(:mentioned_phone_number).with("@roverfield").and_return("+13307772200")
        Register.stub(:mentioned_phone_number).with("@nkennedy").and_return("+12167770022")

        get '/glove/accept', params={:From => FROM_PHONE_NUMBER, :Body => "@roverfield,@nkennedy - Hello"}

        expect(last_response).to be_ok
        expect(last_response.body).to include("to=\"+13307772200\"")
        expect(last_response.body).to include("to=\"+12167770022\"")
        expect(last_response.body).to include("@jcron said - @roverfield,@nkennedy - Hello")
        expect(last_response.body).to include("Ok. Got it!")
      end

      it 'finds the mention at the end of the message' do
        Register.stub(:mentioned_phone_number).with("@roverfield").and_return("+13307772200")

        get '/glove/accept', params={:From => FROM_PHONE_NUMBER, :Body => "Hello - @roverfield"}

        expect(last_response).to be_ok
        expect(last_response.body).to include("to=\"+13307772200\"")
        expect(last_response.body).to include("@jcron said - Hello - @roverfield")
        expect(last_response.body).to include("Ok. Got it!")
      end

    end

  end

  describe 'broadcast to all users' do
    before :each do
      Register.stub(:is_activated?).with(FROM_PHONE_NUMBER).and_return(true)
      DataTable.stub(:add_record_to_data)
      Register.stub(:mentioned_by).with(FROM_PHONE_NUMBER).and_return("jcron")
    end

    it "does not broadcast if user cannot broadcast" do
      Register.stub(:can_user_broadcast?).with(FROM_PHONE_NUMBER).and_return(false)
      Register.stub(:mentioned_phone_number).with("@vht").and_return(nil)

      get '/glove/accept', params={:From => FROM_PHONE_NUMBER, :Body => "@vht - Hello"}

      expect(last_response).to be_ok
      expect(last_response.body).to include("Ok. Got it!")
    end

    it "broadcasts to all users" do
      Register.stub(:can_user_broadcast?).with(FROM_PHONE_NUMBER).and_return(true)
      Register.stub(:all_active_users_except).with(FROM_PHONE_NUMBER).and_return(["+13307770000", "+12167770000"])

      get '/glove/accept', params={:From => FROM_PHONE_NUMBER, :Body => "@vht - Hello"}

      expect(last_response).to be_ok
      expect(last_response.body).to include("to=\"+13307770000\"")
      expect(last_response.body).to include("to=\"+12167770000\"")
      expect(last_response.body).to include("@jcron said - @vht - Hello")
    end
  end
end