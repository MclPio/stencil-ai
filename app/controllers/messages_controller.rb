class MessagesController < ApplicationController
  include ConversationHelper
  include ToastHelper

  def create
    @message = Message.new(message_params)
    if below_cost_limit?
      if @message.save
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream:
              turbo_stream.append("conversations", partial: "conversations/user_role",
                                                    locals: { message: @message })
          end
          format.html { redirect_to @message.conversation }
        end

        if ids_exist
          id_set.each do |artifact_stencil_id, favorite_artifact_stencil_id|
            MermaidJob.perform_later(message_params[:conversation_id], artifact_stencil_id, favorite_artifact_stencil_id, Current.user)
          end
        else
          ProcessLlmChatJob.perform_later(message_params[:conversation_id], Current.user)
        end
      else
        if @message.errors[:base].include?("Conversation has exceeded the token limit of #{Conversation::TOKEN_LIMIT}")
          Turbo::StreamsChannel.broadcast_replace_to(
            "conversation_#{@message.conversation_id}",
            target: "conversation-message-form",
            partial: "conversations/message_form_disabled",
            locals: { conversation: @message.conversation}
          )
        end
        ToastHelper.show_toast("conversation_#{message_params[:conversation_id]}", "error", "Error",  @message.errors.full_messages.join(", "), 8000)
      end
    else
      ToastHelper.show_toast("conversation_#{message_params[:conversation_id]}", "error", "Error",  "You have reached your 24 hour token limit", 8000)
    end
  end

  private

  def message_params
    params.expect(message: [ :content, :conversation_id ])
  end

  def ids_exist
    if params[:message][:artifact_stencil_ids].present? && params[:message][:artifact_stencil_ids].reject(&:blank?).any?
      params[:message][:favorite_artifact_stencil_ids].present? && params[:message][:favorite_artifact_stencil_ids].reject(&:blank?).any?
    end
  end

  def id_set
    a = params[:message][:artifact_stencil_ids].first.split(",").map(&:to_i)
    fav = params[:message][:favorite_artifact_stencil_ids].first.split(",").map(&:to_i)

    a.zip(fav)
  end

  def below_cost_limit?
    account_type = Current.user.account_type
    case account_type
    when "admin"
      Current.user.current_daily_cost < User::ADMIN_DAILY_COST_LIMIT_USD
    when "paid"
      Current.user.current_daily_cost < User::PAID_DAILY_COST_LIMIT_USD
    when "free"
      Current.user.current_daily_cost < User::FREE_DAILY_COST_LIMIT_USD
    end
  end
end
