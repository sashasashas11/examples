class Message < ActiveRecord::Base
  CATEGORIES = {
      0 => :message,
      1 => :alert,
      2 => :approval,
      3 => :signature,
      4 => :hospital_group,
      5 => :hospital_group_with_rep,
      6 => :rejection,
      7 => :chat,
  }
  LABELS = {
      message: :message,
      alert: :alert,
      approval: :approval,
      signature: :signature,
      hospital_group: :message,
      hospital_group_with_rep: :message,
      rejection: :rejection,
      chat: :message,
  }
  GROUPS = {
      message: :message,
      alert: :alert,
      approval: :approval,
      signature: :signature,
      hospital_group: :message,
      hospital_group_with_rep: :message,
      rejection: :rejection,
      chat: :message,
      verify_submission: :signature,
      physician_received: :accepted_info,
  }
  DEFAULT_OPTS = {
      category_name: :message
  }
  include WithCategory

  belongs_to :thread, class_name: 'MessageThread', foreign_key: :message_thread_id
  belongs_to :author, polymorphic: true
  has_many :user_messages
  has_many :readers, class_name: 'User', through: :user_messages, source: :user

  scope :by_thread, ->(thread_id){ where(message_thread_id: thread_id) }
  scope :events_only, -> { where(no_event: false) }
  scope :include_all, -> { includes(:author).includes(:user_messages) }
  scope :by_categories, ->(categories){ where(category: categories.map{|c| category_index_by_name(c) }) }

  validates :message_thread_id, presence: true

  module Author
    extend ActiveSupport::Concern

    included do
      has_many :written_messages, class_name: 'Message', as: :author
    end

    def post_to(message_thread, text, opts={category_name: :message})
      ( message_thread.target || message_thread ).post(text, self, opts)
    end

  end

  def to_json
    json = {
        id: id,
        action: label_name,
        category_name: category_name,
        body: body,
        posted_at: posted_at,
        object: object,
        section: section,
        author: {
            id: author.id,
            avatar: author.avatar,
            name: author.full_name,
            first_name: author.try(:first_name),
            last_name: author.try(:last_name),
            role: author.try(:role),
        },

    }

    json
  end


  def user_message
    self.user_messages.where(user_id: self.author, message_id: self.id).take!
  end

  def clean_system_name
    self.update_attribute(:system_name, nil) if system_name == ''
  end

  def posted_at
    self.created_at
  end

  def self.label_name(category_name)
    LABELS[category_name]
  end

  def self.group_name(category_name)
    GROUPS[category_name]
  end

  def self.categories_by_label(label)
    LABELS.to_a.select{|x| x.last == label }.map(&:first)
  end

  def self.categories_by_groups(label)
    GROUPS.to_a.select{|x| x.last == label }.map(&:first)
  end

  def label_name
    self.class.label_name(self.category_name)
  end


end
