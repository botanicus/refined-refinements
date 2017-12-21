require 'spec_helper'
require 'pomodoro/exts/hour'

describe Hour do
  describe '#initialize' do
    it 'can be initialised with a mix of hours and minutes' do
      expect(described_class.new(0, 0).to_s).to eql('0:00')
      expect(described_class.new(0, 1).to_s).to eql('0:01')
      expect(described_class.new(0, 20).to_s).to eql('0:20')
      expect(described_class.new(2, 20).to_s).to eql('2:20')
      expect(described_class.new(2, 80).to_s).to eql('3:20')
    end
  end

  describe '#+' do
    it 'can add another instance of Hour' do
      expect(described_class.new(0, 20) + described_class.new(1, 25)).to eql(described_class.new(1, 45))
    end
  end

  describe '#==' do
    it 'returns true if the other instance is of the same length' do
      expect(described_class.new(1) == described_class.new(0, 60)).to be(true)
    end

    it 'returns false if the other instance is not of the same length' do
      expect(described_class.new(0, 5) == described_class.new(0, 1)).to be(false)
    end
  end

  describe '#<' do
    it 'returns true if the other instance is bigger' do
      expect(described_class.new(0, 5) < described_class.new(0, 10)).to be(true)
    end

    it 'returns false if the other instance is smaller' do
      expect(described_class.new(0, 5) < described_class.new(0, 1)).to be(false)
    end

    it 'returns false if the other instance is of the same length' do
      expect(described_class.new(0, 5) < described_class.new(0, 5)).to be(false)
    end
  end

  describe '#>' do
    it 'returns false if the other instance is bigger' do
      expect(described_class.new(0, 5) > described_class.new(0, 10)).to be(false)
    end

    it 'returns true if the other instance is smaller' do
      expect(described_class.new(0, 5) > described_class.new(0, 1)).to be(true)
    end

    it 'returns false if the other instance is of the same length' do
      expect(described_class.new(0, 5) > described_class.new(0, 5)).to be(false)
    end
  end

  describe '#<=' do
    it 'returns true if the other instance is bigger' do
      expect(described_class.new(0, 5) <= described_class.new(0, 10)).to be(true)
    end

    it 'returns false if the other instance is smaller' do
      expect(described_class.new(0, 5) <= described_class.new(0, 1)).to be(false)
    end

    it 'returns true if the other instance is of the same length' do
      expect(described_class.new(0, 5) <= described_class.new(0, 5)).to be(true)
    end
  end

  describe '#>=' do
    it 'returns false if the other instance is bigger' do
      expect(described_class.new(0, 5) >= described_class.new(0, 10)).to be(false)
    end

    it 'returns true if the other instance is smaller' do
      expect(described_class.new(0, 5) >= described_class.new(0, 1)).to be(true)
    end

    it 'returns true if the other instance is of the same length' do
      expect(described_class.new(0, 5) >= described_class.new(0, 5)).to be(true)
    end
  end
end
