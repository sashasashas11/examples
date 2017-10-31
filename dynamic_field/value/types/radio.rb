module DynamicField
  module ValueType
    class Radio < Base

      def display_value
        field_record.is_selected ? 'Yes' : N_A
      end

      def recalculate_approvement_value!
        self.approvement_value = display_value
      end

    end
  end
end