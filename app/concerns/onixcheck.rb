module Onixcheck
  
    def onix_valid
      if  self.work.try(:main_bisac_code).try(:blank?)        or 
          self.work.try(:main_bic_code).try(:blank?)          or
          self.title.blank?                       or
          self.extents.empty?                     or
          self.imprint.blank?                     or
          self.publisher_role.blank?              or
          self.publisher.blank?                   or
          self.publication_city.blank?            or
          self.publication_country.blank?         or
          self.publishing_status.blank?           or
          self.pub_date.blank?                    or
          self.format_detail_id.blank?            or
          self.audiences.empty?                   or
          self.marketingtexts.empty?              or
          self.supportingresources.empty?         or
          self.rights.empty?                      or
          self.measurements.empty?                or
          self.supplies.empty?                    or
          self.notification.blank?       
        false
      elsif test_contacts               == false        or 
            test_extents                == false        or
            test_marketingtexts         == false        or
            test_supportingresources    == false        or
            test_rights                 == false        or
            test_measurements           == false        or
            test_identifiers            == false        or
            test_supplies               == false          
        false
      else
        update_column(:valid_onix, 'true')
        true
      end
    end

    
    def test_contacts
      validity = []
      self.workcontacts.each do |workcontact|
         validity << false if self.contributor_statement.blank? and Contact.find(workcontact.contact_id).try(:biographical_note).blank?
         validity << false if workcontact.contact_id.blank?
         validity << false if workcontact.work_contact_role.blank?
      end
      false if validity.include? false
    end

    def test_extents
      validity = []
      self.extents.each do |extent|
         validity << false if extent.extent_type_id.blank?
         validity << false if extent.extent_unit_id.blank?
         validity << false if extent.extent_value.blank?        
      end
      false if validity.include? false
    end

    def test_marketingtexts
      validity = []
      self.marketingtexts.each do |marketingtext|
         validity << false if marketingtext.legacy_code.blank?
         validity << false if marketingtext.marketing_text.blank?
      end
      false if validity.include? false
    end

    def test_supportingresources
      validity = []
      self.supportingresources.each do |supportingresource|
        validity << false if supportingresource.resource_content_type.blank?
      end
      false if validity.include? false
    end
    
    def test_identifiers
      validity = []
      self.productcodes.each do |identifier|
        validity << false if identifier.idvalue.blank?
        validity << false if identifier.idtype.blank?
      end
      false if validity.include? false
    end
    
    def test_rights
      validity = []
      self.rights.each do |right|       
         validity << false if right.sales_rights_type.blank?
         

      list = []
       if Rightlist.find_by_id(right.countries_included.to_i)
         Rightlist.find_by_id(right.countries_included.to_i).country_codes.each do |code|
           list << "#{code.name}"  
         end
       end
       if Rightlist.find_by_id(right.countries_excluded.to_i)
         Rightlist.find_by_id(right.countries_excluded.to_i).country_codes.each do |code|
           list << "#{code.name}"  
         end
       end
       if Rightlist.find_by_id(right.regions_included.to_i)
         Rightlist.find_by_id(right.regions_included.to_i).region_codes.each do |code|
           list << "#{code.name}"  
         end
       end
       if Rightlist.find_by_id(right.regions_included.to_i)
         Rightlist.find_by_id(right.regions_included.to_i).region_codes.each do |code|
           list << "#{code.name}"  
         end
       end
       
         list.join(" ")         
         validity << false if list.join(" ").empty?
         
         
         validity << false if right.regions_included.blank? and right.regions_excluded.blank? and right.countries_included.blank? and right.countries_excluded.blank?

      end
      false if validity.include? false
    end
    
    def test_measurements
      validity = []
      self.measurements.each do |measurement|
         validity << false if measurement.measurement_type_id.blank?
         validity << false if measurement.measurement.blank?
         validity << false if measurement.measurement_unit_id.blank?
      end
      false if validity.include? false
    end
    
    def test_supplies
      validity = []
      self.supplies.each do |supply|
        validity << false if self.supplydetails.empty?
        validity << false if supply.countries_included.blank? and supply.regions_included.blank? 
        self.supplydetails.each do |supplydetail|
           validity << false if supplydetail.supplier_name.blank?
           validity << false if supplydetail.product_availability.blank?
          validity << false if self.prices.empty?
          self.prices.each do |price|
             validity << false if price.price_type.blank?
             validity << false if price.discount_code.blank?
             validity << false if price.price_amount.blank?
             validity << false if price.currency_code.blank?
             validity << false if price.tax_rate_code.blank?
             validity << false if price.taxable_amount.blank?
          end 
        end             
      end
      false if validity.include? false
    end

  
  
  
  def update_from_default(default)
      self.work.update_attributes(:main_bisac_code => default.bisac )                     if self.work.main_bisac_code.blank? 
      self.work.update_attributes(:main_bic_code => default.bic )                         if self.work.main_bic_code.blank? 
      self.update_attributes(:publication_city  => default.city )                         if self.publication_city.blank?       
      self.update_attributes(:publication_country  => default.country )                         if self.publication_country.blank?       

      self.update_attributes( :imprint => default.imprint )                               if self.imprint.blank?
      self.update_attributes( :pub_date => default.pub_date )                             if self.pub_date.blank?
      self.update_attributes( :publisher => default.publisher )                           if self.publisher.blank?
      self.update_attributes( :publisher_role => default.publisher_role )                 if self.publisher_role.blank?
      self.update_attributes( :publishing_status => default.publishing_status )           if self.publishing_status.blank?
      self.update_attributes( :notification => default.notification )                     if self.notification.blank?
      self.update_attributes( :format_detail_id => default.format_detail )                if self.format_detail_id.blank?      
      if  self.work.workcontacts.first     
      self.work.workcontacts.first.update_attributes(:work_contact_role => default.contributor_role )  if  work.workcontacts.first.work_contact_role.blank?
    end
      unless self.supplies.empty?
        self.supplies.each do |supply|
          unless self.supplydetails.first 
            supply.supplydetails.each do |sup_detail|
              puts "sup_detail is #{sup_detail.inspect}"
              self.update_attributes(sup_detail.product_availability => default.product_availability) if sup_detail.product_availability.blank? 
              self.update_attributes(sup_detail.supplier_name => default.supplier_name ) if sup_detail.supplier_name.blank?
              sup_detail.prices.each do |price|
                price.update_attributes( :currency_code => default.currency_code) if price.currency_code.blank?
                price.update_attributes( :discount_code => default.discount_type) if price.discount_code.blank?
                price.update_attributes( :price_amount => default.price_amount) if price.price_amount.blank?
                price.update_attributes( :price_type => default.price_type)  if price.price_type.blank?
                price.update_attributes( :tax_value => default.tax_amount)  if price.tax_value.blank?
                price.update_attributes( :tax_rate_code => default.tax_rate) if price.tax_rate_code.blank?
                price.update_attributes( :taxable_amount => default.taxable_amount) if price.taxable_amount.blank?
              end
            end
          end
        end
      else
        supply        = Supply.create(:book_id => self.id )
        supply_detail = Supplydetail.create( :supply_id => supply.id, :product_availability => default.product_availability, :supplier_name => default.supplier_name )
        Price.create!(:book_id => self.id, :supplydetail_id => supply_detail.id, :currency_code => default.currency_code,  :discount_code => default.discount_type, :price_amount => default.price_amount,:price_type => default.price_type, :tax_value => default.tax_amount , :tax_rate_code => default.tax_rate, :taxable_amount => default.taxable_amount)
      end    
      
      if self.prices.empty?
        puts "prices empty"
        Price.create(:book_id => self.id, :supplydetail_id => self.supplydetails.first.id, :currency_code => default.currency_code,  :discount_code => default.discount_type, :price_amount => default.price_amount,:price_type => default.price_type, :tax_value => default.tax_amount , :tax_rate_code => default.tax_rate, :taxable_amount => default.taxable_amount)
      
      end
      
     unless self.extents.empty?
        self.extents.each do |extent|
          extent.update_attributes( :extent_type_id => default.extent_type ) if extent.extent_type_id.blank?
          extent.update_attributes( :extent_unit_id => default.extent_unit )  if extent.extent_unit_id.blank?
          extent.update_attributes( :extent_value => default.extent_value ) if extent.extent_value.blank?
        end
      else
        Extent.create(:book_id => self.id, :extent_type_id => default.extent_type , :extent_unit_id => default.extent_unit, :extent_value => default.extent_value)
      end  
      
      if self.audiences.empty?  
        audience = Audience.create(:work_id => self.work.id, :audience_code_value => default.audience) 
        Bookaudience.create(:audience_id => audience.id, :book_id => self.id)
      end
      
      self.marketingtexts.each do |marketing_text|
        marketing_text.update_attributes( :legacy_code  => default.marketing_text_code) if marketing_text.legacy_code.blank?
      end  
      
      unless self.measurements.empty?
        self.measurements.each do |measurement|
          if measurement.measurement_type_id == 1
          measurement.update_attributes(:measurement_unit_id => default.height_unit  )  if measurement.measurement_unit_id.blank?        
          measurement.update_attributes(:measurement => default.height_value  )  if measurement.measurement.blank?        
        elsif measurement.measurement_type_id == 2
          measurement.update_attributes(:measurement_unit_id => default.width_unit  )  if measurement.measurement_unit_id.blank?        
          measurement.update_attributes(:measurement => default.width_value  )  if measurement.measurement.blank?
        elsif measurement.measurement_type_id.blank?
          measurement.update_attributes(:measurement_unit_id => default.width_unit  )  if measurement.measurement_unit_id.blank?        
          end
        end        
      else
        Measurement.create(:book_id => self.id, :measurement_type_id => 1, :measurement_unit_id => default.height_unit, :measurement =>  default.height_value )
        Measurement.create(:book_id => self.id, :measurement_type_id => 2, :measurement_unit_id => default.width_unit, :measurement =>  default.width_value )        
      end  
      
      unless self.rights.empty?
        self.rights.each do |right|       
          right.update_attributes( :sales_rights_type => default.sales_rights_type ) if right.sales_rights_type.blank?                     
          right.update_attributes( :regions_included => default.rights_region ) if right.regions_included.blank? and right.regions_excluded.blank? and right.countries_included.blank? and right.countries_excluded.blank? or right.regions_included == "WORLD"       
          
        end
      else
        Right.create(:book_id => self.id, :sales_rights_type => default.sales_rights_type, :regions_included => default.rights_region  )
      end
      
      self.supportingresources.each do |supportingresource|
       supportingresource.update_attributes( :resource_content_type =>  default.supporting_resource_type) if supportingresource.resource_content_type.blank?
      end
      
      true
  end
  


end