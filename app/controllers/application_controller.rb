# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base




  protect_from_forgery
  before_filter :current_user_variables

    # before_filter :check_url
    after_filter :browser_detection
  # end

  # def check_url
  #   redirect_to "http://snowbooks.bibliocloud.com"  if request.host.match /snowbooks.com/i
  # end


  def browser_detection
    result  = request.env['HTTP_USER_AGENT']
    browser_compatible = ''
    if result =~ /Safari/
      unless result =~ /Chrome/
        version = result.split('Version/')[1].split(' ').first.split('.').first
        browser_compatible = 'Upgrade your browser: Bibliocloud does not support Safari version\'s '+version if version.to_i < 5
      else
        version = result.split('Chrome/')[1].split(' ').first.split('.').first
        browser_compatible = 'Upgrade your browser: Bibliocloud does not support Chrome version\'s '+version if version.to_i < 25
      end
    elsif result =~ /Firefox/
      version = result.split('Firefox/')[1].split('.').first
      browser_compatible = 'Upgrade your browser: Bibliocloud does not support Firefox version\'s '+version if version.to_i < 19
    elsif result =~ /Opera/
      version = result.split('Version/')[1].split('.').first
      browser_compatible = 'Upgrade your browser: Bibliocloud does not support Opera version\'s '+version if version.to_i < 12
    elsif result =~ /MSIE/
      version = result.split('MSIE')[1].split(' ').first
      browser_compatible = 'Upgrade your browser: Bibliocloud does not support Microsoft Internet Explorer version\'s '+version if version.to_i < 10
    end
    flash.now.alert = browser_compatible
  end



  include ActionView::Helpers::NumberHelper

  require 'builder'

  # Helper method to return the user's current ability

  # Means of setting the current locale
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end



  # Helper method to return the current user and client. Called as a before_filter method in most controllers, except for the Webs one where there is no current_user (it's publically accessible.)
  def current_user_variables
    @client    = Client.find(1)
    @user      = User.find(2)
    if current_user.mode == 'true'
      @toggle = false
    else
      @toggle = true
    end
  end

  def current_user
    User.find(2)

  end

  # Method to instantiate a Presenter in the view. See also a more developed method in the application controller
  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    klass.new(object, view_context)
  end

  protected







end
