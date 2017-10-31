module DynamicField
  module ValueType
    class Integer < Base

      def pull_value
        field_record.main_value.to_s.empty? ? nil : field_record.main_value.to_i
      end

    end
  end
end