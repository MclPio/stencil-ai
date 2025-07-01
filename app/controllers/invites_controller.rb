class InvitesController < ApplicationController
  before_action :authorize_admin

  def index
    @invites = Current.user.invites.includes(:user).order(created_at: :desc)
  end

  def new
    @invite = Current.user.invites.new
  end

  def create
    @invite = Current.user.invites.new(invite_params)
    if @invite.save
      redirect_to invites_path, notice: "Invite code successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @invite = Invite.find(params[:id])
    @invite.destroy!
    redirect_to invites_path, notice: "Invite code was successfully deleted."
  rescue ActiveRecord::RecordNotDestroyed
    redirect_to invites_path, alert: @invite.errors.full_messages.join(", ")
  end

  private

  def invite_params
    params.expect(invite: [ :expires_at, :reusable ])
  end

  def authorize_admin
    return if Current.user.account_type_admin?
    redirect_to root_path, alert: "Not found."
  end
end
