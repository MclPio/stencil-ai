class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_url, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    if @user.save
      UserMailer.welcome(@user).deliver_later
      start_new_session_for @user
      redirect_to root_path, notice: "Successfully signed up!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    tab = params[:user][:redirect_tab] || "profile"

    if @user.authenticate(params[:current_password])
      if params[:user][:name].present?
        # Handle name update
        if @user.update(name_params)
          redirect_to edit_registration_path(tab: tab), notice: "Name updated successfully!"
        else
          flash.now[:alert] = @user.errors.full_messages.join(", ")
          render :edit, status: :unprocessable_entity, locals: { tab: tab }
        end
      elsif params[:user][:email_address].present?
        # Handle email address update
        if @user.update(email_params)
          redirect_to edit_registration_path(tab: tab), notice: "Email updated successfully!"
        else
          flash.now[:alert] = @user.errors.full_messages.join(", ")
          render :edit, status: :unprocessable_entity, locals: { tab: tab }
        end
      elsif params[:user][:password].present?
        # Handle password update
        if @user.update(password_params)
          redirect_to edit_registration_path(tab: tab), notice: "Password updated successfully!"
        else
          flash.now[:alert] = @user.errors.full_messages.join(", ")
          render :edit, status: :unprocessable_entity, locals: { tab: tab }
        end
      else
        flash.now[:alert] = "Please provide a new name, email address, or password."
        render :edit, status: :unprocessable_entity, locals: { tab: tab }
      end
    else
      flash.now[:alert] = "Current password is incorrect."
      render :edit, status: :unprocessable_entity, locals: { tab: tab }
    end
  end

  def destroy
    @user = Current.user
    if @user.authenticate(params[:current_password])
      @user.destroy
      terminate_session
      flash[:notice] = "Your account has been successfully deleted."
      redirect_to new_session_path
    else
      flash[:alert] = "Current password is incorrect. Account deletion failed."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.expect(user: [ :name, :email_address, :password, :password_confirmation, :invite_code ])
  end

  def password_params
    params.expect(user: [ :password, :password_confirmation ])
  end

  def email_params
    params.expect(user: [ :email_address ])
  end

  def name_params
    params.expect(user: [ :name ])
  end
end
