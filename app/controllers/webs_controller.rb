# -*- encoding : utf-8 -*-
require 'will_paginate/array'
# don't http stream with all this caching as it throws occasional chunked encoding errors and puts junk characters at the front and end of the cached file.
class WebsController < ApplicationController
  # Rack::MiniProfiler.authorize_request
  include UrlHelper

#  caches_page :home, :blog, :contact, :rights, :submissions, :about


  # caches_action     :alphabetical , :cache_path => Proc.new { |c| c.params }, :expires_in => 1.year
  #   caches_action     :index        , :cache_path => Proc.new { |c| c.params }, :expires_in => 1.year
  #   caches_action     :single_cat   , :cache_path => Proc.new { |c| c.params }, :expires_in => 1.year
  #   caches_action     :author_index , :cache_path => Proc.new { |c| c.params }, :expires_in => 1.year
  #   caches_action     :home         , :cache_path => Proc.new { |c| c.params }, :expires_in => 1.year
  #   caches_action     :show         , :cache_path => Proc.new { |c| c.params }, :expires_in => 1.year
  #   caches_action     :author_show  , :cache_path => Proc.new { |c| c.params }, :expires_in => 1.year
  #   caches_action     :blog         , :cache_path => Proc.new { |c| c.params }, :expires_in => 1.year
  #   caches_action     :rights       , :cache_path => Proc.new { |c| c.params }, :expires_in => 1.year

  layout "web"

  def index
    @webs = Book.get_website_books(@client).text_search(params[:query])
    @feature_root = Web.multiple_summary_details_by_category( @webs )
    @features = @feature_root.to_a.paginate(:page => params[:page], :per_page => 4)
  end

  def alphabetical
    @webs = Book.get_website_books(@client).text_search(params[:query])
    @summaries = Web.multiple_summary_details(@webs)
  end

  def single_cat
    @webs = Book.get_website_books(@client)
    @feature_root = Web.multiple_summary_details_by_category( @webs )
    @cat_name = params[:cat]
    @single_cat = @feature_root[@cat_name]
  end

  def home
    @webs = Book.find_all_by_highlight_on_web_and_client_id(true, Client.find(1).id )
    # @features = Web.multiple_summary_details( highlighted_isbns )
    @features = Web.multiple_summary_details_by_category( @webs ).to_a.paginate(:page => params[:page], :per_page => 4)
  end

  # GET /webs/1
  # GET /webs/1.xml
  def show
    begin
    @web    = Web.find(params[:id])
    rescue
      redirect_to webs_path
      return
    end
    @cover  = Supportingresource.front_cover_original(@web.book, :small)[:url]
    titles = Web.get_related_titles(@web.book)
    @relateds = Web.multiple_summary_details(titles)
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @web }
    end
  end

  def about
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @web }
    end
  end

  def author_index
    # fetch the Webs for the current account
    webs = @client.webs.text_search(params[:query])
    # look up the Books for those Webs
    web_books = webs.map(&:book)

    contacts = []
    # add all the contacts for these books into a new array
    web_books.each { |book| contacts << book.contacts }
    # flatten, remove duplicates and sort by contact surname, then copy into new array
      # sorted_contacts = contacts.flatten.uniq.sort_by {|c| c.keynames.downcase unless c.keynames.blank? }
      sorted_contacts = contacts.flatten.uniq.sort_by {|child| [child.keynames ? 0 : 1, child.keynames || 0]}


      # paginate the list of contacts
      @contribs = sorted_contacts.to_a.paginate(:page => params[:page], :per_page => 5)
      @summaries_by_contrib = {}
      # using this subsection of contacts...
      @contribs.each do |contrib|
        # fetch each contacts books
        all_contribs_books = contrib.books
        # then weed out the non-web enabled ones by comparing to our previous array of books
        contribs_web_books = all_contribs_books.reject {|element| not web_books.include? element }
        # then fetch all the displayable info for those books and store under the contact's id in a hash
        @summaries_by_contrib[contrib.id] = Web.multiple_summary_details(contribs_web_books)
    end
    respond_to do |format|
      format.html # show.html.erb
    end
  end


  def author_show
    @contact = Contact.find(params[:id])
    books = @contact.books.where(:include_on_web => true)
    @features = Web.multiple_summary_details(books)
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @web }
    end
  end


  # GET /webs/new
  # GET /webs/new.xml
  def new
    if user_signed_in?
      @web = Web.new

      respond_to do |format|
        format.html # new.html.erb
        format.xml { render :xml => @web }
      end
    else
      redirect_to(root_path, :alert => "Why did you try that? Your IP #{request.env['REMOTE_HOST']} has been logged. Now go away.")
      Rails.logger.request.env['REMOTE_HOST']
    end
  end

  # GET /webs/1/edit
  def edit
    if user_signed_in?
      @web = Web.find(params[:id])
    else
      redirect_to(root_path, :alert => "Why did you try that? Your IP #{request.env['REMOTE_HOST']} has been logged. Now go away.")
      Rails.logger.request.env['REMOTE_HOST']
    end
  end

  # POST /webs
  # POST /webs.xml
  def create
    if user_signed_in?
      @web           = Web.new(params[:web])
      @web.client_id = current_user.client_id
      respond_to do |format|
        if @web.save
          format.html { redirect_to([:edit, @web], :notice => 'Web was successfully created.', :only_path => true) }
          format.xml { render :xml => @web, :status => :created, :location => @web }
        else
          format.html { render :action => "new" }
          format.xml { render :xml => @web.errors, :status => :unprocessable_entity }
        end
      end
    else
      redirect_to(root_path, :alert => "Why did you try that? Your IP #{request.env['REMOTE_HOST']} has been logged. Now go away.")
      Rails.logger.request.env['REMOTE_HOST']
    end
  end

  # PUT /webs/1
  # PUT /webs/1.xml
  def update

    if user_signed_in?
      @web = Web.find(params[:id])
      respond_to do |format|
        if @web.update_attributes(params[:web])
          format.html { redirect_to([:edit, @web], :notice => 'Web was successfully updated.', :only_path => true) }
          format.xml { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml { render :xml => @web.errors, :status => :unprocessable_entity }
        end
      end
    else
      redirect_to(root_path, :alert => 'Why did you try that? Go away.')
    end
  end

  def blog
    puts "in blog action"
    @posts         = Post.where(:client_id  => @client.id).where(:status => "Publish")
#    @posts_summary = Post.select("id,title,created_at").where(:client_id  => @client).where(:status => "Publish")
     @posts_summary = Post.select("id,title,created_at").where("client_id = ? and status = ?",@client,"Publish")
    @post_months   = Post.monthly_archives(@posts_summary)
  end

  # DELETE /webs/1
  # DELETE /webs/1.xml
  def destroy
    if user_signed_in?
      @web = Web.find(params[:id])
      @web.destroy

      respond_to do |format|
        format.html { redirect_to(webs_url) }
        format.xml { head :ok }
      end
    else
      redirect_to(root_path, :alert => 'Why did you try that? Go away.')
    end
  end


def set_variables
  @client = Client.find(1)
  @company_name = Company.find_by_client_id(@client).try(:sender_name)
end


end
