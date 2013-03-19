# -*- encoding : utf-8 -*-
class CommentsController < ClienttemplatesController

  skip_before_filter :set_ariane_home
  skip_before_filter :set_ariane
  skip_authorization_check :only => [:show, :new, :update, :create, :index]
  skip_before_filter :authenticate_user!, :only => [:show, :new, :update, :create, :index]
  skip_before_filter :current_user_variables, :only => [:show, :new, :update, :create, :index]

  layout 'web', :only => [:show, :new, :update, :create, :index]

  respond_to :html, :csv, :xml

  def index
    @post = Post.find(params[:post_id])

    @comments = @post.comments
  end

  def edit
    singular_action(__method__)
  end

  def new
    new_action(__method__)
  end

  def create
     @post = Post.find(params[:post_id])
     @comment = @post.comments.create(params[:comment])
     if @comment.save
       redirect_to(:back, :notice => "Comment saved.")
     else
       redirect_to(:back, :notice => "Comment not saved: please try again.")
     end
   end

     def update
    @comment           = Comment.new(params[:comment])

  end

  def destroy
      @comment = Comment.find(params[:id])
      @comment.destroy

      respond_to do |format|
        format.html { redirect_to :back }
        format.xml { head :ok }
      end

  end

end



