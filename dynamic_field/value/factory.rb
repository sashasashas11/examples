module DynamicField
  module ValueType
    class Factory

      require Rails.root.join('app/models/dynamic_field/value/base')
      DynamicField::FIELD_TYPES.values.each do |t|
        require Rails.root.join("app/models/dynamic_field/value/types/#{ t }")
      end

      def self.value_for_record(record)
        klass_name = 'ValueType::'+record.field_type_name.to_s.camelize
        klass = eval klass_name
        klass.new(record)
      end

    end
  end
end
