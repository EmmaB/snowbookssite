# == Schema Information
#
# Table name: companies
#
#  id                            :integer          not null, primary key
#  user_id                       :integer
#  sender_name                   :string(255)
#  contact_name                  :string(255)
#  email_address                 :string(255)
#  addressee_name                :string(255)
#  message_note                  :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  text1                         :text
#  text2                         :text
#  text3                         :text
#  text4                         :text
#  text5                         :text
#  text6                         :text
#  text7                         :text
#  text8                         :text
#  text9                         :text
#  text10                        :text
#  client_id                     :integer
#  text11                        :text
#  text12                        :text
#  text13                        :text
#  text14                        :text
#  text15                        :text
#  text16                        :text
#  text17                        :text
#  text18                        :text
#  text19                        :text
#  text20                        :text
#  text21                        :text
#  text22                        :text
#  text23                        :text
#  text24                        :text
#  text25                        :text
#  text26                        :text
#  text27                        :text
#  text28                        :text
#  text29                        :text
#  text30                        :text
#  default_currency              :string(255)
#  default_language              :string(255)
#  category_scheme_preference    :string(255)
#  royalty_statement_copy_one    :text
#  royalty_statement_copy_two    :text
#  royalty_statement_copy_three  :text
#  royalty_statement_copy_four   :text
#  royalty_statement_copy_five   :text
#  royalty_statement_copy_six    :text
#  royalty_statement_copy_seven  :text
#  royalty_statement_copy_eight  :text
#  royalty_statement_copy_nine   :text
#  royalty_statement_copy_ten    :text
#  royalty_statement_copy_eleven :text
#  nielsen_login                 :string(255)
#  nielsen_password              :string(255)
#  nielsen_data_last_sent        :date
#  nielsen_images_last_sent      :date
#  bowker_login                  :string(255)
#  bowker_password               :string(255)
#  bowker_data_last_sent         :date
#  bowker_images_last_sent       :date
#  amazoncouk_login              :string(255)
#  amazoncouk_password           :string(255)
#  amazoncouk_data_last_sent     :date
#  amazoncouk_images_last_sent   :date
#  bds_login                     :string(255)
#  bds_password                  :string(255)
#  bds_data_last_sent            :date
#  bds_images_last_sent          :date
#  gardners_login                :string(255)
#  gardners_password             :string(255)
#  gardners_data_last_sent       :date
#  gardners_images_last_sent     :date
#  sales_person_id               :integer
#  distributor_id                :integer
#

# -*- encoding : utf-8 -*-
class Company < ActiveRecord::Base

  include Nextprev

  strip_attributes
  has_many   :posts
  has_many   :defaults
  has_paper_trail
  belongs_to :client,  :foreign_key => "id"
  accepts_nested_attributes_for :defaults, :allow_destroy => true
  attr_accessible :user_id                       ,
                  :sender_name                   ,
                  :contact_name                  ,
                  :email_address                 ,
                  :addressee_name                ,
                  :message_note                  ,
                  :created_at                    ,
                  :updated_at                    ,
                  :text1                         ,
                  :text2                         ,
                  :text3                         ,
                  :text4                         ,
                  :text5                         ,
                  :text6                         ,
                  :text7                         ,
                  :text8                         ,
                  :text9                         ,
                  :text10                        ,
                  :client_id                     ,
                  :text11                        ,
                  :text12                        ,
                  :text13                        ,
                  :text14                        ,
                  :text15                        ,
                  :text16                        ,
                  :text17                        ,
                  :text18                        ,
                  :text19                        ,
                  :text20                        ,
                  :text21                        ,
                  :text22                        ,
                  :text23                        ,
                  :text24                        ,
                  :text25                        ,
                  :text26                        ,
                  :text27                        ,
                  :text28                        ,
                  :text29                        ,
                  :text30                        ,
                  :default_currency              ,
                  :default_language              ,
                  :category_scheme_preference    ,
                  :royalty_statement_copy_one    ,
                  :royalty_statement_copy_two    ,
                  :royalty_statement_copy_three  ,
                  :royalty_statement_copy_four   ,
                  :royalty_statement_copy_five   ,
                  :royalty_statement_copy_six    ,
                  :royalty_statement_copy_seven  ,
                  :royalty_statement_copy_eight  ,
                  :royalty_statement_copy_nine   ,
                  :royalty_statement_copy_ten    ,
                  :royalty_statement_copy_eleven ,
                  :nielsen_login                 ,
                  :nielsen_password              ,
                  :nielsen_data_last_sent        ,
                  :nielsen_images_last_sent      ,
                  :bowker_login                  ,
                  :bowker_password               ,
                  :bowker_data_last_sent         ,
                  :bowker_images_last_sent       ,
                  :amazoncouk_login              ,
                  :amazoncouk_password           ,
                  :amazoncouk_data_last_sent     ,
                  :amazoncouk_images_last_sent   ,
                  :bds_login                     ,
                  :bds_password                  ,
                  :bds_data_last_sent            ,
                  :bds_images_last_sent          ,
                  :gardners_login                ,
                  :gardners_password             ,
                  :gardners_data_last_sent       ,
                  :gardners_images_last_sent     ,
                  :sales_person_id               ,
                  :distributor_id,
                  :defaults_attributes,
                  :id, :address, :phone

  validates :sender_name, :presence => true
  validates :client_id, :presence => true, :uniqueness => true
  TEXT_KEY = {  :home_page_headline => '1',
                :home_page_text => '2',
                :about_us => '3',
                :home_page_features_content => '8',
                :home_page_features_heading => '9',
                :amazon_associates_id => '10',
                :home_page_about_us => '11',
                :home_page_sidebar_heading=> '12',
                :home_page_sidebar_content => '13',
                :catalogue => '7',
                :contact => '4',
                :submissions => '5' }

  def text(type)

    text_number = TEXT_KEY[type]
    if text_number.nil?
      return
    else
      instance_eval "self.text#{text_number}"
    end
  end

  def self.text(type)
    text_number = TEXT_KEY[type]
  end

  def self.by_webname(webname)
    Company.find_by_id(Client.find_by_webname(webname))
  end

end


