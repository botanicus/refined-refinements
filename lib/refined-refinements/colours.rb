require 'term/ansicolor'
require 'refined-refinements/matching'

module RR
  module ColourExts
    REGEXP = /
      <(?<dot_separated_methods>[^>]+)>
        (?<text_between_tags>.*?)
      <\/\k<dot_separated_methods>>
    /xm

    def self.colours
      @colours ||= Object.new.extend(Term::ANSIColor)
    end

    refine String do
      using RR::MatchingExts

      def parse_colours(options = Hash.new, &block)
        colours = RR::ColourExts.colours
        # was_called = false

        if options[:recursed]
          string = self
        else
          # This solves the problem of having blank spots that never get evaluated
          # i. e. in "Hello <bold>world</bold>!" it'd be "Hello " and "!".
          # This is a problem with bold: true or in curses, where the text never
          # get rendered.
          string = options[:bold] ? "<bold>#{self}</bold>" : self
        end

        result = string.gsub(RR::ColourExts::REGEXP) do |match|
          # was_called = true

          # p [:m, match] ####
          methods = match[:dot_separated_methods].split('.').map(&:to_sym)
          methods.push(:bold) if options[:bold]
          # p [:i, match[:text_between_tags], methods, options] ####

          inner_text = match[:text_between_tags]
          block.call(inner_text, methods, options)
        end

        # block.call(result, Array.new, options) #unless was_called

        result.match(RR::ColourExts::REGEXP) ? result.colourise(options.merge(recursed: true)) : result #block.call(result, [options[:bold] ? :bold : nil].compact, options)
      end

      # FIXME: bold true doesn't do anything for the text that is not wrapped
      # in anything, only for text that is between tags. I. e. "Hey <green>you</green>!"
      def colourise(options = Hash.new)
        colours = RR::ColourExts.colours

        self.parse_colours(options) do |inner_text, methods, options|
          methods.reduce(inner_text) do |result, method|
            # (print '  '; p [:r, result, method]) if result.match(/(<\/[^>]+>)/) ####
            result.gsub!(/(<\/[^>]+>)/, "#{colours.send(method)}\\1")
            # puts "#{result.inspect}.#{method}" ####
            "#{colours.send(method)}#{result}#{colours.reset unless options[:recursed]}"
          end
        end
      end

      # "Hey <green>y<bold>o</bold>u</green>!"
      # 1. "Hey ", []
      # 2. "y", [:green]
      # 3. "o", [:green, :bold]
      # 4. "u", [:green]
      # 5. "!", []
      def _chunks_with_colours(options = Hash.new)
        # p [:call, self, options]
        options[:chunks] ||= Array.new
        was_called = false

        self.colourise.sub(/\e\[(\d+)m/) do |match, before_match, after_match|
          was_called = true

          store = Term::ANSIColor::Attribute.instance_variable_get(:@__store__)
          colour_name = store.find { |name, attribute| attribute.code == match[1] }[0]

          options[:chunks] << before_match unless before_match.empty?
          options[:chunks] << colour_name

          after_match._chunks_with_colours(options)
        end

        options[:chunks] << self unless was_called

        options[:chunks]
      end

      def chunks_with_colours(options = Hash.new)
        buffer, result = Array.new, Array.new

        # p [:s, self.colourise]
        self._chunks_with_colours(options).each do |item|
          # p [:x, result, buffer, item]
          if item.is_a?(Symbol)
            buffer << item
          else
            result << [item, buffer.uniq.dup]
            buffer.clear
          end
        end

        result
      end
    end

    # TODO: Use a separate file.
    if defined?(Curses)
      refine Curses::Window do
        def defined_fg_colours
          Curses.constants.grep(/^COLOR_/).map do |colour|
            colour.to_s.sub(/^COLOR_/, '').downcase.to_sym
          end
        end

        def defined_bg_colours
          Curses.constants.grep(/^A_/).map do |colour|
            colour.to_s.sub(/^A_/, '').downcase.to_sym
          end
        end

        # window.write("<red>Dog's <bold>bollocks</bold>!</red>")
        def write(template)
          @log ||= File.open("commander.log", 'a')
          template.chunks_with_colours.each do |chunk, colours|
            fg = colours.find { |method| self.defined_fg_colours.include?(method) }
            bg = colours.find { |method| self.defined_bg_colours.include?(method) }
            @log.puts({t: chunk}.inspect); @log.flush ####

            if (fg || bg) && ! colours.include?(:clear)
              fg_colour = fg ? Curses.const_get(:"COLOR_#{fg.to_s.upcase}") : Curses::COLOR_WHITE
              bg_colour = bg ? Curses.const_get(:"A_#{bg.to_s.upcase}") : Curses::A_NORMAL
              # @log.puts({fg: [fg, fg_colour], bg: [bg, bg_colour], t: chunk}.inspect); @log.flush

              Curses.init_pair(fg_colour, fg_colour, Curses::COLOR_BLACK)

              self.attron(Curses.color_pair(fg_colour) | Curses::COLOR_WHITE) do
                self.addstr(chunk)
              end
            else
              self.addstr(chunk)
            end
          end
        end
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
