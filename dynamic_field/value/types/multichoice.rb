module DynamicField
  module ValueType
    class Multichoice < Base

      extend_json( [ :option, :options ] )

      DEFAULT_VALUE = [nil]

      def put_value(mv)
        options = CSV.generate_line(mv || [])
        field_record.main_value = options
      end

      def pull_value
        res = CSV.parse_line(field_record.main_value.to_s)
        res.blank? ? default_value : res
      end

      def full_value
        blank? ? no_answer : pull_value
      end

      def display_value
        pull_value * ', '
      end

      def options
        CSV.parse_line(field_record.options_value.to_s)
      end

      def completed?
        v = pull_value
        super() && v !=[] && v !=default_value
      end

      def default_value
        DEFAULT_VALUE
      end

      def recalculate_approvement_value!
        self.approvement_value = self.display_value
      end
    end
  end
end