# == Schema Information
#
# Table name: clients
#
#  id              :integer          not null, primary key
#  client_name     :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  webname         :string(255)
#  use_default_css :boolean
#

# -*- encoding : utf-8 -*-
class Client < ActiveRecord::Base
  has_paper_trail

  include Nextprev
  strip_attributes

  include PgSearch
  pg_search_scope :client_search, against: [:client_name],
    using: {tsearch: {dictionary: "english"}},
    using: {tsearch: {prefix: true}}
  def self.text_search(query)
    if query.present?
      client_search(query)
    else
      scoped
    end
  end


  attr_accessible :client_name    ,
                  :created_at     ,
                  :updated_at     ,
                  :webname        ,
                  :use_default_css,
                  :acts_as_group,
                  :client_groups_attributes,
                  :oauth_token_twitter,
                  :oauth_token_secret_twitter,
                  :consumer_key_twitter,
                  :consumer_secret_twitter,
                  :threshold_for_sign_off

  has_many :users     , :dependent => :destroy
  has_many :channels  , :dependent => :destroy
  has_many :webs      , :dependent => :destroy
  has_many :contracts , :dependent => :destroy
  has_many :works     , :through => :contracts, :dependent => :destroy
  has_many :posts     , :dependent => :destroy

  has_many :groups, :through => :client_groups
  has_many :client_groups, :dependent => :destroy
  has_many :imprints, :dependent => :destroy
  has_many :importisbncsvs, :dependent => :destroy
  has_many :publishernames, :dependent => :destroy

  has_one   :company
  accepts_nested_attributes_for :client_groups
  accepts_nested_attributes_for :imprints
  accepts_nested_attributes_for :importisbncsvs
  accepts_nested_attributes_for :publishernames


  #we don't want more than one client using the same subdomain
  validates :webname      ,  :uniqueness => true
  validates :client_name  ,  :uniqueness => true

  after_create :create_company
  after_create :create_basic_currencies_data
  after_create :create_basic_contract_data
  after_create :create_basic_period_data
  after_create :create_basic_channel_data

  def create_company
    newcompany            = Company.new
    newcompany.client_id  = self.id
    newcompany.sender_name = self.client_name.titlecase
    newcompany.category_scheme_preference = I18n.t(:category_scheme_preference)
    newcompany.royalty_statement_copy_one   = I18n.t(:royalty_statement_copy_one)
    newcompany.royalty_statement_copy_two   = I18n.t(:royalty_statement_copy_two)
    newcompany.royalty_statement_copy_four  = I18n.t(:royalty_statement_copy_four)
    newcompany.royalty_statement_copy_six   = I18n.t(:royalty_statement_copy_six)
    newcompany.royalty_statement_copy_seven = I18n.t(:royalty_statement_copy_seven)
    newcompany.royalty_statement_copy_eight = I18n.t(:royalty_statement_copy_eight)
    newcompany.royalty_statement_copy_nine  = I18n.t(:royalty_statement_copy_nine)
    newcompany.text1  = I18n.t(:text1)
    newcompany.text2  = I18n.t(:text2)
    newcompany.text9  = I18n.t(:text9)
    newcompany.text8  = I18n.t(:text8)
    newcompany.text11 = I18n.t(:text11)
    newcompany.text12 = I18n.t(:text12)
    newcompany.text13 = I18n.t(:text13)
    newcompany.text3  = I18n.t(:text3)
    newcompany.text4  = I18n.t(:text4)
    newcompany.text5  = I18n.t(:text5)
    newcompany.text6  = I18n.t(:text6)
    newcompany.text7  = I18n.t(:text7)
    newcompany.text21 = I18n.t(:text21)
    newcompany.save(:validate => false)
  end


  def create_basic_currencies_data
    Currency.create!(:client_id => self.id, :currencycode => "USD", :exchange_rate_to_base => "1", :base_currency => true, :default_currency => true, :currency_symbol => "$")
  end

  def create_basic_contract_data
  number_of_clauses_to_create = Array.new(31){|i| i + 1}

  work     = Work.create!(:client_id => self.id, :title => "Bibliocloud sample work")
  book     = Book.create!(:client_id => self.id, :title => "Bibliocloud sample book", :work_id => work.id, :isbn => "9781905005123", :include_on_web => true)
  cover   = Supportingresource.create!(:client_id => self.id, :work_id => work.id, :image_url => "https://s3-eu-west-1.amazonaws.com/bibliocloudimages/static/sample.jpg", :resource_content_type => "07") unless Rails.env.test?
  bookcover = Booksupportingresource.create!(:book_id => book.id, :supportingresource_id => cover.id) unless Rails.env.test?
  contract = Contract.create!(:client_id => self.id, :contract_name => "Bibliocloud sample contract", :work_id => work.id, :royalty_basis => "1")
  work.update_attributes(:contract_id => contract.id)
  template = Contracttemplate.create!(:client_id => self.id, :template_name => "Bibliocloud sample contract template")
    number_of_clauses_to_create.each do |iteration|
      numbered_clause_text     = "clause_#{iteration}_text"
      numbered_clause_heading  = "clause_#{iteration}_heading"
      clause_number   = Clause.create!(:client_id => self.id, :clause_text => I18n.t(numbered_clause_text), :clause_heading => I18n.t(numbered_clause_heading) )
      Clausetype.create!(:client_id => self.id, :clause_id => clause_number.id, :contracttemplate_id => template.id)
    end

  contact = Contact.create!(:client_id => self.id, :corporate_name => "Bibliocloud")
  workcontact = Workcontact.create!(:client_id => self.id, :contact_id => contact.id, :work_id => work.id, :work_contact_role => "A01", :sequence_number => "1")
  bookcontact = Bookcontact.create!(:client_id => self.id, :book_id => book.id, :workcontact_id => workcontact.id)
  contractcontrib = Contractcontributor.create!(:client_id => self.id, :contact_id => contact.id, :contract_id => contract.id)
  contact_contact_type = ContactContactType.create!(:contact_id => contact.id, :contact_type_id => 6)
  end


  def create_basic_period_data
  Period.create!(:client_id => self.id, :startdate => '01/01/2012', :enddate => '31/12/2012', :currentperiod => true, :name => 'Calendar year 2012')
  end

  def create_basic_channel_data
    masterchannel = Masterchannel.create!(:client_id => self.id, :masterchannel_name => "UK")
    channel_one = Channel.create!(:client_id => self.id, :channel_name => "UK Home")
    channel_two = Channel.create!(:client_id => self.id, :channel_name => "UK Gratis")
    Channeltype.create!(:client_id => self.id, :channel_id => channel_one.id, :masterchannel_id => masterchannel.id)
    Channeltype.create!(:client_id => self.id, :channel_id => channel_two.id, :masterchannel_id => masterchannel.id)
  end

  def self.by_association(assoc)
    Client.find_by_id(assoc.client_id).client_name unless Client.find_by_id(assoc.client_id).nil?
  end

  def to_s
    "#{client_name.titlecase}"
  end

  def sign_in_to_twitter
    begin
    # Twitter::Client.new(
    #   :consumer_key => self.consumer_key_twitter,
    #   :consumer_secret => self.consumer_secret_twitter,
    #   :oauth_token => self.oauth_token_twitter,
    #   :oauth_token_secret => self.oauth_token_secret_twitter
    # )
    Twitter.consumer_key = self.consumer_key_twitter
    Twitter.consumer_secret = self.consumer_secret_twitter
    Twitter.oauth_token = self.oauth_token_twitter
    Twitter.oauth_token_secret = self.oauth_token_secret_twitter
    rescue
      return
    end
  end


end





