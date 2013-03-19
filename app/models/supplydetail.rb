# == Schema Information
#
# Table name: supplydetails
#
#  id                   :integer          not null, primary key
#  supplier_role        :string(255)
#  supplier_name        :string(255)
#  product_availability :string(255)
#  supply_date_role     :string(255)
#  unpriced_item_type   :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  book_id              :integer
#  supply_id            :integer
#  date                 :date
#  client_id            :integer
#  user_id              :integer
#

# -*- encoding : utf-8 -*-
class Supplydetail < ActiveRecord::Base
  include Nextprev
  include Translation
  has_paper_trail

  strip_attributes
  attr_accessible :user_id, :client_id, :book_id, :supply_id, :prices_attributes, :supplier_role, :productsupply_supplydetail_supplier_supplieridtype, :productsupply_supplydetail_supplier_idvalue, :supplier_name, :product_availability, :supply_date_role, :dateformat, :date, :unpriced_item_type, :availability_code
  belongs_to :book
  belongs_to :supply
  has_many :prices
  # acts_as_audited :associated_with => :book

  accepts_nested_attributes_for :prices, :allow_destroy => true

  # given a book, finds the first Supplydetail record and looks up the human readable form of its product availability status
  def self.description(book)
    sds = book.supplydetails
    sds.blank? ? "-" : pa_code = sds.first
    pa_code.blank? ? "-" : pa_code.translated_product_availability
  end

end


