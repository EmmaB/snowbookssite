# == Schema Information
#
# Table name: contacts
#
#  id                                  :integer          not null, primary key
#  person_name_inverted                :string(255)
#  titles_before_names                 :string(255)
#  names_before_key                    :string(255)
#  keynames                            :string(255)
#  corporate_name                      :string(255)
#  created_at                          :datetime
#  updated_at                          :datetime
#  cross_accounting                    :string(255)
#  client_id                           :integer
#  alternative_name_type               :string(255)
#  alternative_names_before_key        :string(255)
#  alternative_key_names               :string(255)
#  contributor_type                    :string(255)
#  association_type                    :string(255)
#  assoc_contributor_id                :integer
#  user_id                             :integer
#  biographical_note                   :text
#  last_statement_date                 :date
#  sort_code                           :string(255)
#  account_number                      :string(255)
#  account_name                        :string(255)
#  bank_name                           :string(255)
#  bank_address_one                    :string(255)
#  bank_address_two                    :string(255)
#  bank_address_three                  :string(255)
#  bank_address_four                   :string(255)
#  swift_code                          :string(255)
#  routing                             :string(255)
#  set_as_default_address              :boolean
#  preferred_time_for_phone_interviews :string(255)
#  place_of_birth                      :string(255)
#  citizenship                         :string(255)
#  children                            :boolean
#  reader_questions                    :text
#  suggestions_for_back_matter         :text
#  suggestions_for_cover               :text
#  owner                               :integer
#  keyname_prefix                      :string(255)
#  name_after_keyname                  :string(255)
#  suffix_after_keyname                :string(255)
#  qualification_after_keyname         :string(255)
#  titles_after_names                  :string(255)
#  date_of_birth                       :date
#  person_name                         :string(255)
#

# -*- encoding : utf-8 -*-
class Contact < ActiveRecord::Base
  include Nextprev
  include Translation
  has_paper_trail

  strip_attributes
  acts_as_taggable

  attr_accessible :account_name                       ,
                  :account_number                     ,
                  :addresses_attributes               ,
                  :altcontacts_attributes             ,
                  :alternative_key_names              ,
                  :alternative_name_type              ,
                  :alternative_names_before_key       ,
                  :assoc_contact_id                   ,
                  :assoc_contributor_id               ,
                  :association_type                   ,
                  :bank_address_four                  ,
                  :bank_address_one                   ,
                  :bank_address_three                 ,
                  :bank_address_two                   ,
                  :bank_name                          ,
                  :biographical_note                  ,
                  :bookcontacts_attributes            ,
                  :books_attributes                   ,
                  :children                           ,
                  :citizenship                        ,
                  :client_id                          ,
                  :contact_roles_attributes           ,
                  :contact_type_ids                   ,
                  :contactfeatures_attributes         ,
                  :contract_id                        ,
                  :contractcontributors_attributes    ,
                  :contracts_attributes               ,
                  :contributor_type                   ,
                  :contributorrole                    ,
                  :corporate_name                     ,
                  :cost_per_kilo                      ,
                  :cost_per_pallet                    ,
                  :cross_accounting                   ,
                  :currency_id                        ,
                  :date_of_birth                      ,
                  :default_shipping_instructions      ,
                  :emails_attributes                  ,
                  :id                                 ,
                  :keyname_prefix                     ,
                  :keynames                           ,
                  :last_statement_date                ,
                  :logins_attributes                  ,
                  :name_after_keyname                 ,
                  :names_before_key                   ,
                  :owner                              ,
                  :payments_attributes                ,
                  :person_name                        ,
                  :person_name_inverted               ,
                  :phones_attributes                  ,
                  :place_of_birth                     ,
                  :preferred_time_for_phone_interviews,
                  :qualification_after_keyname        ,
                  :reader_questions                   ,
                  :relationships_attributes           ,
                  :routing                            ,
                  :set_as_default_address             ,
                  :sort_code                          ,
                  :suffix_after_keyname               ,
                  :suggestions_for_back_matter        ,
                  :suggestions_for_cover              ,
                  :supportingresources_attributes     ,
                  :swift_code                         ,
                  :tag_list                           ,
                  :titles_after_names                 ,
                  :titles_before_names                ,
                  :twitter_name_                      ,
                  :user_id                            ,
                  :works_attributes                   ,
                  :creator_1_id                       ,
                  :creator_2_id                       ,
                  :creator_3_id                       ,
                  :web_links_attributes               ,
                  :schedules_attributes

  include PgSearch
  pg_search_scope :contact_search, against: [:person_name_inverted, :keynames, :names_before_key],
    using: {tsearch: {dictionary: "english"}},
    using: {tsearch: {prefix: true}},
     associated_against: {:tags => [:name] }

  multisearchable :against =>  [:person_name_inverted, :keynames, :names_before_key],    associated_against: {:tags => [:name] }

  def self.text_search(query)
      if query.present?
        contact_search(query)
      else
        scoped
      end
    end

  has_many :works                 , :through => :workcontacts
  has_many :workcontacts                                                      , :dependent => :destroy
  has_many :contracts             , :through => :contractcontributors
  has_many :contractcontributors
  has_many :addresses                                                         , :dependent => :destroy
  has_many :phones                                                            , :dependent => :destroy
  has_many :emails                                                            , :dependent => :destroy
  has_many :contactfeatures                                                   , :dependent => :destroy
  has_many :deliveries                                                        , :dependent => :destroy
  has_many :logins                                                            , :dependent => :destroy
  has_many :bookcontacts          , :through => :workcontacts                 , :dependent => :destroy
  has_many :books                 , :through => :bookcontacts
  has_many :altcontacts                                                       , :dependent => :destroy
  has_many :contact_types         , :through => :contact_contact_types        , :dependent => :destroy
  has_many :contact_contact_types                                             , :dependent => :destroy
  has_many :catalogue_template_contacts
  has_many :catalogue_templates   , :through => :catalogue_template_contacts
  has_many :royalty_liabilities
  has_many :finance_codes
  has_many :foreignrights
  has_many :contact_prints
  has_many :prints, :through => :contact_prints
  has_many :print_costings
  has_many :supportingresources, as: :resourceable, :dependent => :destroy
  has_many :royarchives
  has_many :copy_trackers
  has_many :relationships
  has_many :relations, :through => :relationships
  has_many :payments
  has_many :advances
  has_many :web_links, as: :linkable                          , :dependent => :destroy
  has_many :schedules, :as => :schedulable                    , :dependent => :destroy


  accepts_nested_attributes_for :logins                 , :allow_destroy => true
  accepts_nested_attributes_for :contractcontributors   , :allow_destroy => true
  accepts_nested_attributes_for :workcontacts           , :allow_destroy => true
  accepts_nested_attributes_for :contact_types          , :allow_destroy => true
  accepts_nested_attributes_for :contact_contact_types  , :allow_destroy => true
  accepts_nested_attributes_for :contracts              , :allow_destroy => true
  accepts_nested_attributes_for :emails                 , :allow_destroy => true
  accepts_nested_attributes_for :addresses              , :allow_destroy => true
  accepts_nested_attributes_for :phones                 , :allow_destroy => true
  accepts_nested_attributes_for :contactfeatures        , :allow_destroy => true
  accepts_nested_attributes_for :altcontacts            , :allow_destroy => true
  accepts_nested_attributes_for :works                  , :allow_destroy => true
  accepts_nested_attributes_for :bookcontacts           , :allow_destroy => true
  accepts_nested_attributes_for :supportingresources    , :allow_destroy => true
  accepts_nested_attributes_for :relationships          , :allow_destroy => true
  accepts_nested_attributes_for :web_links              , :allow_destroy => true
  accepts_nested_attributes_for :schedules              , :allow_destroy => true

  # acts_as_audited
  before_save :person_name_set
  after_save :person_name_inverted_set
  after_save :flag_duplicates
  validates :client_id          , :presence => true
  validate :at_least_one_name

  def to_s
    "#{names_before_key} #{keynames} #{corporate_name}"
  end

  def person_name_inverted_set
    if self.contributor_type.blank?
      self.update_column(:contributor_type, "Person")
    end

    unless self.person_name_inverted
      if self.person_name
        self.update_column(:person_name_inverted, "#{person_name.match(/\ \w+/)}, #{person_name.match(/\w+\ /)}" )
      end
    end
  end

  def flag_duplicate_name
    true if Contact.find(:first, :conditions => ['client_id = ? and lower(person_name_inverted) = ? and id != ?', self.client_id, self.person_name_inverted.try(:downcase), self.id])

  end

  def flag_duplicate_corporate_name
    true if Contact.where('client_id = ? and corporate_name = ? and id != ?', self.client_id, self.corporate_name, self.id).first
  end

  def flag_duplicates
    if Contact.find(:first, :conditions => ['client_id = ? and lower(person_name_inverted) = ? and id != ?', self.client_id, self.person_name_inverted.try(:downcase), self.id])
      dupe = true
    elsif Contact.where('client_id = ? and corporate_name = ? and id != ?', self.client_id, self.corporate_name, self.id).first
      dupe = true
    else
      dupe = false
    end
    errors.add(:biographical_note, "This contact's name isn't unique. You can have contacts with the same name, but make sure you're referring to the right one when you use this record."  ) if dupe == true

  end

  def at_least_one_name
    puts "size is #{[self.keynames, self.corporate_name, self.person_name].compact.size }"
    if [self.keynames, self.corporate_name, self.person_name].compact.size == 0
      errors[:base] << "You must enter at least one of a last name, person name or corporate name"
    end
  end

  def self.person_name(model)
    if model.contact_id
      Contact.find(model.contact_id).person_name_inverted unless Contact.find(model.contact_id).nil?
    end
  end

  # used in dropdown on royalty statements
  def name_plus_date
    "#{self.person_name_inverted} (#{self.last_statement_date})"
  end

  # Scope used in drop down menus on various forms.
  def self.dropdown(current_user)
    Contact.order("keynames ASC").where(:client_id => current_user.client_id)
  end

  def age_calc
    # from http://stackoverflow.com/questions/819263/get-persons-age-in-ruby
    dob   = self.date_of_birth.to_date
    now   = Time.now.utc.to_date
     now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
    # 2012 - 1974 - ((05 > 10 || 05 == 10 and 7 gte 03 ))
  end

  def self.advance_contributor(advance)
    Contact.find_by_id(advance.contact_id)
  end

  def self.by_association(assoc)
    Contact.find_by_id(assoc.contact_id) unless Contact.find_by_id(assoc.contact_id).nil?
  end

  def self.royalty_contribs(current_user)
    Contact.where(:client_id => current_user.client_id).joins(:contact_types).where("contact_types.include_on_statements = ? ", true)
  end

  def self.sale_contribs(current_user)
    Contact.where(:client_id => current_user.client_id).joins(:contact_types).where("contact_types.category = ?", "Seller")
  end

  def self.get_altcontact(contact_id)
    Contact.find(contact_id).altcontacts.first
  end

  def self.by_type(code, current_user)
    Contact.joins(:contact_types).where(:client_id => current_user.client_id).where("contact_types.name = ?", code).order("keynames ASC").order("corporate_name ASC")
  end

  def is_an_author(current_user)
    true if self.contact_types.where('name = ?', "Book contributor").first
  end

  private
    def person_name_set
      if self.keynames.blank?
        self.person_name_inverted = self.corporate_name
      else
        self.person_name_inverted = ("#{self.keynames}, #{self.names_before_key}")
      end
    end

end
