class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_filter :set_csrf_cookie_for_ng

  # Require authentication by default
  before_filter :require_login

  # CanCan authorization in everything
  check_authorization unless: :authorized_controllers?

  # User impersonation for super-admin users
  impersonates :user

  # Rescues
  rescue_from ::ActiveRecord::RecordNotFound do |e| handle_default_exception(e, :not_found); end
  rescue_from ::ActiveRecord::RecordInvalid do |e| handle_record_invalid(e); end
  rescue_from ::ActiveRecord::RecordNotSaved do |e| handle_record_invalid(e); end
  rescue_from ::ActiveRecord::RecordNotUnique do |e| handle_email_not_unique(e); end
  rescue_from ::ActionController::ParameterMissing do |e| handle_default_exception(e, :bad_request); end

  rescue_from ::CanCan::AccessDenied do |exception|
    render file: "#{Rails.root}/public/403", status: 403, formats: [:html, :json], layout: false
  end

protected

  def authorized_controllers?
    devise_controller? or kind_of?(::ActiveAdmin::BaseController) or kind_of?(::OauthsController) or kind_of?(::ActiveAdmin::Devise::SessionsController)
  end

  def not_authenticated
    redirect_to login_path, alert: 'Please login first'
  end

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def verified_request?
    super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
    # Rails 4.1: super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end

  # Errors from rescue
  def handle_default_exception(e, status)
    render json: {error: e.message}, status: status
  end

  def handle_record_invalid(e)
    render json: {error: e.record.errors.full_messages.join(', ')}, status: :unprocessable_entity
  end

  def handle_email_not_unique(e)
    render json: {error: 'Email address is not unique'}, status: :unprocessable_entity
  end

end
