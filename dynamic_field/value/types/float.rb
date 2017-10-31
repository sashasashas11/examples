module DynamicField
  module ValueType
    class Float < Base

      def pull_value
        field_record.main_value.to_s.empty? ? nil : field_record.main_value
      end

    end
  end
end