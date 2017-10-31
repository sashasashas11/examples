require 'message_thread/acl'

class MessageThread < ActiveRecord::Base
  CATEGORIES = {
      0 => :default,
      1 => :own,
      2 => :direct,
      3 => :system,
      5 => :event,
      6 => :group,
  }

  AUTHOR_IS_RECEIVER_CATEGORIES_LIST = [
      :quick_approve
  ]

  include WithCategory
  include MessageThreadExt::Acl

  has_many :messages, -> { order('created_at desc') }
  has_many :user_messages, through: :messages
  has_many :user_threads
  has_many :participants, class_name: 'User', through: :user_threads, source: :user
  belongs_to :target, polymorphic: true

  scope :by_name, ->(name) { where(name: name) }

  def post(text, author, opts, send_emails=true)
    options = {
        author: author,
        body: text,
        readers: self.participants.active
    }.merge(opts)

    receivers = select_email_receivers(options[:readers], author, options[:category_name])
    options[:readers] = select_message_users(options[:readers])
    res = self.messages.create!(options)
    send_emails(receivers, options, res) if send_emails && res
    res
  end

  def select_email_receivers(readers, author, category_name)
    readers.select do |reader|
      if reader.is_a?(User)
        next if !include_author?(category_name) && reader.id == author.id

        filter = reader.filter_by_category(category_name)
        filter && filter[:email_value]
      else
        false
      end
    end
  end

  def select_message_users(readers)
    readers.select { |reader| reader.is_a?(User) }
  end

  def send_emails(readers, options, message)
    category_name = options[:category_name]
    readers.each do |reader|
      filter = reader.filter_by_category(category_name)
      GlDeviseMailer.delay.event(reader, filter[:category], options[:body], options[:author])
    end
  end

  def is_direct_chat?
    self.target_type == "DirectChat"
  end

  def is_device_approvement_step?
    self.target_type == "DeviceApprovementStep"
  end

  def include_author?(category)
    AUTHOR_IS_RECEIVER_CATEGORIES_LIST.include? category
  end

  module Target
    extend ActiveSupport::Concern

    included do
      has_many :owned_threads, class_name: 'MessageThread', as: :target
      after_save :reassign_participants, if: :thread_accessible?
    end

    def thread_accessible?
      target? && persisted?
    end

    def own_thread
      return unless thread_accessible?
      owned_threads.by_category(:own).first_or_create!
    end

    def target_participants
      []
    end

    def target?
      true
    end

    def message_extras(author)
      {}
    end

    def reassign_participants
      return unless thread_accessible?
      current_participants = self.target_participants
      own_thread.participants = current_participants unless current_participants.empty?
    end

    def post(text, author, opts, send_emails=true)
      post_to_thread(text, author, message_extras(author).merge(opts), send_emails)
    end

    private

    def post_to_thread(text, author, opts, send_emails=true)
      own_thread.try(:post, text, author, opts, send_emails)
    end

  end

end
