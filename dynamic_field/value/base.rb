module DynamicField
  module ValueType
    class Base
      include JsonHelper
      include ActionView::Helpers::SanitizeHelper

      attr_reader :field_record

      N_A = 'N/A'

      def initialize(field_record)
        @field_record = field_record
      end

      def set_default_values
      end

      def value=(new_value)
        field_record.original_value = new_value
        put_value(new_value) if field_record.check_value_format(new_value)
      end

      def value
        pull_value
      end

      def put_value(new_value)
        field_record.main_value = new_value
      end

      def pull_value
        field_record.main_value
      end

      def full_value
        pull_value
      end

      def approvement_value
        field_record.approvement_step_field
      end

      def approvement_value=(new_value)
        field_record.approvement_step_field = new_value
      end

      def recalculate_approvement_value!
        self.approvement_value = self.value
      end

      def attachment?
        false
      end

      def display_value
        self.value.nil? ? no_answer : self.value
      end

      def no_answer
        N_A
      end

      def value_attribute
        field_record.value_attribute
      end

      def value_attributes
        field_record.value_attributes
      end

      def errors_list
        field_record.errors.messages.values.flatten.uniq
      end

      def completed?
        v = self.value
        !v.nil? && !v.to_s.empty?
      end

      def is_empty?
        v = self.value
        v.nil?
      end

      def status
        self.completed? ? :completed : :uncompleted
      end

      def blank?
        !completed?
      end

      def affects_status?
        @field_record.affect_level == :default
      end

      def visible?
        @field_record.visible
      end

      def show_on_pdf?
        true
      end

      def has_dependent?
        false
      end

      def dependent_field
      end

      def depends_on?
        false
      end

      def depends_on_field
      end

      def validate
      end

      def update_value(field)
        self.approvement_value = field[:approvement_step_field]
      end

      OVERRIDABLE = [ :comment, :comment=, :code_part, :code_part=, :unit, :unit=, :option, :option= ]
      def stub *args; end
      OVERRIDABLE.each do |m|
        alias_method m, :stub
      end


      BASIC_JSON_FIELDS = [ :value, :display_value, :approvement_value, errors: :errors_list ]
      def self.extend_json(extra_fields=[])
        all_fields = BASIC_JSON_FIELDS + extra_fields
        json( *all_fields )
      end

      extend_json

    end
  end
end
