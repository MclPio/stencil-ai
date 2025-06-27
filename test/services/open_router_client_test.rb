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

  test "successful chat returns the raw response" do
    # This mock simulates the raw, successful response from the API
    mock_response = {
      "choices" => [ { "message" => { "content" => "Hello, how can I help you today?" } } ],
      "usage" => { "total_tokens" => 4 }
    }
    mock_client = Object.new
    # The block here is a closure, so it has access to mock_response
    mock_client.define_singleton_method(:chat) { |parameters:| mock_response }

    @open_router_client.instance_variable_set(:@client, mock_client)

    result = @open_router_client.chat(model: @test_model, messages: @test_messages)

    # Assert that the raw response is returned and has the expected structure
    assert_nil result["error"]
    assert_equal "Hello, how can I help you today?", result.dig("choices", 0, "message", "content")
    assert_equal 4, result.dig("usage", "total_tokens")
  end

  test "response with an error code returns the raw error response" do
    # This mock simulates a raw response that contains an error object
    mock_response = { "error" => { "message" => "Service unavailable", "code" => "service_unavailable" } }
    mock_client = Object.new
    mock_client.define_singleton_method(:chat) { |parameters:| mock_response }

    @open_router_client.instance_variable_set(:@client, mock_client)

    result = @open_router_client.chat(model: @test_model, messages: @test_messages)

    # Assert that the error object is present and contains the correct data
    assert_not_nil result["error"]
    assert_equal "Service unavailable", result.dig("error", "message")
  end

  test "response with missing content is returned as-is" do
    # The client now just warns and returns the malformed response
    mock_response = { "choices" => [ { "message" => { "something_other_than_content" => "HEHE" } } ] }
    mock_client = Object.new
    mock_client.define_singleton_method(:chat) { |parameters:| mock_response }

    @open_router_client.instance_variable_set(:@client, mock_client)

    result = @open_router_client.chat(model: @test_model, messages: @test_messages)

    # Assert the response is returned and content is nil
    assert_not_nil result["choices"]
    assert_nil result.dig("choices", 0, "message", "content")
  end

  test "Faraday::Error is handled and returns a formatted error hash" do
    # Mock the client to raise a network error
    mock_client = Object.new
    def mock_client.chat(parameters:); raise Faraday::Error; end

    @open_router_client.instance_variable_set(:@client, mock_client)

    result = @open_router_client.chat(model: @test_model, messages: @test_messages)

    # Assert that the rescue block returns the correct structure
    assert_equal "Unable to connect to service provider", result.dig("error", "message")
    assert_equal "network_error", result.dig("error", "type")
  end

  test "JSON::ParserError is handled and returns a formatted error hash" do
    # Mock the client to raise a JSON parsing error
    mock_client = Object.new
    def mock_client.chat(parameters:); raise JSON::ParserError; end

    @open_router_client.instance_variable_set(:@client, mock_client)

    result = @open_router_client.chat(model: @test_model, messages: @test_messages)

    # Assert that the rescue block returns the correct structure
    assert_equal "Error processing response", result.dig("error", "message")
    assert_equal "json_parse_error", result.dig("error", "code")
  end

  test "any other unexpected error is handled and returns a formatted error hash" do
    # Mock the client to raise a generic, unexpected error
    mock_client = Object.new
    def mock_client.chat(parameters:); raise "A generic error"; end

    @open_router_client.instance_variable_set(:@client, mock_client)

    result = @open_router_client.chat(model: @test_model, messages: @test_messages)

    # Assert that the generic rescue block returns the correct structure
    assert_equal "An unexpected error occurred", result.dig("error", "message")
    assert_equal "internal_error", result.dig("error", "type")
  end

  test "handles optional parameters correctly" do
    # This test verifies that all parameters are correctly passed to the underlying client
    captured_params = nil # Use a local variable to capture the parameters
    mock_client = Object.new

    # Define a singleton method on the mock object to capture the parameters
    mock_client.define_singleton_method(:chat) do |parameters:|
      captured_params = parameters # Assign to the variable in the outer scope
      # Return a minimal success response
      { "choices" => [ { "message" => { "content" => "OK" } } ] }
    end

    @open_router_client.instance_variable_set(:@client, mock_client)

    @open_router_client.chat(
      model: @test_model,
      messages: @test_messages,
      temperature: 0.5,
      response_format: { type: "json_object" },
      max_tokens: 1000,
      usage: { "include": true }
    )

    assert_equal @test_model, captured_params[:model]
    assert_equal @test_messages, captured_params[:messages]
    assert_equal 0.5, captured_params[:temperature]
    assert_equal({ type: "json_object" }, captured_params[:response_format])
    assert_equal 1000, captured_params[:max_tokens]
    assert_equal({ "include": true }, captured_params[:usage])
  end
end
