class MessagesController < ApplicationController
  include ToastHelper

  before_action :enforce_daily_limit

  def create
    @message = Message.new(message_params)

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

  def enforce_daily_limit
    limits = {
      "admin" => User::ADMIN_DAILY_COST_LIMIT_USD,
      "paid"  => User::PAID_DAILY_COST_LIMIT_USD,
      "free"  => User::FREE_DAILY_COST_LIMIT_USD
    }
    limit = limits[Current.user.account_type]

    # Return early if there's no limit for the account type or if the user is within the limit.
    # The `create` action will only be executed if this method doesn't render or redirect.
    return unless limit && Current.user.cost_exceeded?(limit: limit)

    # --- Limit Exceeded Path ---
    # If the limit is exceeded, show a toast and halt the request.
    conversation_id = params.dig(:message, :conversation_id)
    if conversation_id.present?
      ToastHelper.show_toast(
        "conversation_#{conversation_id}",
        "error",
        "Error",
        "You have reached your 24 hour token limit",
        8000
      )
    end

    head :forbidden
  end
end
