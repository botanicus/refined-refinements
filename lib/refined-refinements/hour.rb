# frozen_string_literal: true

class Hour
  def self.parse(string)
    hours, minutes = string.split(':')
    self.new(hours.to_i, minutes.to_i)
  end

  def self.now
    self.from_time(Time.now)
  end

  def self.from_time(time)
    self.new(time.hour, time.min)
  end

  attr_reader :minutes
  def initialize(*args)
    if args.length == 1 && args.first.is_a?(Hash)
      self.initialize_from_keyword_args(**args.first)
    else
      self.initialize_legacy(*args)
    end
  end

  def initialize_legacy(hours, minutes = 0)
    @minutes = (hours * 60) + minutes
  end

  # TODO: parse 0:1:20
  # TODO: format 1:30 / 90min
  # TODO: hr: 1, min: 20, sec: false to disable sec or sth like that.
  def initialize_from_keyword_args(hr: 0, min: 0, sec: 0)
    @minutes = (hours * 60) + minutes
  end

  # Doesn't work if it's smaller - larger:
  # Hour.parse('0:58') - Hour.parse('1:00')
  # => -1:58
  [:+, :-].each do |method_name|
    define_method(method_name) do |hour_or_minutes|
      if hour_or_minutes.is_a?(self.class)
        self.class.new(0, @minutes.send(method_name, hour_or_minutes.minutes))
      elsif hour_or_minutes.is_a?(Integer)
        self.class.new(0, @minutes.send(method_name, hour_or_minutes))
      else
        raise TypeError.new("Hour or Integer (for minutes) expected, got #{hour_or_minutes.class}.")
      end
    end
  end

  def /(ratio)
    self.class.new(0, self.minutes / ratio)
  end

  def hours
    if (@minutes / 60).round > (@minutes / 60)
      (@minutes / 60).round - 1
    else
      (@minutes / 60).round
    end
  end

  # Currently unused, but it might be in the future.
  # def *(rate)
  #   (@minutes * (rate / 60.0)).round(2)
  # end

  [:==, :eql?, :<, :<=, :>, :>=, :<=>].each do |method_name|
    define_method(method_name) do |anotherHour|
      if anotherHour.is_a?(self.class)
        self.minutes.send(method_name, anotherHour.minutes)
      elsif anotherHour.is_a?(Time)
        self.send(method_name, Hour.now)
      else
        raise TypeError.new("#{self.class}##{method_name} expects #{self.class} or Time object.")
      end
    end
  end

  def inspect
    "#{self.hours}:#{format('%02d', self.minutes_over_the_hour)}"
  end
  alias_method :to_s, :inspect

  def to_time(today = Time.now)
    Time.new(today.year, today.month, today.day, self.hours, self.minutes_over_the_hour)
  end

  protected
  def minutes_over_the_hour
    @minutes - (self.hours * 60)
  end
end
