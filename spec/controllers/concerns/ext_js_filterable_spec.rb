require 'rails_helper'

RSpec.describe ExtJsFilterable do
  # Lightweight host class to test internal helpers in isolation.
  # Integration tests for full filter behavior live in the per-controller
  # *_filters_spec.rb files (artists, albums, tracks).
  let(:host_class) do
    Class.new do
      include ExtJsFilterable

      attr_accessor :params

      def initialize(params = {})
        @params = ActionController::Parameters.new(params)
      end

      # Expose private methods for direct testing
      public :parse_filters, :sanitize_like, :apply_single_filter
    end
  end

  describe '#parse_filters' do
    it 'returns the array directly when params[:filter] is already an Array' do
      filters = [{ 'property' => 'name', 'value' => 'test' }]
      host = host_class.new(filter: filters)
      result = host.parse_filters
      expect(result).to be_an(Array)
      expect(result.length).to eq(1)
      expect(result.first['property']).to eq('name')
      expect(result.first['value']).to eq('test')
    end

    it 'parses a JSON string into an array' do
      json = '[{"property":"name","value":"test"}]'
      host = host_class.new(filter: json)
      expect(host.parse_filters).to eq([{ 'property' => 'name', 'value' => 'test' }])
    end

    it 'returns empty array for malformed JSON' do
      host = host_class.new(filter: 'not-json{{{')
      expect(host.parse_filters).to eq([])
    end

    it 'returns empty array when filter is nil' do
      host = host_class.new(filter: nil)
      expect(host.parse_filters).to eq([])
    end

    it 'parses an empty JSON array' do
      host = host_class.new(filter: '[]')
      expect(host.parse_filters).to eq([])
    end
  end

  describe '#sanitize_like' do
    let(:host) { host_class.new }

    it 'escapes percent signs' do
      expect(host.sanitize_like('100%')).to eq('100\%')
    end

    it 'escapes underscores' do
      expect(host.sanitize_like('a_b')).to eq('a\_b')
    end

    it 'escapes backslashes' do
      expect(host.sanitize_like('a\\b')).to eq('a\\\\b')
    end

    it 'handles multiple special characters together' do
      expect(host.sanitize_like('100% a_b \\ done')).to eq('100\% a\_b \\\\ done')
    end

    it 'leaves normal text unchanged' do
      expect(host.sanitize_like('hello world')).to eq('hello world')
    end

    it 'handles empty string' do
      expect(host.sanitize_like('')).to eq('')
    end
  end

  describe '#apply_single_filter' do
    let(:host) { host_class.new }

    it 'returns scope unchanged for unknown filter kind' do
      scope = double('scope')
      config = { kind: :unknown_kind, column: 'x' }
      filter = { 'value' => 'test' }

      result = host.apply_single_filter(scope, config, filter)
      expect(result).to equal(scope)
    end
  end
end
