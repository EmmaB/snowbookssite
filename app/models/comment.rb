# == Schema Information
#
# Table name: comments
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  client_id   :integer
#  contact_id  :integer
#  author      :string(255)
#  email       :string(255)
#  ip          :string(255)
#  url         :string(255)
#  body        :text
#  published   :boolean
#  post_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  original_id :integer
#

class Comment < ActiveRecord::Base
  attr_accessible :author, :body, :client_id, :contact_id, :email, :ip, :post_id, :published, :url, :user_id, :created_at, :updated_at
  belongs_to :post, counter_cache: true
  has_paper_trail

  validates_presence_of :email
  validates_presence_of :body
  validates_presence_of :author
  validates_presence_of :ip

  validate :captcha_must_be_correct

  def captcha_must_be_correct
    errors.add(:ip, "Try again") unless
     ip.match(/no.?/i)

  end
end
