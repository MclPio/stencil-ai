class InvitesController < ApplicationController
  before_action :authorize_admin

  def index
    @invites = Current.user.invites
  end

  def new
    @invite = Current.user.invites.new
  end

  def create
    @invite = Current.user.invites.new(invite_params)
    if @invite.save
      redirect_to @invite
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @invite = Invites.find(params[:id])
  end

  private

  def invite_params
    params.expect(invite: [ :expires_at ])
  end

  def authorize_admin
    return if Current.user.account_type_admin?
    redirect_to root_path, alert: "Not found."
  end
end
