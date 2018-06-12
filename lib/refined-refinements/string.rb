# frozen_string_literal: true

module RR
  module StringExts
    refine String do
      def titlecase
        "#{self[0].upcase}#{self[1..-1]}"
      end
    end

    refine Array do
      def join_with_and(xxx = 'and', delimiter = ', ', &block)
        block = Proc.new { |item| item } if block.nil?
        return block.call(self[0]) if self.length == 1
        "#{self[0..-2].map(&block).join(delimiter)} #{xxx} #{block.call(self[-1])}"
      end
    end
  end
end
