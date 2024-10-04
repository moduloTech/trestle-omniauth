require 'hashie/mash'

module Trestle
  module Omniauth
    module ControllerMethods
      extend ActiveSupport::Concern

      included do
        helper_method :current_user, :logged_in?

        before_action :require_authenticated_user
      end

      protected

      def current_user
        return @current_user if defined?(@current_user)

        @current_user = Hashie::Mash.new(session[:trestle_user]) if session.key?(:trestle_user)
      end

      def login!(_auth_hash)
        session[:trestle_user] = request.env["omniauth.auth"].slice(
          *Trestle.config.omniauth.session_keys
        ).as_json
        current_user
      end

      def logout!
        session.delete(:trestle_user)
        @current_user = nil
      end

      def logged_in?
        !!current_user
      end

      def store_location
        session[:trestle_return_to] = request.fullpath
      end

      def previous_location
        session.delete(:trestle_return_to)
      end

      def require_authenticated_user
        logged_in? || login_required!
      end

      def login_required!
        store_location
        redirect_to trestle.login_url
        false
      end
    end
  end
end
