# == Schema Information
#
# Table name: supplies
#
#  id                 :integer          not null, primary key
#  countries_included :text
#  regions_included   :text
#  countries_excluded :text
#  regions_excluded   :text
#  created_at         :datetime
#  updated_at         :datetime
#  book_id            :integer
#  client_id          :integer
#  user_id            :integer
#

# -*- encoding : utf-8 -*-
class Supply < ActiveRecord::Base
  include Nextprev
  has_paper_trail


  strip_attributes
  attr_accessible :user_id, :client_id, :book_id, :prices_attributes, :supplydetails_attributes, :countries_included, :regions_included, :countries_excluded, :regions_excluded
  belongs_to :book
  has_many :supplydetails, :dependent => :destroy
  has_many :prices, :through => :supplydetails, :dependent => :destroy
  accepts_nested_attributes_for :supplydetails, :allow_destroy => true
  # acts_as_audited :associated_with => :book

  # validates :client_id, :presence => true
  # validates :book_id, :presence => true
  def to_s
    unless countries_included.blank?
    "#{Channel.where(:id => countries_included).first.try(:to_s)}"
    end
  end
end


