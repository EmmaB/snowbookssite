# == Schema Information
#
# Table name: workcontacts
#
#  id                :integer          not null, primary key
#  contact_id        :integer
#  work_id           :integer
#  work_contact_role :string(255)
#  client_id         :integer
#  created_at        :datetime
#  updated_at        :datetime
#  contact_role_id   :integer
#  sequence_number   :string(255)
#  altcontact_id     :integer
#

# -*- encoding : utf-8 -*-
class Workcontact < ActiveRecord::Base
  has_paper_trail

  attr_accessible :contact_id, :sequence_number, :work_id, :work_contact_role, :client_id, :book_id, :bookcontact_id, :book_ids, :altcontact_id, :contact_roles_attributes #required for adding roles to work contribs
  attr_accessor :contact

  belongs_to  :contact
  belongs_to  :work
  has_many    :contact_roles                                     , :dependent => :destroy
  has_many    :books                 , :through => :bookcontacts
  has_many    :bookcontacts                                      , :dependent => :destroy

  accepts_nested_attributes_for :contact_roles                   , :allow_destroy => true
  accepts_nested_attributes_for :bookcontacts                     , :allow_destroy => true



end
#
