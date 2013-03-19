# == Schema Information
#
# Table name: works
#
#  id                             :integer          not null, primary key
#  registrants_internal_reference :string(255)
#  istc_reference                 :string(255)
#  istc_request_status            :string(255)
#  istc_request_performed_date    :text
#  istc_work_type                 :string(255)
#  origination                    :string(255)
#  derivation_type                :string(255)
#  derivation_note                :string(255)
#  derivation_source_istc         :string(255)
#  istc_title_type                :string(255)
#  title_script                   :string(255)
#  title                          :string(255)
#  subtitle                       :string(255)
#  edition_number                 :string(255)
#  edition_statement              :string(255)
#  work_date_role                 :string(255)
#  work_date_calendar             :string(255)
#  language_of_text               :string(255)
#  istc_registrant_role           :string(255)
#  registrant_id_value            :string(255)
#  registrant_name                :string(255)
#  query_existing_istc            :string(255)
#  preferred_istc                 :string(255)
#  user_id                        :string(255)
#  created_at                     :datetime
#  updated_at                     :datetime
#  contract_id                    :integer
#  work_date                      :date
#  client_id                      :integer
#  status                         :string(255)
#  owner                          :integer
#  main_subject                   :string(255)
#  main_bic_code                  :string(255)
#  main_bisac_code                :string(255)
#  altcontact_id                  :integer
#  books_count                    :integer          default(0), not null
#

# -*- encoding : utf-8 -*-
class Work < ActiveRecord::Base
  include Nextprev
  include Translation
  has_paper_trail
  letsrate_rateable "Title"

  include PgSearch

  pg_search_scope :work_search, against: [:title, :main_bisac_code, :main_subject],
    using: {tsearch: {dictionary: "english"}},
    using: {:tsearch => {:any_word => true}},
    using: {tsearch: {prefix: true}},

    associated_against: {books: [:title, :isbn], contacts: :person_name_inverted, marketingtexts: [:marketing_text, :text_type]}
  multisearchable :against => [:title, :main_bisac_code, :main_subject] , associated_against: {:tags => [:name] }

  strip_attributes

  attr_accessible :altcontact_id                 ,
                  :audiences_attributes          ,
                  :bicgeogsubjects_attributes    ,
                  :bicsubjects_attributes        ,
                  :bisacsubjects_attributes      ,
                  :book_ids                      ,
                  :books_attributes              ,
                  :client_id                     ,
                  :confirmed_contribution        ,
                  :contract_id                   ,
                  :derivation_note               ,
                  :derivation_source_istc        ,
                  :derivation_type               ,
                  :edition_number                ,
                  :edition_statement             ,
                  :foreignrights_attributes      ,
                  :id                            ,
                  :istc_reference                ,
                  :istc_registrant_role          ,
                  :istc_request_performed_date   ,
                  :istc_request_status           ,
                  :istc_title_type               ,
                  :istc_work_type                ,
                  :language_of_text              ,
                  :lifecycledates_attributes     ,
                  :main_bic_code                 ,
                  :main_bisac_code               ,
                  :main_subject                  ,
                  :marketingtexts_attributes     ,
                  :origination                   ,
                  :owner                         ,
                  :preferred_istc                ,
                  :printing_restrictions         ,
                  :prints_attributes             ,
                  :query_existing_istc           ,
                  :registrant_id_value           ,
                  :registrant_name               ,
                  :registrants_internal_reference,
                  :sign_off_meeting_date         ,
                  :skip_contract_sign_off        ,
                  :status                        ,
                  :subjects_attributes           ,
                  :subtitle                      ,
                  :supportingresources_attributes,
                  :title                         ,
                  :title_script                  ,
                  :user_id                       ,
                  :work_date                     ,
                  :work_date_calendar            ,
                  :work_date_role                ,
                  :workcontacts_attributes       ,
                  :non_book_work                 ,
                  :audience_ranges_attributes    ,
                  :schedules_attributes          ,
                  :reprints_attributes

  belongs_to :contract
  has_many :books         , :order => 'title DESC'    , :dependent => :destroy
  has_many :foreignrights                             , :dependent => :destroy
  has_many :contacts      , :through => :workcontacts
  has_many :workcontacts
  has_many :marketingtexts                            , :before_add => :clean_html, :dependent => :destroy
  has_many :bicsubjects                               , :dependent => :destroy
  has_many :bicgeogsubjects                           , :dependent => :destroy
  has_many :bisacsubjects                             , :dependent => :destroy
  has_many :subjects                                  , :dependent => :destroy
  has_many :audiences                                 , :dependent => :destroy
  has_many :supportingresources                       , :dependent => :destroy
  has_many :prints                                    , :dependent => :destroy
  has_many :lifecycledates, as: :lifecycleable
  has_many :book_masterchannels, :through => :books
  has_many :book_channels      , :through => :books
  has_many :book_royalty_specifiers                      , :class_name => 'RoyaltySpecifiers'                   ,:through => :books
  has_many :book_royalty_date_escalators                 , :class_name => 'RoyaltyDateEscalators'               ,:through => :book_royalty_specifiers
  has_many :book_royalty_discount_escalators             , :class_name => 'RoyaltyDiscountEscalators'           ,:through => :book_royalty_specifiers
  has_many :book_royalty_quantity_escalators             , :class_name => 'RoyaltyQuantityEscalators'           ,:through => :book_royalty_specifiers
  has_many :book_royalty_quantity_escalator_channel_rates, :class_name => 'RoyaltyQuantityEscalatorChannelRates',:through => :book_royalty_quantity_escalators
  has_many :audience_ranges
  has_many :schedules, :as => :schedulable, :dependent => :destroy
  has_many :reprints, :dependent => :destroy

  accepts_nested_attributes_for :foreignrights        , :allow_destroy => true
  accepts_nested_attributes_for :contacts
  accepts_nested_attributes_for :books                , :allow_destroy => true
  accepts_nested_attributes_for :workcontacts         , :allow_destroy => true
  accepts_nested_attributes_for :marketingtexts       , :allow_destroy => true
  accepts_nested_attributes_for :bicsubjects          , :allow_destroy => true
  accepts_nested_attributes_for :bicgeogsubjects      , :allow_destroy => true
  accepts_nested_attributes_for :bisacsubjects        , :allow_destroy => true
  accepts_nested_attributes_for :subjects             , :allow_destroy => true
  accepts_nested_attributes_for :audiences            , :allow_destroy => true
  accepts_nested_attributes_for :supportingresources  , :allow_destroy => true
  accepts_nested_attributes_for :prints               , :allow_destroy => true
  accepts_nested_attributes_for :book_masterchannels                          , :allow_destroy => true
  accepts_nested_attributes_for :book_channels                                , :allow_destroy => true
  accepts_nested_attributes_for :book_royalty_specifiers                      , :allow_destroy => true
  accepts_nested_attributes_for :book_royalty_date_escalators                 , :allow_destroy => true
  accepts_nested_attributes_for :book_royalty_discount_escalators             , :allow_destroy => true
  accepts_nested_attributes_for :book_royalty_quantity_escalators             , :allow_destroy => true
  accepts_nested_attributes_for :book_royalty_quantity_escalator_channel_rates, :allow_destroy => true
  accepts_nested_attributes_for :audience_ranges                              , :allow_destroy => true
  accepts_nested_attributes_for :schedules                                    , :allow_destroy => true
  accepts_nested_attributes_for :reprints                                     , :allow_destroy => true

  validates :title      , :presence => true
  validates :client_id  , :presence => true

  after_update :check_that_work_has_contract
  attr_accessor :advance, :advance_total, :payment, :payment_total, :receipt, :receipt_total

  after_create :create_contract
  after_update :check_mkt_text
  before_destroy :update_associated
  before_validation :set_payment_client_ids

  def create_contract
    contract = Contract.new(:work_id => id, :contract_name => title, :royalty_basis => 1, :client_id => client_id)
     if skip_contract_sign_off
       contract.signed_date = Date.today
     end
     contract.save
  end

  def check_mkt_text
    require 'cgi'
    self.marketingtexts.each do |mktg|
      if mktg.marketing_text
        mktg.update_column(:marketing_text, Sanitize.clean(CGI.unescapeHTML(mktg.marketing_text), Sanitize::Config::RESTRICTED))
      end
    end
  end

 def update_associated
   self.marketingtexts.each do |text|
    text.update_column(:soft_delete, DateTime.now)
   end
   # self.contract.destroy
 end

  def clean_html(text)
    require 'cgi'
     require 'htmlentities'
    # puts "running clean up for #{text.marketing_text.inspect}"
    string = CGI.unescapeHTML(text.marketing_text) if text.marketing_text
    if text.marketing_text
      text.marketing_text = Sanitize.clean(string, Sanitize::Config::RESTRICTED)
      text.marketing_text = HTMLEntities.new.decode string
      text.save
    end
  end

  def self.dropdown(current_user)
    Work.unscoped.order('title ASC').where(:client_id => current_user.client_id)
  end

  def contract_formatted_title
    if self.contract_id
      "Already allocated to a contract: #{self.title}"
    else
      "#{self.title}"
    end
  end

  def check_that_work_has_contract
    unless self.contract
      errors.add(:title, "This work proposal has no contract assigned, which means you can't make it live, and you won't be prompted to pay royalties for its editions' sales. <a href='/contracts/new'>Create a contract now</a>.")
    end
  end

  def is_signed_off
    if self.contract
      not self.contract.signed_date.nil?
    end
  end

  def is_over_budget
   if self.confirmed_contribution
     true if self.confirmed_contribution < Client.find(self.client_id).threshold_for_sign_off.to_i
    end
  end

  def is_non_book
    true if self.non_book_work == true
  end

  def self.text_search(query)
      if query.present?
        work_search(query)
      else
        scoped
      end
    end

  def to_s
    "#{title}"
  end

  class << self
  def delete_all_method(edition_import_batch, user)
    Work.where('created_at between ? and ?', edition_import_batch.start_time, edition_import_batch.end_time).where(:client_id => user.client_id).destroy_all
    Contact.where('created_at between ? and ?', edition_import_batch.start_time, edition_import_batch.end_time).where(:client_id => user.client_id).destroy_all
    Seriesname.where('created_at between ? and ?',edition_import_batch.start_time, edition_import_batch.end_time).where(:client_id => user.client_id).destroy_all
    Publishername.where('created_at between ? and ?', edition_import_batch.start_time, edition_import_batch.end_time).where(:client_id => user.client_id).destroy_all
    Imprint.where('created_at between ? and ?', edition_import_batch.start_time, edition_import_batch.end_time).where(:client_id => user.client_id).destroy_all
    Contract.where('created_at between ? and ?', edition_import_batch.start_time, edition_import_batch.end_time).where(:client_id => user.client_id).destroy_all
  end

  handle_asynchronously :delete_all_method
  end

  protected
    def set_payment_client_ids
      self.foreignrights.each do |foreignright|
        foreignright.payments.each do |payment|
          payment.client_id = self.client_id unless self.client_id.nil?
        end
      end
    end

end
