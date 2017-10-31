module DynamicField
  module ValueType
    class Hash < Base

      def put_value(mv)
        field_record.main_value = parse_value_to(mv)
      end

      def pull_value
        res = field_record.main_value.to_s
        res.empty? ? default_value : parse_value_from
      end

      def display_value
        v = pull_value
        return no_answer if v.nil?
        v.map do |key, v|
          "<p style='margin: 1px'><b>#{key}</b>: #{display_one_value(v)}</p>"
        end.join.html_safe
      end

      def full_value
        display_value
      end

      def recalculate_approvement_value!
        v = pull_value
        return no_answer if v.nil?
        v.each do |k,val|
          v[k] = display_one_value(val)
        end

        self.approvement_value = v
        field_record.save
      end

      def approvement_value=(new_value)
        field_record.approvement_step_field = new_value.to_json
      end

      protected

      def default_value
        nil
      end

      def parse_value_from
        HashWithIndifferentAccess[JSON.parse(field_record.main_value.to_s)]
      end

      def parse_value_to(input_value)
        throw JSON::ParserError unless input_value.is_a?(::Hash)
        input_value.to_json
      end

      def display_one_value(value)
        value.to_s.empty? ? no_answer : value
      end

    end
  end
end