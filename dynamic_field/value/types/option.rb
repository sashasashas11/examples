module DynamicField
  module ValueType
    class Option < Base

      extend_json( [ :option, :options ] )

      def option
        self.pull_value
      end

      def options
        field_record.options
      end

      def validate
        @field_record.errors[:field_type] << 'Options are not set for option field.' if @field_record.options.empty?
      end

    end
  end
end