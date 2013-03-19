# == Schema Information
#
# Table name: supportingresources
#
#  id                    :integer          not null, primary key
#  resource_content_type :string(255)
#  content_audience      :string(255)
#  resource_mode         :string(255)
#  resource_form         :string(255)
#  resource_link         :string(255)
#  book_id               :integer
#  created_at            :datetime
#  updated_at            :datetime
#  image_file_name       :string(255)
#  image_content_type    :string(255)
#  image_file_size       :integer
#  image_remote_url      :string(255)
#  client_id             :integer
#  user_id               :integer
#  image_meta            :text
#  work_id               :integer
#

# -*- encoding : utf-8 -*-
require 'open-uri'
require "aws/s3"
class Supportingresource < ActiveRecord::Base
  include Nextprev
  include Defaultimage
  has_paper_trail

  attr_accessible :book_ids, :content_audience, :resource_mode , :resource_form, :resource_link,
 :book_id, :image_file_name, :image_content_type, :image_file_size, :image_remote_url,
 :client_id, :user_id, :image_meta, :work_id, :image_url, :resource_content_type, :image, :id, :resourceable_id, :resourceable_type, :marketingtext_id, :copyright_owner, :software_used


 belongs_to  :work
 has_many    :books                     , :through => :booksupportingresources
 has_many    :booksupportingresources                                             , :dependent => :destroy
 belongs_to  :resourceable  , :polymorphic => true

  scope :lookup, lambda {|book| where("book_id = ?", book)}

  # validates_uniqueness_of :book && :resource_content_type
  attr_accessor :image_url, :url
  alias_attribute :res_link, :resource_link

  has_attached_file :image,
                    :styles         => {
                    :thumb => "250x158",
                    :small => "400x400>"},
                    # s3 code from here: http://doganberktas.com/2010/09/14/amazon-s3-and-paperclip-rails-3/
                    # and from here: http://techspry.com/ruby_and_rails/amazons-s3-european-buckets-and-paperclip-in-rails-3/
                    :storage        => :s3,
                    :s3_credentials => "#{Rails.root}/config/s3.yml",
                    :s3_protocol    => "https",
                    :s3_host_name   => "s3-eu-west-1.amazonaws.com",
                    # :path           => ":class/:id/:basename_:style.:extension",
                    :path           => ":client_id/:id/:isbn_no/:isbn_no_:style.:extension",
                    :bucket         => "bibliocloudimages",
                    # :url            => ":s3_eu_url",
                    :default_url    => BLANK_COVER_URL,
                    :use_timestamp  => false

  before_validation :download_remote_image, :if => :image_url_provided?
  validates_presence_of :image_remote_url, :if => :image_url_provided?, :message => 'is invalid or inaccessible'
  validates_attachment_size :image, :less_than=>2.megabytes
  validates :image_url, :length => { :maximum => 254 }

  after_save :check_for_correct_format_if_cover_image
  process_in_background :image

  def check_for_correct_format_if_cover_image
    if self.resource_content_type == "07"
      unless ["image/jpg", "image/png", "image/jpeg", "image/gif"].include?(self.image_content_type)
        errors.add(:image_content_type, I18n.t(:wrong_image_format, :scope => [:works, :supportingresources]) )
      end
    end
  end

  def picture_from_url(url)
      self.image = open(url)
  end

  # possibly superfluous method (thanks to paperclip-meta's image.url) to fetch the S3 URL for a front cover image
  # em: not supefluous as this method calls the nice default image
  #em: weirdly, the constant BLANK_COVER_URL was being reset so have hard coded the url here to fix.
  def self.front_cover(work, size = :thumb)
    resources = work.supportingresources.where(:resource_content_type => SYSTEM_COVER)
    resources.last.image.url(:thumb)
  end


  def self.front_cover_original(book, size = :thumb)
    resources = book.supportingresources.where(:resource_content_type => SYSTEM_COVER)
    return { :url => "https://s3-eu-west-1.amazonaws.com/bibliocloudimages/static/thumb/missing.png"} if resources.blank?
    resources.last.front_cover(size)
  end


# this method from http://trevorturk.com/2008/12/11/easy-upload-via-url-with-paperclip/#idc-cover


  def image_url_provided?
    !self.image_url.blank?
  end

  def download_remote_image
    self.image            = do_download_remote_image
    self.image_remote_url = image_url
    #Rob: currently, even if nothing gets downloaded from the input URL, a record is written to the database...
    # ...perhaps if this method returns nil when nothing is fetched then the save will fail
    self.image
  end

  def do_download_remote_image
    io = open(URI.parse(image_url))

    def io.original_filename;
      base_uri.path.split('/').last;
    end

    io.original_filename.blank? ? nil : io
    rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end

  # added to allow use of ISBN no in url
  #eb: amended apr 12 when files moved to belong to work
  Paperclip.interpolates :isbn_no  do |attachment, style|
    attachment.instance.work_id
  end

  # added to allow use of client_id in url
  Paperclip.interpolates :client_id  do |attachment, style|
    attachment.instance.client_id
  end

  def self.book(author_book)
    Supportingresource.find_all_by_book_id(author_book).last
  end

  def picture_from_url(url)
    self.image = open(url)
  end

  def authenticated_url(style = nil, expires_in = 90.minutes)
    image.s3_object.url_for(:read, :secure => true, :expires => expires_in).to_s
  end

  def to_s
    "#{work.title} #{image_file_name}"
  end

end

