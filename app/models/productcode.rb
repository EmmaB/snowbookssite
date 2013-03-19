# == Schema Information
#
# Table name: productcodes
#
#  id         :integer          not null, primary key
#  idtype     :string(255)
#  idvalue    :string(255)
#  created_at :datetime
#  updated_at :datetime
#  book_id    :integer
#  client_id  :integer
#  user_id    :integer
#

# -*- encoding : utf-8 -*-
class Productcode < ActiveRecord::Base
  include Nextprev
  has_paper_trail
  
  strip_attributes
  attr_accessible :idtype, :idvalue, :books_attributes, :book_id, :client_id, :user_id, :book_ids
  belongs_to :book
  # validates :client_id, :presence => true
  validates :book_id, :presence => true
  # acts_as_audited :associated_with => :book
end
