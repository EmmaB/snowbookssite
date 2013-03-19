# == Schema Information
#
# Table name: currencies
#
#  id                    :integer          not null, primary key
#  client_id             :integer
#  user_id               :integer
#  exchange_rate_to_base :decimal(, )
#  created_at            :datetime
#  updated_at            :datetime
#  currencycode          :string(255)
#  base_currency         :boolean
#  default_currency      :boolean
#  currency_symbol       :string(255)
#

# -*- encoding : utf-8 -*-
class Currency < ActiveRecord::Base
  include Nextprev
  include Translation
  strip_attributes
  has_paper_trail

  has_many :sales

  attr_accessible :client_id, :user_id, :exchange_rate_to_base, :currencycode, :base_currency, :default_currency, :currency_symbol
  validates :currencycode, :presence => true, :uniqueness => { :scope => :client_id, :case_sensitive => false  }

  after_save :set_base_currency
  after_save :check_at_least_one_true

  def set_base_currency
    unless self.base_currency==false
      falsify_all_others
    end
  end

  def falsify_all_others
      Currency.where('id != ? and client_id = ?', self.id, self.client_id).update_all(:base_currency => false)
  end

  def check_at_least_one_true
     if self.base_currency == false
       unless Currency.where('id != ? and base_currency = ? and client_id = ?', self.id, "t", self.client_id).first
        self.update_attributes(:base_currency => true)
        errors.add(:base_currency, "Must be at least one base currency" )
       end
     end
   end

  def self.dropdown(current_user)
    Currency.where(:client_id => current_user.client_id).order('currencycode ASC').all
  end

  def self.default(client_id)
    Currency.find_by_client_id_and_default_currency(client_id, true)
  end

  def self.get_by_original_currency(original_currency_id)
    Currency.find(original_currency_id).currencycode
  end
  
  def to_s
    "Base currency is #{currencycode} ( #{currency_symbol})"
  end
  
end




