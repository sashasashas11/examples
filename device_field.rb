class DeviceField < ActiveRecord::Base
  require 'value_format_validator'
  require 'dynamic_field/dynamic_field'
  include ValueFormatValidator
  include DynamicField
  include AttachedGroup::Owner
  include JsonHelper

  belongs_to :step_field
  belongs_to :device_step
  has_one :device, through: :device_step
  has_one :submission, through: :device
  has_one :device_approvement_step, through: :device_step
  belongs_to :answered_by, foreign_key: :answered_by, class_name: 'User'

  scope :active, -> { where(deleted: false) }
  scope :by_field, ->(field) { where(step_field_id: field.id) }
  scope :custom, ->{ where(custom: true) }
  scope :non_custom, ->{ where.not(custom: true) }

  attr_accessor :original_value
  delegate :attach_file, to: :dynamic_value
  before_create :clone_details

  def active_attached_units
    attached_units.active
  end

  json(:id, :step_field_id, :name, approvement_step_field: :approvement_value,
       type: :field_type_name, show_on_pdf: :show_on_pdf?,
       custom: :custom?, required: :required?,
  )

  def in_server_state?
    true
  end

  def answered_by_json
    answered_by.try(:short_json)
  end

  def set_update_info(user, old_value)
    DeviceApprovementStepChangeLog.log_change(self, old_value, user)

    return if !(custom? && is_internal?)
    update_attributes(answered_by: user, answered_at: DateTime.now)
  end

  DYNAMIC_VALUE_METHODS = [
      :value, :value=, :full_value, :display_value, :approvement_value, :approvement_value=,
      :errors_list,
      :completed?,
      :status,
      :attachment?,
      :affects_status?,
      :visible?,
      :validate,
  ] + DynamicField::ValueType::Base::OVERRIDABLE
  delegate *DYNAMIC_VALUE_METHODS, to: :dynamic_value

  def is_symlink?
    !attached_group.try(:main_group_id).blank?
  end

  def is_pricing_field?
    DynamicField::PRICING_FIELDS.include?(self.field_type)
  end

  def to_json
    resolve_to_json.merge!(dynamic_value.to_json)
  end

  def default_value=(value)
    self.main_value = value
  end

  def default_value
    self.main_value
  end

  def self.update_rep_static_fields(rep)
    update_rep_static_field(rep, :name, rep.full_name)
    update_rep_static_field(rep, :phone_number, rep.phone_number)
    update_rep_static_field(rep, :email, rep.email)
    update_rep_static_field(rep, :company, rep.company.try(:name))
  end

  protected

  def self.update_rep_static_field(rep, field_key, value)
    by_name_and_device_creator(STATIC_REP_FIELDS[field_key], rep).update_all(main_value: value, approvement_step_field: value)
  end

  def clone_details
    DynamicField::SCHEMA_FIELDS.each do |name|
      self.send("#{name}=", step_field.send(name))
    end
  end

end
