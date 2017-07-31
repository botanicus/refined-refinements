require 'curses'
require 'refined-refinements/curses/colours'
require 'refined-refinements/curses/commander'

using RR::ColourExts

class QuitAppError < StandardError
end

class KeyboardInterrupt < StandardError
  attr_reader :key_code
  def initialize(key_code)
    @key_code = key_code
  end

  def escape?
    @key_code == 27
  end

  def ctrl_d?
    @key_code == 4
  end
end

class App
  def initialize
    @history = Array.new
  end

  def run(&block)
    self.set_up

    loop do
      @current_window = window = Curses::Window.new(Curses.lines, Curses.cols, 0, 0)
      window.keypad = true
      block.call(self, window)
    end
  rescue Interrupt, QuitAppError # Ctrl+C # TODO: Add Ctrl+D into this.
  ensure # TODO: Without this, there's no difference.
    Curses.close_screen
  end

  def destroy
    raise QuitAppError.new
  end

  def set_up
    Curses.init_screen
    Curses.start_color
    Curses.nonl # enter is 13
  end

# TODO: Ctrl+a, Ctrl+e, Ctrl+k, delete.
  def readline(prompt, window = @current_window, &unknown_key_handler)
    Curses.noecho
    window.write(prompt)

    buffer, cursor, original_x = String.new, 0, window.curx
    until (char = window.getch) == 13
      begin
        buffer, cursor = process_char(char, buffer, cursor, window, original_x)
      rescue KeyboardInterrupt => interrupt
        unknown_key_handler.call(interrupt) if unknown_key_handler
      end

      # begin
      #   sp = ' ' * (window.maxx - window.curx - buffer.length - prompt.gsub(/<[^>]+>/, '').length)
      # rescue
      #   sp = ' ERR ' # FIXME.
      # end

      window.setpos(window.cury, 0)
      window.deleteln
      window.write("#{prompt}#{buffer}")
      # window.setpos(window.cury, original_x)
      # window.write(buffer + sp)

      # DBG
      # a, b = window.cury, cursor + original_x
      # window.setpos(window.cury + 1, 0)
      # window.write("<blue.bold>~</blue.bold> DBG: X position <green>#{original_x}</green>, cursor <green>#{cursor}</green>, buffer <green>#{buffer.inspect}</green>, history: <green>#{@history.inspect}</green> ... writing to <green>#{a}</green> x <green>#{b}</green>")
      # window.setpos(window.cury - 1, cursor + original_x)

      window.refresh
    end

    @history << buffer
    Curses.echo
    window.setpos(window.cury + 1, 0)
    # window.write([:input, buffer].inspect + "\n")
    # window.refresh
    # sleep 2.5
    return buffer
  end

  def commander
    Commander.new
  end

  def process_char(char, buffer, cursor, window, original_x)
    case char
    when 127 # Backspace.
      unless buffer.empty?
        buffer = buffer[0..-2]; cursor -= 1
      end
    when 258 # Down arrow
      # TODO
      window.write("X")
      window.refresh
    when 259 # Up arrow.
      # TODO:
      @history_index ||= @history.length - 1

      window.setpos(window.cury + 1, 0)
      window.write("DBG: #{@history_index}, #{(0..@history.length).include?(@history_index)}")
      window.setpos(window.cury - 1, cursor + original_x)
      window.refresh

      if (0..@history.length).include?(@history_index)
        @buffer_before_calling_history = buffer
        buffer = @history[@history_index - 1]
      else
        window.setpos(window.cury, 0)
        if @history.empty?
          window.write("~ The history is empty.")
        else
          window.write("~ Already at the first item.")
        end
        window.setpos(window.cury - 1, original_x)
        window.refresh
      end
      cursor = buffer.length
    when 260 # Left arrow.
      cursor -= 1 unless original_x == window.curx
      # window.setpos(window.cury, window.curx - 1)
    when 261 # Right arrow.
      cursor += 1 unless original_x + buffer.length == window.curx
      # window.setpos(window.cury, window.curx + 1)
    when String
      # window.addch(char)
      buffer.insert(cursor, char); cursor += 1
    else
      raise KeyboardInterrupt.new(char) # TODO: Just return it, it's not really an error.
    end

    return buffer, cursor
  end
end
