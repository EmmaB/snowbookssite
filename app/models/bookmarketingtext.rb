# == Schema Information
#
# Table name: bookmarketingtexts
#
#  id               :integer          not null, primary key
#  book_id          :integer
#  marketingtext_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#  work_id          :integer
#

# -*- encoding : utf-8 -*-
class Bookmarketingtext < ActiveRecord::Base
  
  attr_accessible :book_id          ,
                  :marketingtext_id ,
                  :created_at       ,
                  :updated_at       ,
                  :work_id
  belongs_to :work
  belongs_to :book
  belongs_to :marketingtext

end
       