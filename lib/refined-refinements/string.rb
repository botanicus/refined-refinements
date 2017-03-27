module RR
  module StringExts
    refine String do
      def titlecase
        "#{self[0].upcase}#{self[1..-1]}"
      end
    end
  end
end
