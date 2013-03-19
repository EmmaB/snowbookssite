# -*- encoding : utf-8 -*-
class PostsController < ClienttemplatesController


  layout 'web'

  respond_to :html, :csv, :xml

  def index
    @client = Client.find(1)

    @q = Post.where(:status => "Publish").where(:client_id => @client.id).text_search(params[:query]).search(params[:q])
    @posts = @q.result(:distinct => true).order('created_at DESC').paginate(:page => params[:page])
    respond_with(@posts)
    session[:query] = @posts.map(&:id)

    @posts            = Post.where(:client_id  => @client.id).where(:status => "Publish")
    @posts_summary    = Post.select("id,title,created_at").where(:client_id => @client.id).where(:status => "Publish")
    @post_months      = Post.monthly_archives(@posts_summary)
  end

  def show
    @client = Client.find(1)
    @post             = Post.where(:status => "Publish").find(params[:id])
    @posts            = Post.where(:client_id  => @client.id).where(:status => "Publish")
    @posts_summary    = Post.select("id,title,created_at").where(:client_id => @client.id).where(:status => "Publish")
    @post_months      = Post.monthly_archives(@posts_summary)
  end


end



