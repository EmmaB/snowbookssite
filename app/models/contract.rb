# == Schema Information
#
# Table name: contracts
#
#  id                                       :integer          not null, primary key
#  work_id                                  :integer
#  user_id                                  :integer
#  created_at                               :datetime
#  updated_at                               :datetime
#  termination_reason                       :string(255)
#  contract_type                            :string(255)
#  signatory                                :string(255)
#  contract_name                            :string(255)
#  territory                                :string(255)
#  free_copies                              :string(255)
#  copyright_year                           :string(255)
#  type                                     :string(255)
#  reserve                                  :string(255)
#  author_discount                          :string(255)
#  remainder_rate                           :string(255)
#  cross_accounting                         :string(255)
#  free_copies_used                         :string(255)
#  statement_frequency                      :string(255)
#  term                                     :string(255)
#  royalty_basis                            :string(255)
#  renewal_date                             :date
#  terminated_date                          :date
#  pub_before_date                          :date
#  signed_date                              :date
#  ms_delivery_date                         :date
#  ms_proofs_date                           :date
#  review_date                              :date
#  first_statement_date                     :date
#  contracttemplate_id                      :integer
#  client_id                                :integer
#  last_statement_date                      :date
#  guaranteed_royalty_value                 :decimal(, )
#  flat_fee_value                           :float
#  contractset_id                           :integer
#  owner                                    :integer
#  add_all_contributors_to_work_to_contract :boolean
#

# -*- encoding : utf-8 -*-
class Contract < ActiveRecord::Base

  include Nextprev
  include Translation
  include PgSearch
  has_paper_trail
  pg_search_scope :contract_search, against: [:contract_name],
    using: {tsearch: {dictionary: "english"}},
    using: {tsearch: {prefix: true}},
    associated_against: {work: [:title, :main_bic_code, :main_bisac_code, :main_subject], contacts: :person_name_inverted}

multisearchable :against => [ :contract_name]
  strip_attributes

  attr_accessible :add_all_contributors_to_work_to_contract,
                  :advances_attributes                     ,
                  :author_discount                         ,
                  :clause_id                               ,
                  :clauses_attributes                      ,
                  :client_id                               ,
                  :contract_attachments_attributes         ,
                  :contract_name                           ,
                  :contract_type                           ,
                  :contractcontributors_attributes         ,
                  :contractset_id                          ,
                  :contracttemplate_id                     ,
                  :contracttemplates_attributes            ,
                  :contacts_attributes                     ,
                  :copyright_year                          ,
                  :cross_accounting                        ,
                  :first_statement_date                    ,
                  :flat_fee_value                          ,
                  :free_copies                             ,
                  :free_copies_used                        ,
                  :guaranteed_royalty_value                ,
                  :id                                      ,
                  :last_statement_date                     ,
                  :masterrules_attributes                  ,
                  :ms_delivery_date                        ,
                  :ms_proofs_date                          ,
                  :next_statement                          ,
                  :owner                                   ,
                  :payments_attributes                     ,
                  :pub_before_date                         ,
                  :remainder_rate                          ,
                  :reserve                                 ,
                  :review_date                             ,
                  :rightrule_id                            ,
                  :rightrules_attributes                   ,
                  :righttypes_attributes                   ,
                  :royalty_basis                           ,
                  :rules_attributes                        ,
                  :signatory                               ,
                  :signed_date                             ,
                  :statement_frequency                     ,
                  :term                                    ,
                  :terminated_date                         ,
                  :termination_reason                      ,
                  :territory                               ,
                  :type                                    ,
                  :user_id                                 ,
                  :work_id                                 ,
                  :works_attributes,
                  :schedules_attributes

  belongs_to :user
  belongs_to :client
  belongs_to :contracttemplate
  belongs_to :contractset

  has_one  :work
  has_many :books         , :through => :work
  has_many :rules         , :through => :masterrules
  has_many :sales         , :through => :books
  has_many :contractcontributors                      , :dependent => :destroy
  has_many :contacts      , :through => :contractcontributors
  has_many :rules              , :through => :masterrules
  has_many :rightrules                                , :dependent => :destroy
  has_many :sales              , :through => :books
  has_many :contacts           , :through => :contractcontributors
  has_many :payments
  has_many :righttypes                                , :dependent => :destroy
  has_many :masterrules                               , :dependent => :destroy
  has_many :advances                                  , :dependent => :destroy
  has_many :contract_attachments                      , :dependent => :destroy
  has_many :schedules, :as => :schedulable, :dependent => :destroy
  accepts_nested_attributes_for :advances             , :allow_destroy => true
  accepts_nested_attributes_for :payments             , :allow_destroy => true
  accepts_nested_attributes_for :contractcontributors , :allow_destroy => true
  accepts_nested_attributes_for :contacts
  accepts_nested_attributes_for :rules                , :allow_destroy => true
  accepts_nested_attributes_for :righttypes           , :allow_destroy => true
  accepts_nested_attributes_for :masterrules          , :allow_destroy => true
  accepts_nested_attributes_for :contract_attachments , :allow_destroy => true
  accepts_nested_attributes_for :schedules , :allow_destroy => true


  validates_presence_of :contract_name    , :unless => "@multiple == true"
  validates_presence_of :royalty_basis    , :unless => "@multiple == true"
  validates_presence_of :work_id          , :unless => "@multiple == true"
  validates_presence_of :client_id        , :unless => "@multiple == true"

  attr_writer :masterchannel
  attr_accessor :contracts_due, :statements_due_now

  after_save  :add_contacts
  after_save  :check_rules_exist
  before_save :set_advances_dates
  before_save :set_next_statement_date
  after_save  :add_contract_id_to_work

  def self.text_search(query)
      if query.present?
        contract_search(query)
      else
        scoped
      end
    end

  def check_rules_exist
    unless self.rules
       errors.add("Warning:", "This work has no rules defined, which means that when you calculate its royalties, the calculation will return zero.")
     end
  end

  # # def work
  #  #   Work.find(self.work_id)
  #  # end
  #
  #  delegate :work,   :to => :work


  def add_contract_id_to_work
    #the has_one association doesn't provide many helper methods including work.contract, so I add the contract_id to work to make life easier.
    #first zap any existing association.
    if work = Work.find_by_contract_id(self.id)
      work.update_column(:contract_id, nil)
      Work.find(self.work_id).update_column(:contract_id, self.id)
    else
      if work = Work.find_by_id(self.work_id)
      work.update_column(:contract_id, self.id)
      end
    end

  end

  def to_s
    contract_name
  end

  def add_contacts
    if self.add_all_contributors_to_work_to_contract==true
      self.work.contacts.each do |contact|
        new_contractcontributor = Contractcontributor.find_or_initialize_by_contact_id(contact.id)
        new_contractcontributor.contact_id = contact.id
        new_contractcontributor.contract_id = self.id
        new_contractcontributor.save
      end
    end
  end

   def steps
     %w[title contributors advances payments accounting rules territories term benefits dates]
   end

   def statements_due_now
        interval = '6' if statement_frequency=='1'
        interval = '12' if statement_frequency !='1'
        result = {}
           # if there hasn't been a statement yet
           if last_statement_date.nil?
             # and if the first statement date is after today and within the month... add it to the array
             unless first_statement_date.nil?
               if first_statement_date >= Date.today && first_statement_date < Date.today + 1.month
                 result = {contract_name => first_statement_date}
               end
             end
           else # if there has been a statement
             if last_statement_date.to_date + interval.to_i.months >= Date.today && last_statement_date.to_date + interval.to_i.months < Date.today + 1.month
               result = {contract_name => last_statement_date + 6.months}
             end
           end
        result
   end

   def self.by_association(assoc)
     Contract.find_by_id(assoc.contract_id).contract_name unless Contract.find_by_id(assoc.contract_id).nil?
   end

   def self.by_work(book)
     Contract.find_by_work_id(book.work_id) unless Contract.find_by_work_id(book.work_id).nil?
   end

   def self.by_name(name)
     Contract.find_by_contract_name(name) unless Contract.find_by_contract_name(name).nil?
   end



  def set_advances_dates
    if signed_date_changed?
      advances.where(:trigger => "On signature").each do |advance|
        advance.update_column(:due_date, signed_date)
      end
    end
    if ms_delivery_date_changed?
      advances.where(:trigger => "On delivery").each do |advance|
        advance.update_column(:due_date, ms_delivery_date)
      end
    end
  end

  def set_next_statement_date
    if last_statement_date_changed?
      if statement_frequency == '1'
        update_column(:next_statement, last_statement_date + 6.months) if last_statement_date
      else
        update_column(:next_statement, last_statement_date + 12.months) if last_statement_date
      end
    end
    if first_statement_date_changed? and last_statement_date.blank?
      if statement_frequency == '1'
        update_column(:next_statement, first_statement_date + 6.months)
      else
        update_column(:next_statement, first_statement_date + 12.months)
      end
    end
  end


end
