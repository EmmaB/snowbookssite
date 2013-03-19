# == Schema Information
#
# Table name: marketingtexts
#
#  id               :integer          not null, primary key
#  book_id          :integer
#  text_type        :string(255)
#  marketing_text   :text
#  created_at       :datetime
#  updated_at       :datetime
#  legacy_code      :string(255)
#  legacy_code_note :string(255)
#  client_id        :integer
#  user_id          :integer
#  work_id          :integer
#

# -*- encoding : utf-8 -*-
class Marketingtext < ActiveRecord::Base
  include Nextprev
  include Translation
  has_paper_trail
  acts_as_taggable

  letsrate_rateable "Rating"
  include PgSearch
  pg_search_scope :mktg_search, against: [:marketing_text],
    using: {tsearch: {dictionary: "english"}},
    using: {tsearch: {prefix: true}},
     associated_against: {:tags => [:name], :work => :title }

  multisearchable :against =>  [:client_id, :work_id, :text_type, :marketing_text]
    def self.text_search(query)
      if query.present?
        mktg_search(query)
      else
        scoped
      end
    end

  strip_attributes
  attr_accessible :user_id, :created_at, :legacy_code, :updated_at, :client_id, :book_id, :text_type, :marketing_text, :legacy_code_note, :work_id, :soft_delete, :book_ids, :rating, :date_published , :date_released  , :publication    , :contact_id, :supportingresources_attributes, :supportingresources, :tag_list, :pull_quote, :review_url
   #book_ids needed for the marketing text HABTM selection in Work.
  has_paper_trail

  # belongs_to :book
  before_save :map_legacy_codes
  # acts_as_audited :associated_with => :book
  before_save :clean_up_html
  after_save  :check_dupes
  belongs_to  :work, :touch => true
  has_many    :books                 , :through => :bookmarketingtexts
  has_many    :bookmarketingtexts                                      , :dependent => :destroy
  has_many    :supportingresources, :as => :resourceable
  has_many    :tweets, :as => :tweetable

  validates :client_id, :presence => true
  validates :marketing_text, :presence => true
  TEXT_TYPES = {:blurb => '03', :bio => '12', :reviews => '06', :notice => '13' }

  def check_dupes
    puts "mktgtextself is #{self.inspect}"
    #get all mktgtexts of a work that are the same as the current one
    Marketingtext.where(:marketing_text => self.marketing_text, :client_id => self.client_id, :text_type => self.text_type, :legacy_code => self.legacy_code).where('id != ?', self.id).each do |other_text|
      puts "other text is #{other_text.inspect}"
      # go through each of their bookmarektingtext join records
      other_text.bookmarketingtexts.each do |bmt|
        puts "bmt is #{bmt.inspect}"
        #create a new bmt between the current mktgtext and the book in question
        Bookmarketingtext.find_or_create_by_marketingtext_id_and_book_id(self.id, bmt.book_id)
        #zap the extraneous one
        # bmt.destroy
      end
      other_text.destroy
    end
  end

  def to_s
    "#{work.try(:title)}: text type #{text_type}. #{marketing_text[0..15]}..."
  end

  def clean_up_html
    puts "running clean up"
    Sanitize.clean(self.marketing_text, Sanitize::Config::RESTRICTED)
  end

  # given a book object and a symbol (selected from TEXT_TYPES) fetches the relevant Marketingtext string
  # if biographical note is blank, fetches the first contributor's bio from their contributor record
  def self.get_text(book, text_type)
    m_texts = book.marketingtexts.where('text_type = ?', TEXT_TYPES[text_type])
    m_texts.map(&:marketing_text).join("<br/>")
  end

  #Do Not Run - one off method to make marketingtexts belong to Work, not Book.
  def self.add_work_id_to_marketingtext_table
    marketing_texts = Marketingtext.all
    marketing_texts.each do |mktg_text|
      begin
            mktg_text.update_attributes(:work_id => Book.find(mktg_text.book_id).work.id)
      rescue
        "not found"
      end
    end
  end

  #Do Not Run - one off method to populate HABTM join table.
  def self.populate_bookmarketing_table
    # gets every marketing text which has unique text. I don't want more than one version of every blurb, review etc
    Marketingtext.group(:marketing_text).each do |text|
      new_join_table_record = Bookmarketingtext.new(:book_id => text.book_id, :marketingtext_id => text.id, :work_id => text.work_id)
      new_join_table_record.save
    end
  end

  def map_legacy_codes

    if  self.text_type.blank?

      newcode    = (
      if self.legacy_code == "01" then "03"
      elsif self.legacy_code == "02" then
        "02"
      elsif self.legacy_code == "03" then
        "01"
      elsif self.legacy_code == "04" then
        "04"
      elsif self.legacy_code == "05" then
        "06"
      elsif self.legacy_code == "06" then
        "07"
      elsif self.legacy_code == "07" then
        "06"
      elsif self.legacy_code == "08" then
        "06"
      elsif self.legacy_code == "09" then
        "10"
      elsif self.legacy_code == "10" then
        "08"
      elsif self.legacy_code == "11" then
        "01"
      elsif self.legacy_code == "12" then
        "01"
      elsif self.legacy_code == "13" then
        "12"
      elsif self.legacy_code == "14" then
        "01"
      elsif self.legacy_code == "15" then
        "01"
      elsif self.legacy_code == "16" then
        "01"
      elsif self.legacy_code == "17" then
        "05"
      elsif self.legacy_code == "18" then
        "05"
      elsif self.legacy_code == "19" then
        "11"
      elsif self.legacy_code == "20" then
        "11"
      elsif self.legacy_code == "21" then
        "13"
      elsif self.legacy_code == "23" then
        "14"

      elsif self.legacy_code == "24" then
        "14"
      elsif self.legacy_code == "25" then
        "13"
      elsif self.legacy_code == "26" then
        "13"
      elsif self.legacy_code == "27" then
        "13"
      elsif self.legacy_code == "28" then
        "13"

      elsif self.legacy_code == "30" then
        "09"
      elsif self.legacy_code == "31" then
        "13"
      elsif self.legacy_code == "32" then
        "13"
      elsif self.legacy_code == "33" then
        "14"
      elsif self.legacy_code == "34" then
        "14"
      elsif self.legacy_code == "35" then
        "09"
      elsif self.legacy_code == "40" then
        "01"
      elsif self.legacy_code == "41" then
        "01"
      elsif self.legacy_code == "42" then
        "01"
      elsif self.legacy_code == "99" then
        "01"
      end)
      legacynote = (
      if self.legacy_code == "01" then
        "Onix 2.1 code was 01 Main description"
      elsif self.legacy_code == "02" then
        "Onix 2.1 code was 02 Short description"
      elsif self.legacy_code == "03" then
        "Onix 2.1 code was 03 Long description"
      elsif self.legacy_code == "04" then
        "Onix 2.1 code was 04 Table of contents"
      elsif self.legacy_code == "05" then
        "Onix 2.1 code was 05 Review quote, restricted length"
      elsif self.legacy_code == "06" then
        "Onix 2.1 code was 06 Quote from review of previous edition"
      elsif self.legacy_code == "07" then
        "Onix 2.1 code was 07 Review text"
      elsif self.legacy_code == "08" then
        "Onix 2.1 code was 08 Review quote"
      elsif self.legacy_code == "09" then
        "Onix 2.1 code was 09 Promotional headline"
      elsif self.legacy_code == "10" then
        "Onix 2.1 code was 10 Previous review quote"
      elsif self.legacy_code == "11" then
        "Onix 2.1 code was 11 Author comments"
      elsif self.legacy_code == "12" then
        "Onix 2.1 code was 12 Description for reader"
      elsif self.legacy_code == "13" then
        "Onix 2.1 code was 13 Biographical note"
      elsif self.legacy_code == "14" then
        "Onix 2.1 code was 14 Description for reading group guide"
      elsif self.legacy_code == "15" then
        "Onix 2.1 code was 15 Discussion question for reading group guide"
      elsif self.legacy_code == "16" then
        "Onix 2.1 code was 16 Competing titles"
      elsif self.legacy_code == "17" then
        "Onix 2.1 code was 17 Flap copy"
      elsif self.legacy_code == "18" then
        "Onix 2.1 code was 18 Back cover copy"
      elsif self.legacy_code == "19" then
        "Onix 2.1 code was 19 Feature"
      elsif self.legacy_code == "20" then
        "Onix 2.1 code was 20 New feature"
      elsif self.legacy_code == "21" then
        "Onix 2.1 code was 21 Publisher's notice"
      elsif self.legacy_code == "23" then
        "Onix 2.1 code was 23 Excerpt from book"
      elsif self.legacy_code == "24" then
        "Onix 2.1 code was 24 First chapter"
      elsif self.legacy_code == "25" then
        "Onix 2.1 code was 25 Description for sales people"
      elsif self.legacy_code == "26" then
        "Onix 2.1 code was 26 Description for press"
      elsif self.legacy_code == "27" then
        "Onix 2.1 code was 27 Description for rights"
      elsif self.legacy_code == "28" then
        "Onix 2.1 code was 28 Description for teachers"
      elsif self.legacy_code == "30" then
        "Onix 2.1 code was 30 Unpublished endorsement"
      elsif self.legacy_code == "31" then
        "Onix 2.1 code was 31 Description for bookstore"
      elsif self.legacy_code == "32" then
        "Onix 2.1 code was 32 Description for library"
      elsif self.legacy_code == "33" then
        "Onix 2.1 code was 33 Introduction or preface"
      elsif self.legacy_code == "34" then
        "Onix 2.1 code was 34 Full text"
      elsif self.legacy_code == "35" then
        "Onix 2.1 code was 35 Promotional text"
      elsif self.legacy_code == "40" then
        "Onix 2.1 code was 40 Author interview"
      elsif self.legacy_code == "41" then
        "Onix 2.1 code was 41 Reading group guide"
      elsif self.legacy_code == "42" then
        "Onix 2.1 code was 42 Commentary"
      elsif self.legacy_code == "99" then
        "Onix 2.1 code was 99 Country of final manufacture"
      end)

      self.text_type = newcode
      self.legacy_code_note                        = legacynote
    end
  end
end
