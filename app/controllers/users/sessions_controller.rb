# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _options = {})
    render json: {
      status: { code: 200, message: "User Signed In Successfully", data: current_user }
    }, status: :ok
  end

  def respond_to_on_destroy
    begin
      jwt_payload = JWT.decode(request.headers['Authorization'].split(' ')[1], Rails.application.credentials.fetch(:secret_key_base)).first
      current_user = User.find(jwt_payload['sub'])
      
      if current_user
        render json: {
          status: 200, message: 'Signed out successfully'
        }, status: :ok
      else
        render json: {
          status: 401, message: 'User not found, no active session'
        }, status: :unauthorized
      end
    rescue JWT::DecodeError
      render json: {
        status: 401, message: 'Invalid token'
      }, status: :unauthorized
    end
  end
end
