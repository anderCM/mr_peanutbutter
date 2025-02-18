module UserAuthorization
  extend ActiveSupport::Concern

  private

  def authorize_user
    requested_user_id = params[:user_id].to_i
    return if current_user.admin? || current_user.id == requested_user_id
    
    render_unauthorized("You are not authorized to access this resource") and return
  end
end
