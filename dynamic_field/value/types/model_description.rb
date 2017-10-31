module DynamicField
  module ValueType
    require Rails.root.join 'app/models/dynamic_field/value/types/hash'
    class ModelDescription < Hash

      def put_value(v)
        if v.is_a?(::Hash)
          super
        else
          super({ needed_keys.first => v })
        end
      end

      def completed?
        v = self.value
        !v.nil? && !v.values.any?{|x| [nil, ''].include?(x)}
      end

      def display_value
        return {} if !field_record.main_value || field_record.main_value.empty?
        HashWithIndifferentAccess[JSON.parse(field_record.main_value.to_s)]
      end

      protected

      def needed_keys
        field_record.device.model_number_value if !field_record.device.reload.blank?
      end

      def default_value
        keys = needed_keys
        return nil if keys.blank?
        HashWithIndifferentAccess[keys.zip([nil]*keys.count)]
      end

      def parse_value_from
        prepare_value super
      end

      def parse_value_to(input_value)
        res = prepare_value(input_value)
        res.nil? ? nil : res.to_json
      end

    end
  end
end