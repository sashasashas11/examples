module DynamicField
  module ValueType
    require Rails.root.join 'app/models/dynamic_field/value/types/model_price'
    class FloorPrice < ModelPrice

      def affects_status?
        manufacturer?
      end

      def visible?
        manufacturer?
      end

      def has_dependent?
        true
      end

      def dependent_field
        @field_record.device_step.device_fields.where(field_type: FIELD_TYPES.key(:proposed_price)).take
      end

      def manufacturer?
        @field_record.device.user.manufacturer? if !@field_record.device.blank?
      end
    end
  end
end