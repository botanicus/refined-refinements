require 'term/ansicolor'
require 'refined-refinements/matching'

module RR
  module ColourExts
    def self.colours
      @colours ||= Object.new.extend(Term::ANSIColor)
    end

    refine String do
      using RR::MatchingExts

      def colourise(options = Hash.new)
        regexp = /
          <(?<dot_separated_methods>[^>]+)>
            (?<text_between_tags>.*?)
          <\/\k<dot_separated_methods>>
        /xm

        colours = RR::ColourExts.colours

        result = self.gsub(regexp) do |match|
          # p [:m, match] ####
          methods = match[:dot_separated_methods].split('.').map(&:to_sym)
          methods.push(:bold) if options[:bold]
          # p [:i, match[:text_between_tags], methods, options] ####

          methods.reduce(inner_text = match[:text_between_tags]) do |result, method|
            # (print '  '; p [:r, result, method]) if result.match(/(<\/[^>]+>)/) ####
            result.gsub!(/(<\/[^>]+>)/, "#{colours.send(method)}\\1")
            # puts "#{result.inspect}.#{method}" ####
            "#{colours.send(method)}#{result}#{colours.reset unless options[:recursed]}"
          end
        end

        result.match(regexp) ? result.colourise(options.merge(recursed: true)) : result
      end
    end
  end
end

# using RR::ColourExts
#
# s1 = "<green>Hello <red>world</red>!</green>"
# s2 = "<green>H<yellow>e</yellow>llo <red>world</red>!</green>" # F
# s3 = "<green>H</green>ello <red>w</red>orld!"
#
# puts s1.colourise, ''
# puts s2.colourise(bold: true), ''
# puts s3.colourise, ''
