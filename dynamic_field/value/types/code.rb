module DynamicField
  module ValueType
    class Code < Base
      extend_json( [ :code_part ] )

      def full_value
        if value && value != '0'
          "#{value}s#{field_record.code_part}"
        else
          nil
        end
      end

      def display_value
        if value.blank?
          N_A
        else
          "#{value}#{blank_code ? '' : "s#{field_record.code_part}"}"
        end
      end

      def blank_code
        field_record.code_part.blank?
      end

      def code_part
        field_record.extra_value
      end

      def code_part=(v)
        field_record.extra_value = v
      end

      def recalculate_approvement_value!
        self.approvement_value = display_value
      end
    end
  end
end