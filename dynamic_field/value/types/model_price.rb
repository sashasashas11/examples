module DynamicField
  module ValueType
    require Rails.root.join 'app/models/dynamic_field/value/types/model_description'
    class ModelPrice < ModelDescription

      def display_one_value(value)
        ?$+ '%.2f' % value.to_f
      end

      def completed?
        v = self.value
        !v.nil? && !v.values.any?{|x| [nil, 0].include?(x.try(&:to_i))}
      end

      def status
        return :uncompleted if self.is_empty?
        self.completed? ? :completed : :in_progress
      end

      def is_empty?
        v = self.value
        v.nil? || v.values.inject{|sum,x| sum.to_i + x.to_i }.to_i.zero?
      end

      def put_value(mv)
        if mv.is_a?(::Hash)
          mv.keys.each { |k|
            mv[k] =  to_float(mv[k]) if !mv[k].nil? && !mv[k].to_s.empty?
          }
        end
        super(mv)
      end

      def to_float(value)
        sprintf("%.2f", value.to_s.gsub(/[^0-9.]/, ''))
      end

    end
  end
end