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

  test "successful chat returns a JSON object" do
    def fake_chat
      {DERP: "HALP"}
    end

    @open_router_client.stub :chat, fake_chat

    xd = @open_router_client.chat(
      model: @test_model,
      messages: @test_messages
    )

    puts xd
  end

  # test "response with error" do
  # end

  # test "Unexpected response is handled" do
  # end

  # test "Faraday::Error is handled" do
  # end

  # test "JSON::ParserError is handled" do
  # end

  # test "any other unexpected error is handled" do
  # end
end
