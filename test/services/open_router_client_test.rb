require "test_helper"
require "minitest/mock"

class OpenRouterClientTest < ActiveSupport::TestCase
  setup do
    @open_router_client = OpenRouterClient.new
    @test_model = "google/gemini-2.0-flash-exp:free"
    @test_messages = [ { role: "user", content: "Hello" } ]
  end

  test "initializes with correct configuration" do
    assert_instance_of(OpenRouterClient, @open_router_client)
    assert_equal Rails.application.credentials.open_router_key, @open_router_client.instance_variable_get(:@client).access_token
    assert_equal OpenRouterClient::API_BASE_URL, @open_router_client.instance_variable_get(:@client).uri_base
  end

  test "successful chat returns expected content" do
    mock_client = Object.new
    def mock_client.chat(parameters:)
      {
        "choices" => [
          {
            "message" => {
              "content" => "Hello, how can I help you today?"
            }
          }
        ]
      }
    end

    @open_router_client.instance_variable_set(:@client, mock_client)

    result = @open_router_client.chat(
      model: @test_model,
      messages: @test_messages
    )

    assert_equal false, result[:error]
    assert_equal "Hello, how can I help you today?", result[:content]
  end

  test "response with error code" do
    mock_client = Object.new
    def mock_client.chat(parameters:)
      {
        "error" => {
            "code" => "420"
        }
      }
    end

    @open_router_client.instance_variable_set(:@client, mock_client)

    result = @open_router_client.chat(
      model: @test_model,
      messages: @test_messages
    )

    assert_equal true, result[:error]
    assert_equal "Service unavailable", result[:message]
  end

  test "Unexpected response is handled" do
    mock_client = Object.new
    def mock_client.chat(parameters:)
      {
        "choices" => {
          "message" => {
            "something_other_than_content" => "HEHE"
          }
        }
      }
    end

    @open_router_client.instance_variable_set(:@client, mock_client)

    result = @open_router_client.chat(
      model: @test_model,
      messages: @test_messages
    )

    assert_equal true, result[:error]
    assert_equal "Received unexpected response from provider", result[:message]
  end

  test "Faraday::Error is handled" do
    mock_client = Object.new
    def mock_client.chat(parameters:)
      raise Faraday::Error
    end

    @open_router_client.instance_variable_set(:@client, mock_client)

    result = @open_router_client.chat(
      model: @test_model,
      messages: @test_messages
    )

    assert_equal true, result[:error]
    assert_equal "Unable to connect to service provider", result[:message]
  end

  test "JSON::ParserError is handled" do
    mock_client = Object.new
    def mock_client.chat(parameters:)
      raise JSON::ParserError
    end

    @open_router_client.instance_variable_set(:@client, mock_client)

    result = @open_router_client.chat(
      model: @test_model,
      messages: @test_messages
    )

    assert_equal true, result[:error]
    assert_equal "Error processing response", result[:message]
  end

  test "any other unexpected error is handled" do
    mock_client = Object.new
    def mock_client.chat(parameters:)
      raise "error"
    end

    @open_router_client.instance_variable_set(:@client, mock_client)

    result = @open_router_client.chat(
      model: @test_model,
      messages: @test_messages
    )

    assert_equal true, result[:error]
    assert_equal "An unexpected error occurred", result[:message]
  end
end
