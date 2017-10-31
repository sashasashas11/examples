module DynamicField
  module ValueType
    class CompletedField < Base
      def completed?
        true
      end
      def show_on_pdf?
        false
      end
    end
  end
end