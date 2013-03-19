# -*- encoding : utf-8 -*-
module ApplicationHelper
  include GoogleVisualization
  include ActsAsTaggableOn::TagsHelper

  include GoogleVisualization

  # Method to instantiate a Presenter in the view
  def present(object, klass = nil)
    # Determine the class based on the object psased in
    klass ||= "#{object.class}Presenter".constantize
    # Instantiate presenter by passing in klass and self
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end

  # Returns a title variable, which is used on most views to provide a title for the page.
  def title
    base_title = "Bibliocloud"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end

  def facebook_like
    content_tag :iframe, nil, :src => "https://www.facebook.com/plugins/like.php?href=#{CGI::escape(request.url)}&layout=standard&show_faces=true&width=450&action=like&font=arial&colorscheme=light&height=80", :scrolling => 'no', :frameborder => '0', :allowtransparency => true, :id => :facebook_like
  end

  def facebook_like_from_index(post)
    content_tag :iframe, nil, :src => "https://www.facebook.com/plugins/like.php?href=https://#{current_company_name}.bibliocloud.com/posts/#{post.id}&layout=standard&show_faces=true&width=450&action=like&font=arial&colorscheme=light&height=80", :scrolling => 'no', :frameborder => '0', :allowtransparency => true, :id => :facebook_like
  end

  # Returns the client id of the client whose name is the current subdomain
  def current_subdomain
    if request.subdomains.first
      Client.find_by_webname(request.subdomains.first).id if Client.find_by_webname(request.subdomains.first)
    end
  end

  # Returns the record of the company based on the current subdomain e.g. Snowbooks, in snowbooks.bibliocloud.com
  def current_company
    Company.find(1)
  end

  # Returns the current subdomain name of the company based on the current subdomain e.g. Snowbooks, in snowbooks.bibliocloud.com
  def current_company_name
    begin
    Client.find(current_subdomain).webname
  rescue
    ""
  end
  end

  # Returns the default currency for the subdomain company
  def current_company_curr
    Currency.where('client_id = ? and default_currency = ?', current_subdomain, "t").first.try(:currency_symbol)
  end

  # Returns the company record to which the current user belongs.
  def user_company_root
    Company.find_by_client_id(current_user.client_id) unless Company.find_by_client_id(current_user.client_id).nil?
  end

  # Returns the name of the company to which the current user belongs.
  def user_company
    if Client.find_by_id(current_user.client_id)
      Client.find_by_id(current_user.client_id).client_name
    end
  end

  # Returns the symbol of the default currency of the current user's company.
  def curr
      Currency.where('client_id = ? and default_currency = ?', current_user.client_id, "t").first.try(:currency_symbol)
  end

  # Returns the current period for the current user's company.
  def current_period_and_client
    Period.where(["currentperiod = ? and client_id = ?", "t", current_user.client_id]).first
  end

  def controller?(*controller)
    controller.include?(params[:controller])
  end

  # Returns the URL where we keep static images on S3.
  def static_root
    "https://s3-eu-west-1.amazonaws.com/bibliocloudimages/static"
  end

  # Toggles heLp mode
  def help_mode
    if current_user.mode == 'true'
      @toggle = false
    else
      @toggle = true
    end
    true if current_user.mode == 'true'
  end



end





