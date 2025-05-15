require "test_helper"

class OpenRouterClientTest < ActiveSupport::TestCase
  setup do
    # Stub the credentials
    Rails.application.credentials.stubs(:open_router_key).returns('fake-api-key')
    mock_credentials = OpenStruct.new(
      open_router_key: { 
        access_key_id: 'test_key',
        secret_access_key: 'test_secret'
      },
      stripe: {
        api_key: 'test_stripe_key'
      }
    )

    # Create a mock for OpenAI::Client
    @client_mock = Minitest::Mock.new
    # Stub the OpenAI::Client.new to return the mock
    OpenAI::Client.stubs(:new).with(
      access_token: 'fake-api-key',
      log_errors: true,
      uri_base: OpenRouterClient::API_BASE_URL
    ).returns(@client_mock)

    # Instantiate the class
    @open_router_client = OpenRouterClient.new
  end

  test 'initializes with correct configuration' do
    assert_not_nil @open_router_client
    # Verify the mock was used (implicitly tested by the stub)
  end

end
