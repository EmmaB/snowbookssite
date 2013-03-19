# == Schema Information
#
# Table name: webs
#
#  id          :integer          not null, primary key
#  book_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  client_id   :integer
#  old_book_id :integer
#  user_id     :integer
#

# -*- encoding : utf-8 -*-
class Web < ActiveRecord::Base
  include Translation
  has_paper_trail
  
  attr_accessible :book_id    ,
                  :created_at ,
                  :updated_at ,
                  :client_id  ,
                  :old_book_id,
                  :user_id

  include PgSearch
  pg_search_scope :web_search,
    using: {tsearch: {dictionary: "english"}},
    using: {tsearch: {prefix: true}},
    associated_against: {book: [:title, :isbn, :subtitle, :default_contributor_last_name, :default_contributor_first_name]}

  belongs_to  :book
  belongs_to  :client
  has_many    :posts

  validates :book_id, :presence => true
  validates :client_id, :presence => true
  # acts_as_audited :associated_with => :book


  # takes a Book object. Finds the other contributors for that title but screens for non-web-enabled books
  def self.get_related_titles(starting_book)
    related_books = []
    contribs = starting_book.contacts
    contribs.each {|contrib| related_books << contrib.books.where(:include_on_web => true) }
    related_books.flatten.uniq.reject {|book|  book == starting_book }
  end

  def self.multiple_summary_details(books)
    books_array = []
    books.uniq.each { |book| books_array << summary_details(book) } unless books.nil?
    books_array.sort_by { |hsh| hsh["Category"] }
  end

  def self.multiple_summary_details_by_category(books)
    books_array_cat = []

#    books.uniq_by {|obj| obj.title }.each { |book| books_array_cat << summary_details(book) } unless books.nil?

    last_title = String.new
    books.each do |book|
      books_array_cat << summary_details(book)  unless (book.nil? or book.title == last_title)
      last_title = book.title
    end


    books_array_cat.sort_by { |hsh| hsh["Category"] }
    array_of_genres = books_array_cat.group_by {|prod| prod["Category"]}
  end

  # given a list of Books fetches typical display content in a hash. Some keys are text so that they can be used...
  # ...as the title or heading for the associated data
  def self.summary_details(book, size = :thumb)
    puts "in the accursed summary details method"
    details = {}
    # front_cover returns a hash pre-filled with blanks if data is unavailable
    details[:cover] = book.supportingresources.last ? book.supportingresources.last.image.url(:thumb) : "https://s3-eu-west-1.amazonaws.com/bibliocloudimages/static/thumb/missing.png"
    details["Category"] = book.work.main_subject if book.work.main_subject
    details["Title"] = book.title
    details["Author"] = "#{book.default_contributor_first_name} #{book.default_contributor_last_name}"
    details["Price"] = book.default_price_amount if book.default_price_amount
    details["Format"] = book.translated_format
    details["Status"] = book.translated_publishing_status
    details["Published"] = book.pub_date.strftime("%d %B '%y") unless book.pub_date.nil?
    details[:bio] = book.marketingtexts.where('text_type = ?', '12')
    details[:book] = book.productcodes
    details[:web] = book.webs.first
    details[:isbn_number] = book.isbn
    details
  end

  def self.text_search(query)
      if query.present?
        web_search(query)
      else
        scoped
      end
    end

end


