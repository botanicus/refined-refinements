require 'refined-refinements/colours'

module RR
  module ColourExts
    refine Curses::Window do
      def defined_colours
        Curses.constants.grep(/^COLOR_/).map do |colour|
          colour.to_s.sub(/^COLOR_/, '').downcase.to_sym
        end
      end

      def defined_attributes
        Curses.constants.grep(/^A_/).map do |colour|
          colour.to_s.sub(/^A_/, '').downcase.to_sym
        end
      end

      # window.write("<red>Dog's <bold>bollocks</bold>!</red>")
      def write(template)
        template.chunks_with_colours.each do |chunk, colours|
          attributes = colours.select { |method| self.defined_attributes.include?(method) }.map do |attribute_name|
            Curses.const_get(:"A_#{attribute_name.to_s.upcase}") || raise("Unknown attribute #{attribute_name}.")
          end

          colours.select { |method| self.defined_colours.include?(method) }.each do |colour_name|
            fg_colour = get_colour(colour_name)
            Curses.init_pair(fg_colour, fg_colour, Curses::COLOR_BLACK)
            attributes << (Curses.color_pair(fg_colour) | Curses::COLOR_WHITE)
          end

          if ! attributes.empty? && ! colours.include?(:clear)
            self.multi_attron(*attributes) do
              self.addstr(chunk)
            end
          else
            self.addstr(chunk)
          end
        end
      end

      def get_colour(colour_name)
        Curses.const_get(:"COLOR_#{colour_name.to_s.upcase}") || raise("Unknown colour: #{colour_name}")
      end

      def multi_attron(*attributes, &block)
        self.attron(attributes.shift) do
          if attributes.empty?
            block.call
          else
            self.multi_attron(*attributes, &block)
          end
        end
      end
    end
  end
end
