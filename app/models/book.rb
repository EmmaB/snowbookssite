# == Schema Information
#
# Table name: books
#
#  id                             :integer          not null, primary key
#  notification                   :string(255)
#  isbn                           :string(255)
#  format                         :string(255)
#  prefix                         :string(255)
#  title                          :string(255)
#  subtitle                       :string(255)
#  edition                        :string(255)
#  edition_statement              :string(255)
#  imprint                        :string(255)
#  publisher_role                 :string(255)
#  publisher                      :string(255)
#  publication_city               :string(255)
#  publication_country            :string(255)
#  publishing_status              :string(255)
#  work_id                        :integer
#  created_at                     :datetime
#  updated_at                     :datetime
#  default_price_amount           :string(255)
#  default_price_currency         :string(255)
#  default_contributor_first_name :string(255)
#  default_contributor_last_name  :string(255)
#  pub_date                       :date
#  include_on_web                 :boolean
#  client_id                      :integer
#  highlight_on_web               :boolean
#  contributor_statement          :text
#  user_id                        :integer
#  format_detail                  :string(255)
#  format_description             :string(255)
#  part_number                    :string(255)
#  annual_year                    :string(255)
#  illustrations_note             :string(255)
#  illustrated                    :string(255)
#  number_of_illustrations        :string(255)
#  series_id                      :integer
#  onixsent                       :date
#  google_preview                 :string(255)
#  google_info                    :string(255)
#  high_discount_threshold        :float
#  exclude_from_royalty_calc      :boolean          default(FALSE)
#  owner                          :integer
#  micron                         :float
#  cover_ftped_date               :date
#  altcontact_id                  :integer
#  format_id                      :integer
#  format_detail_id               :integer
#  valid_onix                     :boolean
#

# -*- encoding : utf-8 -*-
# The Book model is at the core of Bibliocloud along with their parent Work. It has_many objects, such as marketing texts, prices, subjects and measurements.
# This model inherits the navsteps module, which generates the blue buttons along the bottom of the form fields.
# It also inherits the nextprev module, so that the user can easily hop between records.
# Books are involved in royalty statement calculations. That functionality is inherited from the calculation module.
# A Book belongs_to a Work. So, for instance, the War and Peace paperback belongs_to the War and Peace work.
# A Book also belongs_to a Series. Monster Island paperback belongs to the Monster Trilogy.
# There are a number of validations to make sure that the Book contains some basic identification detail (the title, for instance) and that it contains the right client.
# There are also a bunch of callbacks to perform tasks such as creating a barcode from an ISBN number, and publishing book information to the public website.

class Book < ActiveRecord::Base

  include Calculation
  include Nextprev
  include Translation
  include Onixcheck
  include PgSearch
  pg_search_scope :book_search, against: [:contributor_statement,  :default_contributor_first_name, :default_contributor_last_name, :isbn,
    :format_description, :prefix, :title, :subtitle, :edition, :edition_statement,
    :imprint, :publisher_role, :publisher, :publication_city, :publication_country, :publishing_status, :pub_date,
    :default_price_amount, :default_price_currency, :part_number, :annual_year, :illustrations_note, :micron, :owner],
    using: {tsearch: {dictionary: "english"}},
    using: {:tsearch => {:any_word => true}},
    using: {tsearch: {prefix: true}},

    associated_against: {:tags => [:name] , work: [:title, :main_bic_code, :main_bisac_code, :main_subject], contacts: :person_name_inverted, marketingtexts: [:marketing_text, :text_type]}

    multisearchable :against => [:title, :isbn, :contributor_statement,  :default_contributor_first_name, :default_contributor_last_name,
      :format_description, :prefix, :subtitle, :edition, :edition_statement,
      :imprint, :publisher_role, :publisher, :publication_city, :publication_country, :publishing_status, :pub_date,
      :default_price_amount, :default_price_currency, :part_number, :annual_year, :illustrations_note, :micron, :owner, :tag_list]

  delegate :contract_id,   :to => :work
  delegate :value,    :to => :format, :prefix => :format, :allow_nil => true

  has_paper_trail
  acts_as_taggable
  strip_attributes
  # attr_accessible whitelists attributes that can be written to. If an attribute isn't here, you get the Can't Mass Assign error on saving a model object
  # Because we're using attr_accessible to whitelist attributes, we have to explicitly allow the nested model's attributes to be written to, as well.
  attr_accessible :annual_year                   ,
                  :audiences_attributes          ,
                  :bicgeogsubjects_attributes    ,
                  :bicsubjects_attributes        ,
                  :bisacsubjects_attributes      ,
                  :book_channel_attributes       ,
                  :book_ids                      ,
                  :book_masterchannel_attributes ,
                  :bookcontacts_attributes       ,
                  :books_attributes              ,
                  :client_id                     ,
                  :contact_id                    ,
                  :contacts_attributes           ,
                  :contributor_statement         ,
                  :cover_ftped_date              ,
                  :default_contributor_first_name,
                  :default_contributor_last_name ,
                  :default_price_amount          ,
                  :default_price_currency        ,
                  :edition                       ,
                  :edition_statement             ,
                  :estimate_ids                  ,
                  :estimates_attributes          ,
                  :exclude_from_onix             ,
                  :exclude_from_royalty_calc     ,
                  :extent_ids                    ,
                  :extents_attributes            ,
                  :foreignright_id               ,
                  :format_attributes             ,
                  :format_description            ,
                  :format_detail                 ,
                  :format_detail_id              ,
                  :format_id                     ,
                  :format_types_attributes       ,
                  :google_info                   ,
                  :google_preview                ,
                  :high_discount_threshold       ,
                  :highlight_on_web              ,
                  :id                            ,
                  :illustrated                   ,
                  :illustrations_note            ,
                  :imprint                       ,
                  :include_marketingtext         ,
                  :include_on_web                ,
                  :internal_reference            ,
                  :isbn                          ,
                  :keyword_list                  ,
                  :language                      ,
                  :lifecycledates_attributes     ,
                  :marketingtexts_attributes     ,
                  :measurement_ids               ,
                  :measurements_attributes       ,
                  :micron                        ,
                  :notification                  ,
                  :number_of_illustrations       ,
                  :onixsent                      ,
                  :owner                         ,
                  :part_number                   ,
                  :prefix                        ,
                  :prices_attributes             ,
                  :prints_attributes             ,
                  :product_titles_attributes     ,
                  :productcode_ids               ,
                  :productcodes_attributes       ,
                  :pub_date                      ,
                  :publication_city              ,
                  :publication_country           ,
                  :publisher                     ,
                  :publisher_role                ,
                  :publishing_status             ,
                  :relatedproducts_attributes    ,
                  :rights_attributes             ,
                  :rights_edition                ,
                  :series_id                     ,
                  :spelling                      ,
                  :subjects_attributes           ,
                  :subtitle                      ,
                  :supplies_attributes           ,
                  :supplydetails_attributes      ,
                  :supportingresources_attributes,
                  :tag_list                      ,
                  :title                         ,
                  :user_id                       ,
                  :valid_onix                    ,
                  :web_links_attributes          ,
                  :work_id                       ,
                  :item_code_id                  ,
                  :languages_attributes          ,
                  :bic_excellence                ,
                  :bic_basic                     ,
                  :edition_type_code             ,
                  :validation_template_ids       ,
                  :validation_templates_attributes,
                  :non_book                      ,
                  :contained_items_attributes    ,
                  :book_seriesnames_attributes   ,
                  :sales_restrictions_attributes ,
                  :rights_attributes             ,
                  :imprint_id                    ,
                  :publishername_id,
                  :no_validation,
                  :work_attributes,
                  :work




  # attr_accessor combines both attr_reader and attr_writer so objects outside this model can both read and write to the following objects:
  attr_accessor :average_value_per_unit           ,
                :channel_sales_net_receipts       ,
                :channel_sales_qty                ,
                :default_set_name                 ,
                :master_channel_sales_net_receipts,
                :master_channel_sales_qty         ,
                :other_books_by_author            ,
                :royaltiesbychannel               ,
                :sale_royalty_by_band


  acts_as_xlsx

  belongs_to :work , :counter_cache => true
  belongs_to :contract
  has_many :seriesnames        , :through => :book_seriesnames
  has_many :book_seriesnames
  belongs_to :foreignright

  has_many :masterrules                                       , :dependent => :destroy
  has_many :sales                                             , :dependent => :destroy
  # has_many :channels           , :through   => :sales
  has_many :productcodes                                      , :dependent => :destroy
  has_one  :isbnlist
  has_many :bookcontacts                                      , :dependent => :destroy
  has_many :workcontacts       , :through => :bookcontacts
  has_many :contacts           , :through => :workcontacts # this is a nested has_many through. Book has many bookcontacts, then has many workcontacts through bookcontacts, then has_many contacts through workcontacts. So now I can call @book.contacts. New in rails 3.1

  has_many :subjects           , :through => :booksubjects    , :dependent => :destroy
  has_many :booksubjects                                      , :dependent => :destroy

  has_many :bicsubjects        , :through => :bookbicsubjects , :dependent => :destroy
  has_many :bookbicsubjects                                   , :dependent => :destroy

  has_many :bisacsubjects      , :through => :bookbisacsubjects  , :dependent => :destroy
  has_many :bookbisacsubjects                                    , :dependent => :destroy

  has_many :bicgeogsubjects    , :through => :bookbicgeogsubjects, :dependent => :destroy
  has_many :bookbicgeogsubjects                                , :dependent => :destroy

  has_many :audiences          , :through => :bookaudiences, :dependent => :destroy
  has_many :bookaudiences                                 , :dependent => :destroy

  has_many :audience_ranges, :through => :book_audience_ranges, :dependent => :destroy
  has_many :book_audience_ranges, :dependent => :destroy

  has_many :measurements                                      , :dependent => :destroy
  has_many :extents                                           , :dependent => :destroy
  belongs_to :format, :foreign_key => :format_detail_id, :class_name => "FormatDetail"
  belongs_to :format_detail, :foreign_key => :format_id, :class_name => "FormatDetail"

  has_many :rights                                            , :dependent => :destroy
  has_many :supplies                                          , :dependent => :destroy
  has_many :supplydetails      , :through   => :supplies      , :dependent => :destroy
  has_many :prices             , :through   => :supplydetails , :dependent => :destroy
  has_many :relatedproducts                                   , :dependent => :destroy

  has_many :supportingresources, :through => :booksupportingresources   , :dependent => :destroy
  has_many :booksupportingresources                                     , :dependent => :destroy

  has_many :payments
  has_many :webs                                              , :dependent => :destroy
  has_many :purchases
  has_many :returnvols                                        , :dependent => :destroy
  has_many :returns                                           , :dependent => :destroy
  has_many :schedules, :as => :schedulable
  has_one  :barcodeimg                                        , :dependent => :destroy
  has_one  :amazontitle
  belongs_to  :publishername
  belongs_to  :imprint
  has_many :prints     , :through => :bookprints
  has_many :bookprints                                        , :dependent => :destroy

  has_many :print_cover_details , :through => :book_print_cover_details
  has_many :book_print_cover_details                          , :dependent => :destroy

  has_many :print_paper_details , :through => :book_print_paper_details
  has_many :book_print_paper_details                          , :dependent => :destroy

  has_many :print_binding_details , :through => :book_print_binding_details
  has_many :book_print_binding_details                        , :dependent => :destroy

  has_many :print_originations , :through => :book_print_originations
  has_many :book_print_originations                           , :dependent => :destroy

  has_many :print_parts        , :through => :book_print_parts
  has_many :book_print_parts                               , :dependent => :destroy

  has_many :simple_print_prices , :through => :book_simple_print_prices
  has_many :book_simple_print_prices                           , :dependent => :destroy

  has_many :reprints , :through => :book_reprints
  has_many :book_reprints                           , :dependent => :destroy

  has_many :marketingtexts     , :through => :bookmarketingtexts
  has_many :bookmarketingtexts                                , :dependent => :destroy

  has_many :schedules     , :through => :book_schedules
  has_many :book_schedules                                , :dependent => :destroy


  # has_many :booksearches
  has_many :estimates                                         , :dependent => :destroy
  has_many :lifecycledates    , as: :lifecycleable
  has_many :deliveries
  has_many :product_titles                                    , :dependent => :destroy

  has_many :web_links, as: :linkable                          , :dependent => :destroy
  has_many :copy_trackers
  has_many :book_book_collections , :dependent => :destroy
  has_many :book_collections, :through => :book_book_collections

  has_many :tweets, :as => :tweetable
  has_many :keywords, :as => :keywordable

  has_many :book_masterchannels  , :dependent => :destroy
  has_many :book_channels        , :through => :book_masterchannels

  has_one  :royalty_specifier                       , :as => :royaltyable, :dependent => :destroy
  has_many :royalty_date_escalators                 ,:through => :royalty_specifier
  has_many :royalty_discount_escalators             ,:through => :royalty_specifier
  has_many :royalty_quantity_escalators             ,:through => :royalty_specifier
  has_many :royalty_quantity_escalator_channel_rates,:through => :royalty_quantity_escalators
  has_many :royalty_batch_books
  has_many :sale_royalties                          , :dependent => :destroy

  has_many :advances
  has_many :languages                               , :dependent => :destroy

  has_many :validation_templates, :through => :book_validation_templates
  has_many :book_validation_templates
  has_many :book_validation_tests
  has_many :contained_items       , :foreign_key => :container_book_id, :class_name => "ContainedItem"
  belongs_to :format,  :foreign_key => :format_detail_id, :class_name => "Format"
  has_many :sales_restrictions, :dependent => :destroy


  # accepts_nested_attributes_for allows the Book object to crud in another model even if there's no relevant action in that model's controller.
  # You have to use fields_for in the form, so that the code executes once for each nested model present.
  # And you have to make the nested attributes accessible by adding them to this model, e.g. attr_accessible :marketingtexts_attributes.
  # Validations are honoured.
  # I've combined nested_attributes with adding fields dynamically. The cocoon gem provides the methods link_to_add_association and link_to_remove_association

  accepts_nested_attributes_for :bicgeogsubjects                              , :allow_destroy => true
  accepts_nested_attributes_for :bicsubjects                                  , :allow_destroy => true
  accepts_nested_attributes_for :bisacsubjects                                , :allow_destroy => true
  accepts_nested_attributes_for :book_channels                                , :allow_destroy => true
  accepts_nested_attributes_for :book_masterchannels                          , :allow_destroy => true
#  accepts_nested_attributes_for :book_royalty_date_escalators                 , :allow_destroy => true
#  accepts_nested_attributes_for :book_royalty_discount_escalators             , :allow_destroy => true
#  accepts_nested_attributes_for :book_royalty_quantity_escalator_channel_rates, :allow_destroy => true
#  accepts_nested_attributes_for :book_royalty_quantity_escalators             , :allow_destroy => true
#  accepts_nested_attributes_for :book_royalty_specifier                       , :allow_destroy => true
  accepts_nested_attributes_for :bookcontacts                                 , :allow_destroy => true
  accepts_nested_attributes_for :contacts
  accepts_nested_attributes_for :bookcontacts       , :allow_destroy => true
  accepts_nested_attributes_for :productcodes       , :allow_destroy => true
  accepts_nested_attributes_for :marketingtexts     , :allow_destroy => true
  accepts_nested_attributes_for :subjects           , :allow_destroy => true
  accepts_nested_attributes_for :measurements       , :allow_destroy => true
  accepts_nested_attributes_for :extents            , :allow_destroy => true
  accepts_nested_attributes_for :supplies           , :allow_destroy => true
  accepts_nested_attributes_for :supplydetails      , :allow_destroy => true
  accepts_nested_attributes_for :prices             , :allow_destroy => true
  accepts_nested_attributes_for :relatedproducts    , :allow_destroy => true
  accepts_nested_attributes_for :supportingresources, :allow_destroy => true
  accepts_nested_attributes_for :bicsubjects        , :allow_destroy => true
  accepts_nested_attributes_for :bisacsubjects      , :allow_destroy => true
  accepts_nested_attributes_for :bicgeogsubjects    , :allow_destroy => true
  accepts_nested_attributes_for :book_masterchannels, :allow_destroy => true
  accepts_nested_attributes_for :book_channels      , :allow_destroy => true
  accepts_nested_attributes_for :estimates          , :allow_destroy => true
  accepts_nested_attributes_for :lifecycledates     , :allow_destroy => true
  accepts_nested_attributes_for :prints             , :allow_destroy => true
  accepts_nested_attributes_for :product_titles     , :allow_destroy => true
  accepts_nested_attributes_for :web_links          , :allow_destroy => true
  accepts_nested_attributes_for :languages          , :allow_destroy => true
  accepts_nested_attributes_for :contained_items    , :allow_destroy => true
  accepts_nested_attributes_for :book_seriesnames   , :allow_destroy => true
  accepts_nested_attributes_for :rights             , :allow_destroy => true
  accepts_nested_attributes_for :sales_restrictions , :allow_destroy => true
  accepts_nested_attributes_for :work


  # After the Book object is saved, this aftersave callback checks to see if the Book should be published to the customer-facing website
  after_save        :publish_to_web
  # After the Book object is saved, this aftersave callback checks to see if the Book has used a new ISBN
  after_save        :update_isbn_list                   , :if => :isbn_changed?
  after_save        :delete_isbn_list                   , :if => :isbn_changed?
  before_validation :set_isbn_to_previous_value_if_blank
  after_save        :barcode
  # before_save       :set_up_known_formats
  # before_save       :update_format
  before_save       :set_advance_dates
  # after_save        :bic_basic
  # before_save        :update_author

  validates     :title      , :presence => true, :unless => "@multiple == true"
  validates     :work_id    , :presence => true, :unless => "@multiple == true", :on => :update
  validates     :client_id  , :presence => true, :unless => "@multiple == true"
  validates     :isbn       , :presence => true, :unless => "@multiple == true", :unless => :isbn_already_saved?
  validates     :include_on_web , :presence => true, :unless => "@multiple == true", :if => :highlight_on_web?

  after_save    :title_should_not_be_placeholder_text
  after_save    :availabilities_should_match
  after_save    :if_status_is_cancelled_so_should_availabilty
  before_save   :set_defaults
  before_save   :set_validity
  after_save    :update_schedule, :unless => "@multiple == true", :only => :update
  after_save    :update_validations, :unless => Proc.new { |book| book.no_validation == true }


  def update_validations
    @book = self
    ValidationTemplate.where('client_id is null or client_id = ?', self.client_id).each do |validation_template|
      BookValidationTemplate.first_or_create(:book_id => self.id, :validation_template_id => validation_template.id)
      validation_template.validation_test_suites.each do |test|
        unless test.validation_test.nil?
          BookValidationTest.where(:book_id => self.id, :validation_test_id => test.validation_test.id).delete_all
          if (eval test.validation_test.predicate).to_s == (eval test.validation_test.desired_result).to_s
            BookValidationTest.create!(:result => true, :book_id => self.id, :validation_test_id => test.validation_test.id)
          else
            BookValidationTest.create!(:result => false, :book_id => self.id, :validation_test_id => test.validation_test.id)
          end
        end
      end
    end
  end

  def is_non_book
    true if self.non_book == true
  end

  # def update_author
  #   default_contributor_first_name = work.contacts.first.try(:names_before_key)
  #   default_contributor_last_name = work.contacts.first.try(:keynames)
  # end


  def set_advance_dates
    if pub_date_changed?
      earliest_book = self.work.books.order('pub_date ASC').first
      if self == earliest_book
        self.work.contract.advances.where(:trigger => "On publication").each do |advance|
          advance.update_column(:due_date, pub_date)
        end
        self.work.contract.advances.where(:trigger => "1st January of the year of publication").each do |advance|
          advance.update_column(:due_date, pub_date.beginning_of_year)
        end
      end
    end
  end

  def update_schedule
    self.lifecycledates.each do |lifecycledate|
      schedule = Schedule.find_or_initialize_by_book_id_and_name(self.id, "#{self.title} #{lifecycledate.phase_name}")
      schedule.schedule_type = lifecycledate.lifecycleable_type
      schedule.client_id = self.client_id
      schedule.save!
      puts "schedule is #{schedule.inspect}"

      task = Task.find_or_initialize_by_schedule_id_and_name(schedule.id, lifecycledate.phase_name)
      task.name = lifecycledate.phase_name
      task.start = lifecycledate.forecast_start_date
      task.duration = 10
      task.save
      puts "saved task #{task.inspect}"
    end
  end

  def to_s
  title
  end

  def isbn_already_saved?
    true if isbn
  end

  def set_validity
    if self.onix_valid
      self.valid_onix = 'true'
    else
      self.valid_onix = 'false'
    end

  end

  def self.send_onix(client_id)
    Book.where(:client_id => client_id).each do |book|
      if book.onix_valid
        unless book.exclude_from_onix

        end
      end
    end
  end


  # def update_format
  #   self.format = Format.find(self.format_detail_id).code if self.format_id
  # end

  def set_defaults
    unless self.micron
      self.micron = "120"
    end
  end

   def if_status_is_cancelled_so_should_availabilty
     if self.publishing_status == "01" and self.supplydetails.first.product_availability != "01"
       errors.add(:publishing_status, I18n.t(:dodgy_availabilities, :scope => [:books, :books]) )
     end
   end

  def title_should_not_be_placeholder_text
    if /(tbc|placeholder|xxx|tba|unconfirmed|title|to be confirmed)/.match(self.title)
      errors.add(:title, I18n.t(:dodgy_book_title, :scope => [:books, :books])  )
    end
  end

   def availabilities_should_match
     self.supplydetails.each do |supplydetail|
       if self.publishing_status == "04"
         unless (["20", "21", "44"]).include?(supplydetail.product_availability)
           errors.add(:publishing_status, I18n.t(:dodgy_availabilities, :scope => [:books, :books]) )
         end
       end
       if supplydetail.product_availability =="10" and supplydetail.supply_date_role !="08"
         errors.add(:product_availability, I18n.t(:dodgy_expected_shipdate, :scope => [:books, :books]) )
       end
     end
   end

  # used in a number of drop down lists to include the format and price, so you can differentiate between
  # different versions of a book easily.
  def formatted_name
    "#{self.title} (#{self.format_value } #{self.default_price_amount} )"
  end

  def to_s
    "#{self.title} (#{self.format_value } #{self.default_price_amount} )"
  end

  # The drop down list of ISBNs isn't available in a record which already has an isbn record, so
  # this method sets the same isbn even though the field is empty in params.
  def set_isbn_to_previous_value_if_blank
    if self.isbn.blank?
      self.isbn = self.isbn_was
    end
  end

  # This is an after_save callback method which runs if the isbn number has changed
  # updates the isbnlists table with the string "used" in the used column if the number has been used as the ISBN.
  def update_isbn_list
    if self.isbn
      list = Isbnlist.find_by_number(self.isbn)
      list.update_attribute(:used, "used") unless list.nil?
    end
  end

  # This is an after_save callback method which runs if the isbn number has changed
  # It sets the isbn13 in the Isbn list to "not used" if the isbn is not present in a Book record.
  def delete_isbn_list
    Isbnlist.where(:client_id => self.client_id).find_each do |liste|
      if Book.where(:client_id => self.client_id).where(:isbn => liste.number).empty?
        liste.update_attribute(:used, "not used")
      end
    end
  end
handle_asynchronously :delete_isbn_list

    # Generates a barcode for a book, if the IBSN is more-or-less valid and if it hasn't already been generated.
    # I say more-or-less, because the regex here checks for a 13 digit number with 978 or 979 and a number or X at the end, but it doesn't check the checksum algorithm, which is
    # how the last digit is created.
    def barcode
      unless Rails.env.test?
        # if /^(97(8|9))?\d{9}(\d|X)$/.match(self.isbn)
          if ISBN.valid?(self.isbn)
            puts "isbn valid!"
          if Barcodeimg.find_by_book_id(self.id).nil? || self.isbn_changed?
            # delete the old bar code for previous ISBN
            self.barcodeimg.delete if self.barcodeimg
            Barcodeimg.generate(self)
          elsif self.barcodeimg.image.content_type != "image/png"
            puts "barcode exists but isn't a png"
            self.barcodeimg.delete if self.barcodeimg

            Barcodeimg.generate(self)

          end
        end
      end
    end

    # part of looking up the author's other books in books/show view
    def self.book(author_book)
      Book.find_by_id(author_book)
    end

    def self.book_by_contract(contract, client)
      books = Book.joins(:work => :contract).where('contracts.signed_date is not null').find_all_by_client_id_and_work_id(client, contract.work)
      book_array = []
      books.each do |book|
        book_array << "#{book.title} #{book.translated_format} #{book.default_price_amount}"
      end
      book_array
    end

    # Scope used in drop down menus on various forms.
    def self.dropdown(current_user)
      Book.unscoped.joins(:work => :contract).where('contracts.signed_date is not null').order('title ASC').where(:client_id => current_user.client_id)
    end

    def is_signed_off
      # Book.joins(:work => :contract).where('contracts.signed_date is not null').any? {|u| u.id == id}
      # not self.work.contract.signed_date.blank?

      true if Book.joins(:work => :contract).where(:books => {:id => self.id}).where("contracts.signed_date is not null").count > 0
    end

    # Scope used in drop down menus on various forms.
    def self.proposal_dropdown(current_user)
      Book.unscoped.joins(:work => :contract).where('contracts.signed_date is null').order('title ASC').where(:client_id => current_user.client_id)
    end

    def self.dropdown_for_royalties(current_user)

      client_id = current_user.client_id

      Book.where("books.client_id = ? and
                  books.id not in (
                    select rbb.book_id
                    from   royalty_batch_books rbb join
                           royalty_batches     rb  on
                             (rb.id = rbb.royalty_batch_id)
                    where  rb.status    = 'Approved' and
                           rb.client_id = ?)",client_id,client_id)
    end

    # Used to get the book title in a number of views, e.g. sales edit.
    def self.book_title(book)
      Book.find_by_id(book).title unless Book.find_by_id(book).nil?
    end

    def self.by_association(assoc)
      Book.find_by_id(assoc.book_id) unless Book.find_by_id(assoc.book_id).nil?
    end

    # Creates a new Web object if the book should be published to the customer-facing website. Deletes a Web object if the
    # book shouldn't be published to the live site.
    def publish_to_web
      if self.include_on_web?
        newweb           = Web.find_or_initialize_by_book_id(self.id)
        newweb.book_id   = self.id
        newweb.client_id = self.client_id
        newweb.save!
      else
        oldweb = Web.find_by_book_id(self.id)
        if oldweb.nil?
        else
          oldweb.delete
        end
      end
    end

  # def set_up_known_formats
  #   if self.format_detail == "B104"
  #     unless Measurement.find_by_book_id_and_measurement_unit_id(self.id, 1)
  #       Measurement.create!(:client_id => self.client_id, :book_id => self.id, :measurement => "178", :measurement_unit_id => "1", :measurement_type_id => "1" )
  #       Measurement.create!(:client_id => self.client_id, :book_id => self.id, :measurement => "110", :measurement_unit_id => "2", :measurement_type_id => "1" )
  #       errors.add(:format_detail, "Because you've set this to A format, the system has automatically created height and width records below.")
  #     end
  #   end
  #
  #   if self.format_detail == "B105"
  #     unless Measurement.find_by_book_id_and_measurement_unit_id(self.id, 1)
  #       Measurement.create!(:client_id => self.client_id, :book_id => self.id, :measurement => "198", :measurement_unit_id => "1", :measurement_type_id => "1" )
  #       Measurement.create!(:client_id => self.client_id, :book_id => self.id, :measurement => "129", :measurement_unit_id => "2", :measurement_type_id => "1" )
  #       errors.add(:format_detail, "Because you've set this to B format, the system has automatically created height and width records below.")
  #     end
  #   end
  # end

  def other_books_by_author
    # This method returns an array of hashes. Each hash contains two kv pairs: the book id and the name of each title by the same author. We then uniq it to avoid cluttering up the AI with duplicated cover images.
    @bookcontact = self.contacts.first.books if self.contacts.first
    @array        = []
    # First get the contributor id via the HABTM bookcontact relationship.
      @bookcontact.try(:each) do |bookcontact|
        # Get the books by the contributor
        Book.where("publishing_status = ? AND books.id = ?", "04", bookcontact.id).joins(:work => :contract).where('contracts.signed_date is not null').each do |book|
          # Omit the current title and fill the array with hashes of id => x, titlename =>y
            @array << {:id => book.id, :name => book.title} unless book.id == self.id
        end
      end
    get_unique_titlenames(@array)
    #Then in the view, we can iterate through this array of ids.
    return @author_books
  end

  def get_unique_titlenames(array)
    array.uniq! { |e| e[:name] }
    @author_books=[]
    array.each do |a|
      # get the id only in a new array.
      @author_books << a.values_at(:id)
    end
  end

  def self.text_search(query)
    if query.present?
      book_search(query)
    else
      scoped
    end
  end

    def self.get_website_books(client)
      Book.joins(:work => :contract).where('contracts.signed_date is not null').where(:client_id => client.id, :include_on_web => true).includes(:marketingtexts => [:bookmarketingtexts]).includes(:productcodes, :work, :webs, :supportingresources => [:booksupportingresources])
    end

    def self.eager_load_book_assocs(client)
      Book.where(:client_id => client.id).includes(:marketingtexts => [:bookmarketingtexts]).includes(:work => [:contract]).includes(:productcodes, :webs, :supportingresources => [:booksupportingresources])
    end

    def self.change_measures
      Book.all.each do |book|
        book.measurements.each do |measurement|

        if measurement.measurement_unit_id == 3
          measurement.update_column(:measurement_unit_id, 1)
        end
      end
      end
    end

  def contained_item_complete
    not_present = []
    not_present << 1 unless contained_items.first
    contained_items.each do |ci|
      ci.book.productcodes.each do |pc|
        not_present << 1 unless pc.idtype
        not_present << 1 unless pc.idvalue
      end
      not_present << 1 unless ci.item_quantity
    end
    not_present.include?(1) ? false : true

  end



end


