# == Schema Information
#
# Table name: booksupportingresources
#
#  id                     :integer          not null, primary key
#  created_at             :datetime
#  updated_at             :datetime
#  book_id                :integer
#  supportingresources_id :integer
#  supportingresource_id  :integer
#

# -*- encoding : utf-8 -*-
class Booksupportingresource < ActiveRecord::Base
  attr_accessible :created_at             ,
                  :updated_at             ,
                  :book_id                ,
                  :supportingresources_id ,
                  :supportingresource_id
  belongs_to :book
  belongs_to :supportingresource
end


