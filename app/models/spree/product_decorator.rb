Spree::Product.class_eval do
  translates :name, :description, :meta_description, :meta_keywords, :permalink     
  
  before_save :create_default_transalations
      
  
  private
  
  def create_default_transalations 
    I18n.available_locales.each do |locale|
      name_locale = self.send("name_#{locale.to_s}")
      permalink_locale = self.send("permalink_#{locale.to_s}") 
      self.update_attribute("name_#{locale.to_s}", name) if name_locale.blank?
      self.update_attribute("permalink_#{locale.to_s}", permalink) if permalink_locale.blank?
    end 
  end
end