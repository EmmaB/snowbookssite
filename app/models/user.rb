# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(128)      default("")
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string(255)
#  last_name              :string(255)
#  client_id              :integer
#  invitation_token       :string(60)
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string(255)
#  client_name_requested  :string(255)
#  mode                   :string(255)
#  forem_admin            :boolean          default(FALSE)
#  forem_state            :string(255)      default("pending_review")
#  forem_auto_subscribe   :boolean          default(FALSE)
#  imprint_preference_id  :integer
#  role_preference_id     :integer
#

# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  has_gritter_notices
  scope :lookup, lambda {|model| where("id = ?", model.user_id)}
  include Nextprev
  has_paper_trail
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :invitable, :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :invitable, :invite_for => 2.weeks, :invite_key => :email, :validate_on_invite => true
  # delegate :can?, :cannot?, :to => :ability

  include PgSearch
  pg_search_scope :user_search, against: [:first_name, :last_name, :client_id, :client_name_requested, :last_sign_in_ip, :sign_in_count],
    using: {tsearch: {dictionary: "english"}},
    using: {:tsearch => {:any_word => true}},
    using: {tsearch: {prefix: true}}

  # Setup accessible (or protected) attributes for the model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :level_ids, :levels_attributes, :levelusers_attributes, :client_id, :client_name_requested, :mode, :notice, :group_id, :css_preference, :schedule_notification

  belongs_to  :client
  has_many    :levelusers
  has_many    :levels, :through => :levelusers
  has_many    :contracts
  has_many    :posts
  has_many    :schedule_users
  has_many    :schedules, :through => :schedule_users
  has_many    :task_users
  has_many    :tasks, :through => :task_users
  has_many    :sales
  has_many    :friendships
  has_many    :friends, :through => :friendships
  has_many    :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many    :inverse_friends, :through => :inverse_friendships, :source => :user
  validates   :client_name_requested, :uniqueness => true, :on => :create, :unless => :invited?
  validates   :client_id, :presence => true, :on => :update
  validates   :email, :presence => true

  after_save  :set_up_client_if_registering, :unless => :invited?
  after_create :if_no_level_default_to_team
  after_create :check_client_id_manually , :unless => :invited?
  accepts_nested_attributes_for :levels, :allow_destroy => true
  accepts_nested_attributes_for :levelusers, :allow_destroy => true

  delegate :company, :to => :client

  def self.text_search(query)
    if query.present?
      user_search(query)
    else
      scoped
    end
  end

  def invited?
    true if self.invited_by
  end

  def set_up_client_if_registering
    puts "in set_up_client_if_registering"
    unless self.client_id
      # gsub removes all whitespaces for the webname
      new_client = Client.new(:webname => self.client_name_requested.gsub(/\s+/, ""), :client_name => self.client_name_requested, :use_default_css => true)
      new_client.save
      self.client_id = new_client.id
        self.save!
      level = Leveluser.new(:user_id => self.id, :level_id => 2)
      level.save!
    end
  end

  def if_no_level_default_to_team
    unless self.levelusers.first
     level = Leveluser.new(:user_id => self.id, :level_id => 3)
     level.save!
    end
  end

  def check_client_id_manually
    puts "in check_client_id_manually"
    #returns true if there's no problem with the client name
    unless self.client_id
      errors.add(:client_id, I18n.t(:user_has_no_client, :scope => [:books, :books]) )
      return false
      self.destroy!
      #  user has no client, so destroyed
    else
      true
      # user has a client - all systems go
    end
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def level?(level)
    return self.levels.find_by_name(level).try(:name) == level.to_s
  end

  # Get roles accessible by the current user
  def accessible_roles
    @accessible_roles = Level.accessible_by(current_ability, :read)
  end

  # Make the current user object available to views
  def get_user
    @current_user = current_user
  end

  def self.by_association(assoc)
    User.find_by_id(assoc.user_id) unless User.find_by_id(assoc.user_id).nil?
  end

  def self.by_task(task)
    User.find_by_id(task.owner)
  end

  def self.by_client(current_user)
    where(:client_id => current_user.client_id)
  end

  def to_s
    "#{first_name} #{last_name} from #{Client.find(client_id).client_name}"
  end

  def full_name
    first_name + " " + last_name
  end

  def self.send_reminders
    User.where('schedule_notification is not null').each do |user|
      if user.schedule_notification > 4
        user.tasks.where('"end" = ?', Date.today - 7).each do |task|
          puts "tsk 1 is #{task}"
          ScheduleMailer.delay.schedule_update_one_week(user, task)
        end
      end
      if user.schedule_notification > 2
        user.tasks.where('"end" = ?', Date.today - 1).each do |task|
          puts "tsk 2 is #{task}"
          ScheduleMailer.delay.schedule_update_one_day(user, task)
        end
      end
      if user.schedule_notification > 1
        user.tasks.where('"end" = ?', Date.today ).each do |task|
          puts "tsk 3 is #{task}"
          ScheduleMailer.delay.schedule_update_late(user, task)
        end
      end
    end
  end

end
