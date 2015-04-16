class CrudController < ApplicationController
  before_filter :setup

  def index
    if params[:scope].present?
      @q = @model.send(params[:scope]).search(params[:q])
    else
      @q = @model.search(params[:q])
    end
    if @q.sorts.empty?
      if "#{@crud_helper.order_field}".include?("desc") or "#{@crud_helper.order_field}".include?("asc")
        @q.sorts = "#{@crud_helper.order_field}"
      else
        @q.sorts = "#{@crud_helper.order_field} asc"
      end
    end
    if respond_to?(:current_usuario)
      @records = @q.result(distinct: true).accessible_by(current_ability).page(params[:page]).per(@crud_helper.per_page)
    else
      @records = @q.result(distinct: true).page(params[:page]).per(@crud_helper.per_page)
    end
    @titulo = @model.name.pluralize
    render partial: 'records' if request.respond_to?(:wiselinks_partial?) && request.wiselinks_partial?
  end

  def setup
    @model = Module.const_get(params[:model].camelize)
    @crud_helper = Module.const_get("#{params[:model]}_crud".camelize)
    authorize! :read, @model if respond_to?(:current_usuario)
  end
  
  def new
    @record = @model.new
  end
  
  def edit
    @record = @model.find(params[:id])
  end

  def show
    @record = @model.find(params[:id])
  end

  def action
    @record = @model.find(params[:id])
    if @model.method_defined?(params[:acao])
      if @record.send(params[:acao])
        flash.now[:success] = "Ação #{params[:acao]} efetuada com sucesso."
      else
        flash.now[:error] = "Erro ao tentar executar a ação #{params[:acao]}."
      end
      index
    else
      @titulo = @record.to_s
      @texto = params[:acao]
      render "/papeis/#{params[:acao]}"
    end
  end
  
  def create
    saved = false
    
    if params[:id]
      @record = @model.find(params[:id])
      saved = @record.update(params_permitt)
    else
      @record  =  @model.new(params_permitt)
      saved = @record.save
    end
    
    respond_to do |format|
      if saved
        flash[:success] = params[:id].present? ? "Cadastro alterado com sucesso." : "Cadastro efetuado com sucesso."
        format.html { redirect_to "/crud/#{@model.name.underscore}" }
        format.js { render action: :index }
      else
        action = (params[:id]) ? :edit : :new
        format.html { render action: action }
        format.js { render action: action }
      end
    end
  end
  
  def destroy
    @record = @model.find(params[:id])
    @record.destroy
    respond_to do |format|
      flash[:success] = "Cadastro removido com sucesso."
      format.html { redirect_to "/crud/#{@model.name.underscore}" }
      format.js { render action: :index }
    end
  end
  
  def query
    @resource = Module.const_get(params[:model].classify)
    @q = @resource.search(params[:q])
    @q.sorts = 'updated_at desc' if @q.sorts.empty?
    if respond_to?(:current_usuario)
      results = @q.result(distinct: true).accessible_by(current_ability).page(params[:page])
    else
      results = @q.result(distinct: true).page(params[:page])
    end
    instance_variable_set("@#{params[:var]}", results)
    if request.respond_to?(:wiselinks_partial?) && request.wiselinks_partial?
      render :partial => params[:partial]
    else
      if request[:controller] == "crud"
        redirect_to "/#{request[:controller]}/#{params[:model]}"
      else
        redirect_to "/#{request[:controller]}"
      end
    end
  end

  private
  def params_permitt 
    params.require(@model.name.underscore.to_sym).permit(fields_model)
  end
  
  def fields_model
    fields = []
    @crud_helper.form_fields.each do |field|
      if @model.reflect_on_association(field[:attribute])
        if @model.reflect_on_association(field[:attribute]).macro == :belongs_to
          fields << "#{field[:attribute]}_id".to_sym
        else
          fields << {"#{field[:attribute].to_s.singularize}_ids".to_sym => []}
        end
      else
        fields << field[:attribute]
      end
    end
    fields
  end
end