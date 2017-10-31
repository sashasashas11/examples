module DynamicField
  module ValueType
    class Boolean < Base
      VALUES = [ 'Yes', 'No', 'N/A', nil ]

      def put_value(v)
        super(v) if VALUES.include?(v)
      end

      def display_value
        self.value.nil? ? '-' : self.value
      end

    end
  end
end