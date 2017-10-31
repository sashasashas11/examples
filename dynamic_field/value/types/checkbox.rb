module DynamicField
  module ValueType
    class Checkbox < Base

      def put_value v
        field_record.main_value = (v ? true : nil)
      end

      def pull_value
        [true, 'true', 1, ?1].include?(field_record.main_value) ? true : nil
      end

      def display_value
        self.value.nil? ? ('N/A') : ( self.value ? 'Yes' : 'No' )
      end

      def recalculate_approvement_value!
        self.approvement_value = display_value
      end
    end
  end
end