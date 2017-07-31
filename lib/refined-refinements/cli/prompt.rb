# def prompt_date
#   help = "<green>#{Date.today.iso8601}</green>, anything that <magenta>Data.parse</magenta> parses or <magenta>-1</magenta> for yesterday etc"
#   @prompt.prompt(:date, 'Date', help: help) do
#     clean_value do |raw_value|
#       case raw_value
#       when /^$/ then Date.today
#       when /^-(\d+)$/ then Date.today - $1.to_i
#       else Date.parse(raw_value) end
#     end
#
#     validate_clean_value do |clean_value|
#       clean_value.is_a?(Date)
#     end
#   end
# end
#
# def prompt_type
#   @prompt.prompt(:type, 'Type', options: Expense::TYPES) do
#     clean_value do |raw_value|
#       self.retrieve_by_index_or_self_if_on_the_list(Expense::TYPES, raw_value)
#     end
#
#     validate_clean_value do |clean_value|
#       Expense::TYPES.include?(clean_value)
#     end
#   end
# end
#
# def prompt_tip
#   @prompt.prompt(:tip, 'Tip') do
#     validate_raw_value(/^\d+(\.\d{2})?$/, allow_empty: true)
#
#     clean_value do |raw_value|
#       convert_money_to_cents(raw_value)
#     end
#   end
# end
#
# def prompt_currency(expenses)
#   currencies = expenses.map(&:currency).uniq
#   @prompt.prompt(:currency, 'Currency code', options: currencies, default: expenses.last.currency) do
#     clean_value do |raw_value|
#       (not raw_value.empty?) ? self.self_or_retrieve_by_index(currencies, raw_value) : expenses.last.currency
#     end
#
#     validate_clean_value do |clean_value|
#       clean_value.match(/^[A-Z]{3}$/)
#     end
#   end
# end
#
# def prompt_location(expenses)
#   locations = expenses.map(&:location).uniq.sort_by { |location|
#     puts "#{location}: #{expenses.count { |expense| expense.location == location }}"
#     expenses.count { |expense| expense.location == location }
#   }.reverse
#
#   @prompt.prompt(:location, 'Location', options: locations, default: expenses.last.location) do
#     clean_value do |raw_value|
#       (not raw_value.empty?) ? self.self_or_retrieve_by_index(locations, raw_value) : expenses.last.location
#     end
#
#     validate_clean_value do |clean_value|
#       clean_value && ! clean_value.empty?
#     end
#   end
# end

module RR
  class InvalidResponse < StandardError; end

  class Answer
    def initialize
      @callbacks = Hash.new { Proc.new { true } }
    end

    def validate_raw_value(regexp, allow_empty: nil)
      @callbacks[:validate_raw_value] = Proc.new do |raw_value|
        unless (allow_empty && raw_value.empty?) || raw_value.match(regexp)
          raise InvalidResponse.new("Doesn't match #{regexp}.")
        end
      end
    end

    def validate_clean_value(&block)
      @callbacks[:validate_clean_value] = block
    end

    def clean_value(&block)
      @callbacks[:get_clean_value] = block
    end

    def run(raw_value)
      @callbacks[:validate_raw_value].call(raw_value)
      clean_value = @callbacks[:get_clean_value].call(raw_value)

      unless @callbacks[:validate_clean_value].call(clean_value)
        raise InvalidResponse.new
      end

      clean_value
    end

    def self_or_retrieve_by_index(list, raw_value, default_value = nil)
      if raw_value.match(/^\d+$/)
        list[raw_value.to_i - 1]
      elsif raw_value.empty?
        default_value
      else
        raw_value
      end
    end

    def retrieve_by_index_or_self_if_on_the_list(list, raw_value, default_value = nil)
      if raw_value.match(/^\d+$/)
        list[raw_value.to_i - 1]
      elsif list.include?(raw_value)
        raw_value
      elsif raw_value.empty? && default_value
        default_value
      else
        raise InvalidResponse.new(raw_value)
      end
    end

    def convert_money_to_cents(raw_value)
      if raw_value.match(/\./)
        raw_value.delete('.').to_i
      else
        "#{raw_value}00".to_i
      end
    end
  end

  class Prompt
    using RR::ColourExts

    attr_reader :data
    def initialize(&block)
      @data, @block = Hash.new, block || Proc.new do |prompt|
        require 'readline'
        Readline.readline(prompt, true)
      end
    end

    # options: ['one', 'two']
    # help: 'One of one, two or any integer value.'
    def prompt(key, prompt_text, **options, &block)
      answer = Answer.new
      answer.instance_eval(&block)

      help = help(**options)
      prompt = "<bold>#{prompt_text}</bold>#{" (#{help})" if help}: ".colourise
      @data[key] = answer.run(@block.call(prompt))
      raise InvalidResponse.new if @data[key].nil? && options[:required]
      @data[key]
    rescue InvalidResponse => error
      puts "<red>Invalid response</red>, try again.".colourise
      retry
    end

    # currency_help = " (#{self.show_label_for_self_or_retrieve_by_index(currencies)})" unless currencies.empty?
    # print "Currency#{currency_help}: "
    # expense_data[:currency] = self.self_or_retrieve_by_index(currencies, STDIN.readline.chomp, 'EUR')
    # TODO: Say that it defaults to EUR.
    # TODO: raw_value = 'EUR' vs. default: 'EUR' ???
    # TODO: If it evals as nil, shall we still add it to the data?
    def help(help: nil, options: Array.new, default: nil, **rest)
      if help then help
      elsif help.nil? && ! options.empty?
        options = options.map.with_index { |key, index|
          if default == key
            "<green.bold>#{key}</green.bold> <bright_black>default</bright_black>"
          else
            "<green>#{key}</green> <magenta>#{index + 1}</magenta>"
          end
        }.join(' ').colourise
        # default ? "#{options}; defaults to #{default}" : options
      else end
    end

    def set_completion_proc(proc, character = ' ', &block)
      return block.call unless defined?(::Readline)
      original_append_character = Readline.completion_append_character
      Readline.completion_append_character = ' '
      Readline.completion_proc = proc
      block.call
    ensure
      return unless defined?(::Readline)
      Readline.completion_proc = nil
      Readline.completion_append_character = original_append_character
    end
  end
end
