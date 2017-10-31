module DynamicField

  extend ActiveSupport::Concern
  include WithName
  SCHEMA_FIELDS = [ :name, :field_type, :options_value, :affect_level_index, :visible, :custom, :order_priority, :default_value ]
  VALUE_FIELDS = [ :main_value, :extra_value ]

  FIELD_TYPES = {
      0 => :string,
      1 => :integer,
      2 => :float,
      3 => :boolean,
      5 => :attachment,
      6 => :quantity,
      7 => :email,
      8 => :phone,
      9 => :date,
      10 => :option,
      11 => :currency,
      12 => :list,
      13 => :checkbox,
      14 => :commentable_checkbox,
      15 => :multichoice,
      16 => :text,

  }

  PRICING_FIELDS = [
      FIELD_TYPES.key(:floor_price),
      FIELD_TYPES.key(:model_price),
      FIELD_TYPES.key(:proposed_price),
  ]

  AFFECT_LEVELS = {
      0 => :default,
      1 => :skippable,
      2 => :switch,
  }

  require Rails.root.join('app/models/dynamic_field/value/factory')

  included do
    scope :by_field_type, ->(ft){ where(field_type: ft) }
    scope :by_type, ->(t){ by_field_type(field_type_index(t)) }
    scope :strings, ->{ by_type(:string) }
    scope :integers, ->{ by_type(:integer) }
    scope :floats, ->{ by_type(:float) }
    scope :booleans, ->{ by_type(:boolean) }
    scope :active, ->{ where(deleted: false) }
    scope :custom, ->{ where(custom: true) }

    validate :validate_fields
    validates :field_type, inclusion: FIELD_TYPES.keys, presence: true
  end

  def dynamic_value
    @dv ||= ValueType::Factory.value_for_record(self)
  end

  def value_attribute
    field_type_name
  end

  def value_attributes
    HashWithIndifferentAccess[
        attributes.to_a.select do |(n, v)|
          VALUE_FIELDS.include? n.to_sym
        end
    ]
  end

  def options
    has_options? ? list_value(:options) : []
  end

  def units
    has_units? ? list_value(:options) : []
  end

  def options=(v)
    set_list_value(:options,v)
  end

  alias_method :units=, :options=

  def has_options?
    [ :option, :multichoice ].include? field_type_name
  end

  def has_units?
    [ :quantity, :stateful_metric ].include? field_type_name
  end

  def field_type_name
    FIELD_TYPES[self.field_type]
  end

  def field_type_name=name
    self.field_type=self.class.field_type_index(name)
  end

  def affect_level
    AFFECT_LEVELS[self.affect_level_index]
  end

  def affect_level=name
    self.affect_level_index = AFFECT_LEVELS.key(name)
  end

  def switch?
    affect_level == :switch
  end

  def affects_status?
    affect_level == :default
  end

  def associate_with_hospital(hospital)
    hospital.custom_questions.first.step.step_fields << self
  end

  def floor_price?
    self.field_type_name == :floor_price
  end

  module ClassMethods
    def field_type_index(name)
      FIELD_TYPES.select{|index,n| n == name.to_s.to_sym }.first.first
    end
  end

  def revalidate
    self.errors[:field_record].clear
    validate
  end

  def validate_fields
    self.validate
  end

end
