# == Schema Information
#
# Table name: bookcontacts
#
#  id               :integer          not null, primary key
#  created_at       :datetime
#  updated_at       :datetime
#  contact_id       :integer
#  book_id          :integer
#  sequence_number  :string(255)
#  contributor_role :string(255)
#  client_id        :integer
#  workcontact_id   :integer
#  work_id          :integer
#

# -*- encoding : utf-8 -*-
class Bookcontact < ActiveRecord::Base
  include Translation

  attr_accessible :contact_id, :book_id, :sequence_number, :contributor_role, :client_id, :workcontact_id, :contact_role_id, :work_id
  attr_accessor :contact

  belongs_to :book
  belongs_to :workcontact
  # acts_as_audited :associated_with => :book
  after_save :update_default_contrib

  def update_default_contrib
    if book = Book.find_all_by_id(self.book_id).first 
      if self.workcontact
        if contact = self.workcontact.contact
        default_contributor_first_name = contact.names_before_key
        default_contributor_last_name  = contact.keynames 
        end

        if altcon = self.workcontact.altcontact_id
          # make default contrib the selected alias
          default_contributor_first_name = Altcontact.find(altcon).names_before_key
          default_contributor_last_name  = Altcontact.find(altcon).keynames 
        end
      
        defaultcontribseq = self.sequence_number
        if defaultcontribseq=="1" || defaultcontribseq.blank?
          book.update_attributes(:default_contributor_first_name => default_contributor_first_name,
                                 :default_contributor_last_name  => default_contributor_last_name)
        end
      end      
    end
  end
  
  #Do Not Run - one off method to make subjects belong to Work, not Book. 
  def self.add_work_id_to_bookcontact_table
    bookcontacts = Bookcontact.all
    bookcontacts.each do |bookcontact|
      begin 
        bookcontact.update_attributes(:work_id => Book.find(bookcontact.book_id).work.id) 
      rescue
        "not found"
      end
    end  
  end 
  
  #Do Not Run - one off method to populate HABTM join table. 
  def self.populate_workcontact_table
    Bookcontact.all.each do |bookcontact|
      new_join_table_record = Workcontact.new(:book_id => bookcontact.book_id, :work_id => bookcontact.work_id, :bookcontact_id => bookcontact.id, 
                                              :contact_id => bookcontact.contact_id, :sequence_number => bookcontact.sequence_number, 
                                               :work_contact_role => bookcontact.contributor_role, :client_id => bookcontact.client_id)
      new_join_table_record.save
    end
  end
  

  
end

