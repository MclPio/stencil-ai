class PagesController < ApplicationController
  allow_unauthenticated_access

  def home
    render "pages/landing/home"
  end
end
