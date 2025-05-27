require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "does not create message if conversation is over token limit" do
    message = messages(:one)
    conversation = message.conversation
    total_token = conversation.total_token
    total_token.total = 96001

    new_message = Message.build(conversation: conversation, content: "hello world")

    assert_not new_message.save, "Message was saved despite exceeding token limit"
    assert_includes new_message.errors.full_messages, "Conversation has exceeded the token limit of 96000"
    assert_not new_message.persisted?, "Message was persisted despite validation failure"
  end
end
