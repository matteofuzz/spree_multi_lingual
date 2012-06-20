module Spree
  Taxonomy.class_eval do
    translates :name   
    
    before_save :create_default_transalations     

    private
    def set_name
      if self.root
        self.root.update_attributes(attrs_translations_for(:name))
      else
        self.root = Taxon.create!({ :taxonomy_id => self.id, :name => self.name })
      end
    end 

    def create_default_transalations 
      I18n.available_locales.each do |locale|
        name_locale = self.send("name_#{locale.to_s}")      
        self.update_attribute("name_#{locale.to_s}", name) if name_locale.blank?      
      end 
    end
    
  end
end