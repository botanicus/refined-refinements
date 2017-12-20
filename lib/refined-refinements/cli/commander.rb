require 'refined-refinements/string'
require 'refined-refinements/colours'

module RR
  class Commander
    using RR::ColourExts

    def self.commands
      @commands ||= Hash.new
    end

    def self.command(command_name, command_class)
      self.commands[command_name] = command_class
    end

    def help_template(program_name)
      <<-EOF
<red.bold>:: #{program_name} ::</red.bold>

<cyan.bold>Commands</cyan.bold>
      EOF
    end

    def help
      self.commands.reduce(self.help_template) do |buffer, (command_name, command_class)|
        command_help = command_class.help && command_class.help.split("\n").map { |line| line.sub(/^ {4}/, '') }.join("\n")
        command_class.help ? [buffer, command_help].join("\n") : buffer
      end.colourise
    end

    def commands
      self.class.commands
    end

    def run(command_name, args)
      command_class = self.class.commands[command_name]
      command = command_class.new(args)
      command.run
    end
  end

  class Command
    using RR::ColourExts
    using RR::StringExts # #titlecase

    class << self
      attr_accessor :help
      def main_command
        File.basename($0)
      end
    end

    def initialize(args)
      @args = args
    end
  end
end
