# == Schema Information
#
# Table name: posts
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  client_id      :integer
#  title          :string(255)
#  status         :string(255)
#  allow_comments :boolean
#  body           :text
#  extended_body  :text
#  excerpt        :text
#  keywords       :string(255)
#  category       :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  company_id     :integer
#  go_live_date   :date
#  original_id    :integer
#  author_name    :string(255)
#  comments_count :integer          default(0), not null
#

class Post < ActiveRecord::Base
  include Nextprev
  has_paper_trail

  strip_attributes
  include PgSearch
  pg_search_scope :post_search, against: [:body,  :extended_body, :category],
    using: {tsearch: {dictionary: "english"}},
    using: {tsearch: {prefix: true}},
    using: {:tsearch => {:any_word => true}},
    associated_against: {user: [:first_name, :last_name]}

  def self.text_search(query)
      if query.present?
        post_search(query)
      else
        scoped
      end
      end



  attr_accessible :allow_comments, :body, :category, :client_id, :excerpt, :extended_body, :keywords, :status, :title, :user_id, :company_id, :created_at, :updated_at
  belongs_to :company
  has_many :comments
  belongs_to :client
  belongs_to :user


  def self.monthly_archives(posts)
    posts.group_by { |t| t.created_at.beginning_of_month }.sort.reverse
  end


  def self.rename_all_img_roots
    Post.all.each do |post|
      if post.body
        post.body           = post.body.gsub(/http:\/\/www.snowbooks.com\/weblog\/(.*.jpg)/, 'https://s3-eu-west-1.amazonaws.com/bibliocloudimages/snowblog/\1')
      end
      if post.extended_body
        post.extended_body  = post.extended_body.gsub(/http:\/\/www.snowbooks.com\/weblog\/(.*.jpg)/, 'https://s3-eu-west-1.amazonaws.com/bibliocloudimages/snowblog/\1')
      end
      post.save
    end
  end
end
