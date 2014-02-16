class SessionsController < ApplicationController
  def destroy
    session.clear
    cookies.clear
    redirect_to "/login"
  end
end