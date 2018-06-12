# frozen_string_literal: true

require 'refined-refinements/string'

class QuitError < StandardError
end

class Command
  attr_reader :keys, :help
  def initialize(keys, help = nil, &handler)
    @keys, @help, @handler = keys, help, handler
  end

  def handles?(command_key)
    @keys.include?(command_key)
  end

  def execute(commander_window, command_key)
    @handler.call(commander_window, command_key)
  end
end

class Commander
  using RR::ColourExts
  using RR::StringExts

  def initialize
    @commands = Array.new
    # @commands << Command.new(['?'], "Display help.") do |commander_window|
    #   commander_window.write(self.help)
    #   commander_window.getch # Enter or any key.
    # end
  end

  def run(&block)
    Curses.noecho
    Curses.curs_set(0)

    commander_window = Curses::Window.new(Curses.lines, Curses.cols, 0, 0)
    commander_window.keypad = true

    if block
      block.call(self, commander_window)
      commander_window.refresh
    end

    commander_window.setpos(commander_window.cury + 4, 0)

    command_key = commander_window.getch
    if command = self.find_command(command_key)
      command.execute(commander_window, command_key) # Return message.
    else
      # TODO: command not found, display message?
      self.run(&block) # Restart.
    end
  ensure
    Curses.echo
  end

  def loop(&block)
    Kernel.loop { self.run(&block) }
  rescue QuitError
    # void
  end

  def command(keys_or_key, help = nil, &handler)
    @commands << Command.new([keys_or_key].flatten, help, &handler) # TODO: (One) key vs. keys?
  end

  def default_command(&handler)
    @default_command = Command.new(Array.new, nil, &handler)
  end

  def find_command(command_key)
    @commands.find { |command| command.handles?(command_key) } || @default_command
  end

  def help
    commands_help = @commands.reduce(Array.new) do |buffer, command|
      if command.help
        keys_text = command.keys.join_with_and('or') do |word|
          "<yellow.bold>#{word}</yellow.bold>"
        end

        buffer << "#{keys_text} to #{command.help}"
      else
        buffer
      end
    end

    "<red.bold>Help:</red.bold> Press #{commands_help.join_with_and('or')}."
  end

  def available_commands_help
    commands_help = @commands.reduce(Array.new) { |buffer, command|
      keys_text = command.keys.join_with_and('or') { |word| "<yellow.bold>#{word}</yellow.bold>" }
      buffer << "#{keys_text}"
    }.join_with_and

    "<green>Available commands</green> are #{commands_help}. Press <yellow>?</yellow> for <red>help</red>."
  end
end
