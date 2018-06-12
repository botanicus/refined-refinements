# frozen_string_literal: true

require 'date'

module RR
  module DateExts
    refine Date do
      def weekend?
        self.saturday? || self.sunday?
      end

      def weekday?
        !self.weekend?
      end
    end
  end
end
