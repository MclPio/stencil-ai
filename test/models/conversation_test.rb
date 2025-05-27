require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  setup do
    @conversation = conversations(:one)
  end

  test "default reached_token_limit is false" do
    assert_equal false, @conversation.reached_token_limit
  end

  test "reached_token_limit is set to true when TOKEN_LIMIT is reached" do
    @conversation.total_token.update(total: Conversation::TOKEN_LIMIT + 1)
    assert_equal true, @conversation.reached_token_limit
  end

  test "reached_token_limit is not set to true when TOKEN_LIMIT is not reached" do
    @conversation.total_token.update(total: 10)
    assert_equal false, @conversation.reached_token_limit
  end
end
