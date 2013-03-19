# -*- encoding : utf-8 -*-
module Defaultimage
  SYSTEM_COVER = '07'
  BLANK_COVER_URL = "https://s3-eu-west-1.amazonaws.com/bibliocloudimages/static/thumb/missing.png"
  BLANK_COVER_SIZE = "100x158"
  DEFAULT_COVER_DETAILS = { :url => BLANK_COVER_URL, :size => BLANK_COVER_SIZE}
  
  def front_cover(size = :thumb)
    # prepare a blank hash to return in case some details are unavailable
    return DEFAULT_COVER_DETAILS if self.image.nil?
    cover_details = DEFAULT_COVER_DETAILS
    #uses Paperclip to fetch the image's URL
    cover_details[:url] = self.image.url(size)
    #fetches the :size hash using the paperclip-meta functionality
    cover_details[:size] = self.image.image_size(size) 
    # Paperclip will return the 'default url' if no image is found. Need to provide a size for that image.
    cover_details[:size] = BLANK_COVER_SIZE if cover_details[:url] == BLANK_COVER_URL
    cover_details
  end
  
  
  #==========================================================================================================
  #The  methods below are tucked away in this module to stop them from cluttering up the supporting resource model class. They are one off methods which should no longer be required, but it's nice to keep them somewhere just in case.  
  #==========================================================================================================
  
  # Do Not Run. Well, you can run it, but it's intended to be more or less a one-off, probably run from the console which re-uplaods...
  # ...all the cover images to S3 so that we can change the URL/image location scheme and then make all the images available again on S3
  # EM: had to run this again when I accidentally deleted a bunch of images from localhost. I deleted a page of books when testing edit_multiple, 
  # but forgot that this would delete the live site images... dur. I've changed the Book find to suit that sitution - rather than fetch all books for client_id 1.
  # I had to pull down the db from heroku too, to replace the delete books, otherwise there was no book_id to match on. 
  def self.refresh_all_images
    input_url_template = 'https://s3-eu-west-1.amazonaws.com/bibliocloudimages/1/x/x_original.jpg'
    snowbooks_client_id = 1
    Book.where('client_id = ?', 1).each do |book|
      input_url = input_url_template.gsub(%r{x}, book.isbn.to_s)
        new_sr = Supportingresource.new(:client_id => snowbooks_client_id,
                                      :image_url => input_url,
                                      :resource_content_type => "07",
                                      :book_id => book.id, 
                                      :work_id => book.work.id
                                      )
        puts "[refresh_all_images: save/upload failed for #{book}: #{input_url} ]" if not new_sr.save
        
        book.work.books.each do |eachbook|                            
        new_booksupportingres = Booksupportingresource.new(:book_id => eachbook.id,
                                                           :supportingresource_id => new_sr.id)
        new_booksupportingres.save                                                   
      end

        
        puts "about to save: #{new_sr.inspect}"
    end
  end
    
  #Do Not Run. This is a one-off (hopefully) temp fix that nicks cover images from other books in the same ISTC. 
  def self.borrow_missing_images
    Book.where(:client_id => 1).each do |book|
      sr_to_check = book.supportingresources.last
      next if sr_to_check.blank?
      if sr_to_check.image_file_name.blank?
        work = book.work
        next if work.nil?
        work.books.each do |sister_bk|
          next if sister_bk == book
          sister_sr = sister_bk.supportingresources.where(:resource_content_type => SYSTEM_COVER).last
          unless sister_sr.nil? || sister_sr.image_file_name.blank?
            new_sr = sister_sr.dup
            new_sr.book = book
            if book.save
              sr_to_check.delete
              puts "[borrow_missing_images: #{book.isbn} needs its own image]"
            end
          end
        end
      end
    end
  end

  def self.find_borrowed_images
    srs_needing_covers = []
    fields_wanted = ['resource_link', 'book_id']
    where(:resource_content_type => SYSTEM_COVER, :client_id => 1).select(fields_wanted).each do |sr|
      next if sr.res_link.blank? || sr.book.nil?
      isbn = sr.book.isbn
      srs_needing_covers << isbn if sr.res_link.gsub(%r{.*([0-9xX]{13}).jpg}, '\1'  ) != sr.book.isbn
    end
    srs_needing_covers.each {|line| puts line}
  end
  
  #Do Not Run - one off method to make supportingresource belong to Work, not Book. 
  def self.add_work_id_to_supres_table
    supportingresources = Supportingresource.all
    supportingresources.each do |supportingresource|
      begin 
        supportingresource.update_attributes(:work_id => Book.find(supportingresource.book_id).work.id) 
      rescue
        "not found"
      end
    end  
  end 
  
  #Do Not Run - one off method to populate HABTM join table. 
  def self.populate_booksupportingresource_table
    Supportingresource.all.each do |supportingresource|
      new_join_table_record = Booksupportingresource.new(:book_id => supportingresource.book_id, :supportingresource_id => supportingresource.id)
      new_join_table_record.save
    end
  end

  
  
end
