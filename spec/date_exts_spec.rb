require 'pomodoro/exts/date_exts'

describe DateExts do
  let(:monday)    { Date.new(2017, 2, 20).extend(described_class) }
  let(:tuesday)   { Date.new(2017, 2, 21).extend(described_class) }
  let(:wednesday) { Date.new(2017, 2, 22).extend(described_class) }
  let(:thursday)  { Date.new(2017, 2, 23).extend(described_class) }
  let(:friday)    { Date.new(2017, 2, 24).extend(described_class) }
  let(:saturday)  { Date.new(2017, 2, 25).extend(described_class) }
  let(:sunday)    { Date.new(2017, 2, 26).extend(described_class) }

  describe '#weekend?' do
    it 'returns true for week days' do
      expect(saturday.weekend?).to be(true)
      expect(sunday.weekend?).to be(true)
    end

    it 'returns false for days of the weekend' do
      expect(monday.weekend?).to be(false)
      expect(tuesday.weekend?).to be(false)
      expect(wednesday.weekend?).to be(false)
      expect(thursday.weekend?).to be(false)
      expect(friday.weekend?).to be(false)
    end
  end

  describe '#weekday?' do
    it 'returns false for days of the weekend' do
      expect(saturday.weekday?).to be(false)
      expect(sunday.weekday?).to be(false)
    end

    it 'returns true for days of the weekend' do
      expect(monday.weekday?).to be(true)
      expect(tuesday.weekday?).to be(true)
      expect(wednesday.weekday?).to be(true)
      expect(thursday.weekday?).to be(true)
      expect(friday.weekday?).to be(true)
    end
  end
end
