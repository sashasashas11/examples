module DynamicField
  module ValueType

    class Currency < Base

      def pull_value
        field_record.main_value.to_f == 0.0 ? nil : field_record.main_value.to_f
      end

      def put_value(cv)
        field_record.main_value = (cv.to_f == 0.0 ? nil : cv)
      end

      def display_value
        ?$+ ' %.2f' % pull_value.to_f
      end

      def recalculate_approvement_value!
        self.approvement_value = display_value
      end

    end
  end
end