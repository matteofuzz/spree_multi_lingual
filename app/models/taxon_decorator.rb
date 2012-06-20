module Spree
  Taxon.class_eval do
    translates :name, :description, :permalink    
    
    # No blank translation !
    before_save :create_default_transalations

    # Public : Permalink setter with multi language support
    #
    # string - The permalink part of the taxon
    #
    # Set the full permalink accordingly from the argument permalink
    #
    # Returns nothing
    (SpreeMultiLingual.languages + [""]).each do |locale|
      locale_suffix = locale.empty? ? "" : "_#{locale}"
      define_method("permalink#{locale_suffix}=") do |permalink_part|
        opts = locale.empty? ? {} : { :locale => locale.to_sym }
        unless new_record?
          _permalink = (read_attribute(:permalink, opts) || []).split("/")[0...-1]
          permalink_part = (_permalink << permalink_part).join("/")
        end
        write_attribute(:permalink, permalink_part, opts)
      end
    end

    # Creates permalink based on Stringex's .to_url method
    def set_permalink
      if parent_id.nil?
        self.permalink = name.to_url if self.permalink.blank?
      else
        parent_taxon = Taxon.find(parent_id)
        parent_taxon.translations_for(:permalink).each do |attribute|
          parent_permalink, locale = attribute[:permalink], attribute[:locale]
          permalink_locale = read_attribute(:permalink, :locale => locale)
          write_attribute(:permalink, [parent_permalink, (permalink_locale.blank? ? name.to_url : permalink_locale.split('/').last)].join('/'), :locale => locale)
        end
        write_attribute :permalink, [parent_taxon.permalink, (self.permalink.blank? ? name.to_url : self.permalink.split('/').last)].join('/')
      end
    end


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
end