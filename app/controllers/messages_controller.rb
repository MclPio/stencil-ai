class MessagesController < ApplicationController
  def create
    @message = Message.new(message_params)
    @message.save
  end

  private

  def message_params
    params.expect(message: [ :content, :conversation_id ])
  end
end
