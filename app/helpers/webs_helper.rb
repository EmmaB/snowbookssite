# -*- encoding : utf-8 -*-
module WebsHelper 
  
  # ISBN10_ONIX_CODE = '02'
  AMAZON_ROOT_URL = 'http://www.amazon.co.uk/exec/obidos/ASIN/'
  AMAZON_MIDDLE_URL = '/ref=nosim/'

  # def amazon_url_helper(book, company) 
  #   book10_record = book.where(:idtype => ISBN10_ONIX_CODE).first
  #   unless book10_record.nil?
  #     AMAZON_ROOT_URL + book10_record.idvalue + AMAZON_MIDDLE_URL + company.text( :amazon_associates_id )
  #   end
  # end
  
  def amazon_url_helper(book, company) 
    begin
    book10 = ISBN.ten(book.isbn)
    rescue
      return
    end
    if company.text( :amazon_associates_id ).nil?
      co_text = "bibliocloud21"
    else
      co_text = company.text( :amazon_associates_id )
    end
    unless book10.nil? 
      AMAZON_ROOT_URL + book10 + AMAZON_MIDDLE_URL + co_text
    end
  end
    
  def get_contributor_details(book)
    contributor_details = []
    bio_note = Marketingtext.get_text(@web.book, :bio)
    if bio_note.empty?
      book.contacts.each do |contrib|
        contrib_dossier = {}
        contrib_dossier[:bio] = contrib.biographical_note
        contrib_dossier[:name] = contrib.names_before_key + ' ' + contrib.keynames if contrib.keynames and contrib.names_before_key
        contributor_details << contrib_dossier
      end
    else
      contrib_dossier = {}
      contrib_dossier[:bio] = bio_note
      contrib_dossier[:name] = book.default_contributor_first_name + ' ' + book.default_contributor_last_name if book.default_contributor_last_name and book.default_contributor_first_name
      contributor_details << contrib_dossier
    end                             
    contributor_details
  end
    

    
end


