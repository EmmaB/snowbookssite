# -*- encoding : utf-8 -*-
class ClienttemplatesController < ApplicationController
  # Boilerplate controllers for models where data is unique to a client inherit this template.

  # Gets the controller's name
  def class_name
    self.class.to_s.gsub( %r{^\w*::(\w*)Controller} ) {|s| $1 }
  end

  # Defines the name of an instance variable
  def model_var
    "@#{class_name.underscore.singularize.downcase}"
  end

  # Sets a variable which we can call to_sym on
  def var
    class_name.underscore.singularize.downcase
  end

  # Gets the instance variable
  def inst_var_get
    # e.g. Work.instance_variable_get(@work)
    # which results in @work
    self.instance_variable_get(model_var)
  end

  # Gets the instance variable for the index action, which is plural
  # Defines @books
  #
  def inst_var_plural_get
    self.instance_variable_get("@#{class_name.underscore.downcase}")
  end

  # Sets the instance variable
  def inst_var_set
    self.instance_variable_set(model_var, by_client.find(params[:id]))
  end

  # Gets the model name
  def model
    class_name.singularize.constantize
  end

  # Limits the model query to data owned by the current user's client
  def by_client
    model.where(:client_id => current_user.client_id)
  end

  # This is the index action
  def plural_action(method_name)
    @title = "#{method_name.to_s.titlecase} of #{class_name}"
    @q = by_client.search(params[:q])
    #e.g. the following line could render as @works = @q.result(:distinct => true).paginate(:page => params[:page]))
    self.instance_variable_set("@#{class_name.underscore.downcase}", @q.result(:distinct => true).order('created_at DESC').paginate(:page => params[:page]))
    # e.g. could render as respond_with @works
    respond_with(inst_var_plural_get)
    # used for the prev and next functionality. See singular_action below, and also app/concerns/nextprev.rb
    session[:query] = inst_var_plural_get.map(&:id)
  end

  # This is the show and edit action
  def singular_action(method_name)
    @title = "#{method_name.to_s.titlecase} #{class_name.singularize.to_s}"
    inst_var_set
    if session[:query]
      @next = inst_var_get.next(session[:query])
      @prev = inst_var_get.previous(session[:query])
    end
    respond_with(inst_var_get)
  end

  def new_action(method_name)
    ariane.add "Add new #{var}"
    self.instance_variable_set(model_var, model.new)
    respond_with(inst_var_get)
  end

  def create_action(method_name)
    self.instance_variable_set(model_var, model.new(params[var.to_sym]))
    inst_var_get.client_id = @client
    inst_var_get.user_id = @user
    if inst_var_get.save
      flash[:success] = t(:"#{var}_create").html_safe
      redirect_to [:edit, inst_var_get]
    else
      flash[:failure] = t(:"#{var}_failure").html_safe
      render :action => "new"
    end
  end

  def destroy_action(method_name)
    self.instance_variable_set(model_var, by_client.find(params[:id]))
    inst_var_get.destroy
    flash[:success] = t(:"#{var}_destroy").html_safe
    respond_with(inst_var_get)
  end

  def update_action(method_name)
    inst_var_set
    inst_var_get.user_id = @user
    if inst_var_get.update_attributes(params[:"#{var}"]) then flash[:success] = t(:"#{var}_update").html_safe else flash[:failure] = t(:"#{var}_failure").html_safe end
      render :action => 'edit'
  end


end
