# == Schema Information
#
# Table name: formats
#
#  id               :integer          not null, primary key
#  code             :string(255)
#  value            :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  format_detail_id :integer
#  format_alias     :string(255)
#

class Format < ActiveRecord::Base
  has_paper_trail

  attr_accessible :code             ,
                  :value            ,
                  :created_at       ,
                  :updated_at       ,
                  :format_detail_id ,
                  :format_alias

  has_many :format_details
  def self.dropdown
    order(:value)
  end

  def to_s
    value
  end
end
