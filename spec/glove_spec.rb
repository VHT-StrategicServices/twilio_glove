require_relative '../glove'
require 'test/unit'
require 'rack/test'

describe 'The Glove App' do
  include Rack::Test::Methods

  def app
    Glove
  end

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
    Register.stub(:is_activated?).with("3306702200").and_return(false)

    get '/glove/accept', params={:From => "3306702200"}

    expect(last_response).to be_ok
    expect(last_response.body).to include("Something bad happened. Message not posted :(")
  end

  it "returns a list of users sms message" do
    Register.stub(:is_activated?).with("3306702200").and_return(true)
    Register.stub(:all_users).and_return(["@jcron", "@roverfield"])

    get '/glove/accept', params={:From => "3306702200", :Body => "@@users"}

    expect(last_response).to be_ok
    expect(last_response.body).to include("@jcron\r\n@roverfield")
  end

  #it "returns a success sms message when activated" do
  #  Register.stub(:is_activated?).with("3306702200").and_return(true)
  #  DataTable.stub(:add_record_to_data)
  #
  #  get '/glove/accept', params={:From => "3306702200", :Body => "Hello"}
  #
  #  expect(last_response).to be_ok
  #  expect(last_response.body).to include("Ok. Got it!")
  #end
end