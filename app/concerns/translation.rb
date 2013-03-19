# -*- encoding : utf-8 -*-
module Translation

  # looks up the audience code from the I18n codelists.
  # e.g. in a form view, f.object.translated_audience_category
  # Adding in the default means if the lookup fails, there won't be an ugly "translation missing" error message
  def translated_audience_category
      I18n.t(audience_code_value, :scope => [:codelists, :audience_code_value], :default => "") unless audience_code_value.blank?
  end
  
  def translated_bic_code
      I18n.t(main_bic_code, :scope => [:codelists, :bic_code], :default => "") unless main_bic_code.blank?
  end

  def translated_bisac_code
      I18n.t(main_bisac_code, :scope => [:codelists, :bisac_code], :default => "") unless main_bisac_code.blank?
  end

  def translated_currency_code
      I18n.t(currencycode, :scope => [:codelists, :currency_code], :default => "") unless currencycode.blank?
  end

  def translated_base_currency_code
      I18n.t(base_currency, :scope => [:codelists, :base_currency], :default => "") unless base_currency.blank?
  end
  
  def translated_extent_code
      I18n.t(extent_type, :scope => [:codelists, :extent_type], :default => "") unless extent_type.blank?
  end

  def translated_extent_unit
      I18n.t(extent_unit, :scope => [:codelists, :extent_unit], :default => "") unless extent_unit.blank?
  end

  def translated_measure_type
      I18n.t(measure_type, :scope => [:codelists, :measure_type], :default => "") unless measure_type.blank?
  end
  
  def translated_measure_unit
      I18n.t(measure_unit, :scope => [:codelists, :measure_unit], :default => "") unless measure_unit.blank?
  end
  
  def translated_product_availability
      I18n.t(product_availability, :scope => [:codelists, :product_availability], :default => "") unless product_availability.blank?
  end
  
  def translated_format
        I18n.t(format, :scope => [:codelists, :format], :default => "") unless format.blank?
  end

  def translated_publishing_status
      I18n.t(publishing_status, :scope => [:codelists, :publishing_status], :default => "") unless publishing_status.blank?
  end
  
  def translated_language
      I18n.t(language, :scope => [:codelists, :language], :default => "") unless language.blank?
  end
  
  def translated_frequency
      I18n.t(statement_frequency, :scope => [:codelists, :statement_frequency], :default => "") unless statement_frequency.blank?
  end
  def translated_royalty_basis
      I18n.t(royalty_basis, :scope => [:codelists, :basis], :default => "") unless royalty_basis.blank?
  end

  def translated_content_text_type_legacy
      I18n.t(text_type, :scope => [:codelists, :content_text_type_legacy], :default => "") unless text_type.blank?
  end
  
end
