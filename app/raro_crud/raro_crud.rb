class RaroCrud
  @@order_field       = {}
  @@per_page          = {}
  @@index_fields      = {}
  @@form_fields       = {}
  @@view_fields       = {}
  @@search_fields     = {}
  @@test_fields       = {}
  @@top_links         = {} 
  @@title             = {}
  @@subtitle_index    = {}
  @@description_index = {}
  @@actions           = {}
  @@edit_action       = {}
  @@destroy_action    = {}
  @@view_action       = {}
  @@options_link      = {}
  @@scopes            = {}
  @@menus             = []
  @@index_path        = nil

  def self.edit_action
    if @@edit_action[self.to_s.to_sym] == false
      return false
    else
      return true
    end
  end
  
  def self.destroy_action
    if @@destroy_action[self.to_s.to_sym] == false
      return false
    else
      return true
    end
  end

  def self.view_action
    if @@view_action[self.to_s.to_sym] == false
      return false
    else
      return true
    end
  end

  def self.root_path
    "/crud/#{self.to_s.gsub('Crud', '').underscore}"
  end

  def self.index_path str
    @@index_path = str
  end
  
  def self.get_index_path
    @@index_path
  end

  def self.title
    @@title[self.to_s.to_sym]
  end

  def self.subtitle(type)
    case type
    when :index
      @@subtitle_index[self.to_s.to_sym]
    end
  end

  def self.description(type)
    case type
    when :index
      @@description_index[self.to_s.to_sym]
    end
  end

  def self.top_links 
    (@@top_links[self.to_s.to_sym]) ? @@top_links[self.to_s.to_sym] : []
  end

  def self.index_fields
    (@@index_fields[self.to_s.to_sym]) ? @@index_fields[self.to_s.to_sym] : []
  end

  def self.order_field
    (@@order_field[self.to_s.to_sym]).present? ? @@order_field[self.to_s.to_sym] : "id"
  end
  
  def self.per_page
    @@per_page[self.to_s.to_sym]
  end

  def self.actions
    (@@actions[self.to_s.to_sym]) ? @@actions[self.to_s.to_sym] : []
  end

  def self.options_link
    (@@options_link[self.to_s.to_sym]) ? @@options_link[self.to_s.to_sym] : []
  end

  def self.form_fields
    (@@form_fields[self.to_s.to_sym]) ? @@form_fields[self.to_s.to_sym]  : []
  end

  def self.view_fields
    (@@view_fields[self.to_s.to_sym]) ? @@view_fields[self.to_s.to_sym]  : []
  end

  def self.search_fields
    (@@search_fields[self.to_s.to_sym]) ? @@search_fields[self.to_s.to_sym]  : []
  end

  def self.test_fields
    (@@test_fields[self.to_s.to_sym]) ? @@test_fields[self.to_s.to_sym]  : []
  end
  
  def self.scopes
    (@@scopes[self.to_s.to_sym]) ? @@scopes[self.to_s.to_sym]  : []
  end

  def self.add_menus(menu)
    @@menus << menu
  end

  def self.menus
    @@menus
  end
  
  
  private

  def self.titulo str
    @@title[self.to_s.to_sym] = str
  end

  def self.subtitulo(str,type)
    case type
    when :index
      @@subtitle_index[self.to_s.to_sym] = str
    end
  end

  def self.descricao(str,type)
    case type
    when :index
      @@description_index[self.to_s.to_sym] = str
    end
  end

  def self.link_superior nome, opts
      @@top_links[self.to_s.to_sym] = [] unless @@top_links[self.to_s.to_sym]
      @@top_links[self.to_s.to_sym].push(
          {
            text: nome,
            id:   opts[:id],
            data: {push: 'partial', target: '#form'},
            icon: "fa fa-#{opts[:icon]}",
            class: 'btn btn-small btn-primary btn-rounded',
            link: "#{self.root_path}/#{opts[:link]}"
          }
    )
  end 
  
  def self.campo_tabela nome, opts
    @@index_fields[self.to_s.to_sym] = [] unless @@index_fields[self.to_s.to_sym]
    @@index_fields[self.to_s.to_sym].push(
      {
        attribute: nome
      }.merge(opts)
    )
  end
  
  def self.ordenar_por nome
    @@order_field[self.to_s.to_sym] = nome
  end
  
  def self.itens_por_pagina qtd
    @@per_page[self.to_s.to_sym] = qtd
  end
  
  def self.campo_teste nome, opts
    @@test_fields[self.to_s.to_sym] = [] unless @@test_fields[self.to_s.to_sym]
    @@test_fields[self.to_s.to_sym].push(
      {
        attribute: nome
      }.merge({sf: opts})
    )
  end   
  
  def self.campo_formulario nome, opts
    @@form_fields[self.to_s.to_sym] = [] unless @@form_fields[self.to_s.to_sym]
    @@form_fields[self.to_s.to_sym].push(
      {
        attribute: nome
      }.merge({sf: opts})
    )
  end    

  def self.campo_visualizacao nome, opts = nil
    @@view_fields[self.to_s.to_sym] = [] unless @@view_fields[self.to_s.to_sym]
    @@view_fields[self.to_s.to_sym].push(
      {
        attribute: nome
      }.merge({sf: opts})
    )
  end    

  def self.campo_busca nome, opts = nil
    @@search_fields[self.to_s.to_sym] = [] unless @@search_fields[self.to_s.to_sym]
    @@search_fields[self.to_s.to_sym].push(
      {
        attribute: nome
      }.merge({sf: opts})
    )
  end    
  
  def self.sem_visualizacao
    @@view_action[self.to_s.to_sym] = false
  end

  def self.sem_edicao
    @@edit_action[self.to_s.to_sym] = false
  end

  def self.sem_exclusao
    @@destroy_action[self.to_s.to_sym] = false
  end
  
  def self.acoes(method,desc,proc = nil)
    @@actions[self.to_s.to_sym] = [] unless @@actions[self.to_s.to_sym]
    @@actions[self.to_s.to_sym].push([method,desc,proc])
  end
  
  def self.opcoes(link,desc,proc = nil)
    @@options_link[self.to_s.to_sym] = [] unless @@options_link[self.to_s.to_sym]
    @@options_link[self.to_s.to_sym].push([link,desc,proc])
  end
  
  def self.escopos(scopes)
    @@scopes[self.to_s.to_sym] = scopes
  end

end