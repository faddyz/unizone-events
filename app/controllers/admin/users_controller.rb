class Admin::UsersController < ApplicationController
  ROLE_FILTERS = [
    [ "all", "Tumu" ],
    [ "admin", "Admin" ],
    [ "member", "Uye" ]
  ].freeze

  before_action :authenticate_user!
  before_action :authorize_index!
  before_action :set_user, only: :update

  def index
    @role_filters = ROLE_FILTERS
    @role = ROLE_FILTERS.map(&:first).include?(params[:role].to_s) ? params[:role].to_s : "all"
    @query = params[:query].to_s.strip
    @stats = {
      total: User.count,
      admins: User.where(admin: true).count,
      members: User.where(admin: false).count,
      recent: User.where(created_at: 7.days.ago..).count
    }
    @users = filtered_users.page(params[:page]).per(20)
    @active_filters = @query.present? || @role != "all"

    render "admin/users/index"
  end

  def update
    authorize @user

    new_admin_state = ActiveModel::Type::Boolean.new.cast(user_params[:admin])
    if removing_admin_from_self?(new_admin_state)
      redirect_back fallback_location: admin_users_path, alert: "Kendi admin rolunu kaldiramazsin.", status: :see_other
      return
    end

    if removing_last_admin?(new_admin_state)
      redirect_back fallback_location: admin_users_path, alert: "Sistemde en az bir admin kalmali.", status: :see_other
      return
    end

    @user.update!(admin: new_admin_state)
    role_label = @user.admin? ? "admin" : "uye"
    redirect_back fallback_location: admin_users_path, notice: "#{@user.email} rolu #{role_label} olarak guncellendi.", status: :see_other
  end

  private

  def authorize_index!
    authorize User
  end

  def set_user
    @user = policy_scope(User).find(params[:id])
  end

  def filtered_users
    scope = policy_scope(User).left_joins(:events, :attendances)
                             .select("users.*, COUNT(DISTINCT events.id) AS events_count, COUNT(DISTINCT attendances.id) AS attendances_count")
                             .group("users.id")
    scope = scope.where(admin: true) if @role == "admin"
    scope = scope.where(admin: false) if @role == "member"

    if @query.present?
      needle = "%#{@query.downcase}%"
      scope = scope.where("LOWER(users.email) LIKE :query OR LOWER(users.name) LIKE :query", query: needle)
    end

    scope.order(admin: :desc, created_at: :desc)
  end

  def user_params
    params.require(:user).permit(:admin)
  end

  def removing_admin_from_self?(new_admin_state)
    @user == current_user && @user.admin? && !new_admin_state
  end

  def removing_last_admin?(new_admin_state)
    @user.admin? && !new_admin_state && User.where(admin: true).where.not(id: @user.id).none?
  end
end
