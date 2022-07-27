# frozen_string_literal: true

require 'sleeping_king_studios/yard/data/types/parser'

RSpec.describe SleepingKingStudios::Yard::Data::Types::Parser do
  subject(:parser) { described_class.new(registry: registry) }

  let(:registry) { ::YARD::Registry }

  before(:context) { ::YARD::Registry.clear } # rubocop:disable RSpec/BeforeAfterAll

  after(:example) { ::YARD::Registry.clear }

  describe '::ParseError' do
    include_examples 'should define constant',
      :ParseError,
      -> { be_a(Class).and(be < StandardError) }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:registry)
    end
  end

  describe '#parse' do
    def array_type(items:, name:, ordered: false)
      SleepingKingStudios::Yard::Data::Types::ParameterizedType.new(
        name:     name,
        items:    items,
        ordered:  ordered,
        registry: registry
      )
    end

    def basic_type(name:)
      SleepingKingStudios::Yard::Data::Types::Type.new(
        name:     name,
        registry: registry
      )
    end

    def hash_type(keys:, name:, values:)
      SleepingKingStudios::Yard::Data::Types::KeyValueType.new(
        keys:     keys,
        name:     name,
        registry: registry,
        values:   values
      )
    end

    it { expect(parser).to respond_to(:parse).with(1).argument }

    describe 'with nil' do
      it { expect(parser.parse(nil)).to be == [] }
    end

    describe 'with an empty string' do
      it { expect(parser.parse('')).to be == [] }
    end

    describe 'with a definition' do
      let(:type) { 'Rocket' }
      let(:expected) do
        [
          basic_type(name: 'Rocket')
        ]
      end

      it { expect(parser.parse(type)).to be == expected }
    end

    describe 'with a class method' do
      let(:type) { '.build' }
      let(:expected) do
        [
          basic_type(name: '.build')
        ]
      end

      it { expect(parser.parse(type)).to be == expected }
    end

    describe 'with an instance method' do
      let(:type) { '#call' }
      let(:expected) do
        [
          basic_type(name: '#call')
        ]
      end

      it { expect(parser.parse(type)).to be == expected }
    end

    describe 'with a literal' do
      let(:type) { 'nil' }
      let(:expected) do
        [
          basic_type(name: 'nil')
        ]
      end

      it { expect(parser.parse(type)).to be == expected }
    end

    describe 'with a list of types' do
      let(:type) { 'String, Symbol, nil' }
      let(:expected) do
        [
          basic_type(name: 'String'),
          basic_type(name: 'Symbol'),
          basic_type(name: 'nil')
        ]
      end

      it { expect(parser.parse(type)).to be == expected }
    end

    describe 'with a parameterized type' do
      let(:type) { 'Array<String>' }
      let(:expected) do
        [
          array_type(
            name:  'Array',
            items: [
              basic_type(name: 'String')
            ]
          )
        ]
      end

      it { expect(parser.parse(type)).to be == expected }
    end

    describe 'with a parameterized type with a list of types' do
      let(:type) { 'Array<String, Symbol, nil>' }
      let(:expected) do
        [
          array_type(
            name:  'Array',
            items: [
              basic_type(name: 'String'),
              basic_type(name: 'Symbol'),
              basic_type(name: 'nil')
            ]
          )
        ]
      end

      it { expect(parser.parse(type)).to be == expected }
    end

    describe 'with a parameterized type with a list of parameterized types' do
      let(:type) { 'Array<Array<String>, Set<String>>' }
      let(:expected) do
        [
          array_type(
            name:  'Array',
            items: [
              array_type(
                name:  'Array',
                items: [
                  basic_type(name: 'String')
                ]
              ),
              array_type(
                name:  'Set',
                items: [
                  basic_type(name: 'String')
                ]
              )
            ]
          )
        ]
      end

      it { expect(parser.parse(type)).to be == expected }
    end

    describe 'with a nested parameterized type' do
      let(:type) { 'Array<Array<Array<Integer>>>' }
      let(:expected) do
        [
          array_type(
            name:  'Array',
            items: [
              array_type(
                name:  'Array',
                items: [
                  array_type(
                    name:  'Array',
                    items: [
                      basic_type(name: 'Integer')
                    ]
                  )
                ]
              )
            ]
          )
        ]
      end

      it { expect(parser.parse(type)).to be == expected }
    end

    describe 'with an improperly closed parameterized type' do
      let(:type) { 'Array<String>>' }
      let(:error_message) do
        %(invalid character `>' at index 13: ">" must terminate a ) \
          'parameterized type'
      end

      it 'should raise an exception' do
        expect { parser.parse(type) }
          .to raise_error described_class::ParseError, error_message
      end
    end

    describe 'with an improperly opened parameterized type' do
      let(:type) { 'Array<<String>>' }
      let(:error_message) do
        %(invalid character `<' at index 6: "<" must follow a token name)
      end

      it 'should raise an exception' do
        expect { parser.parse(type) }
          .to raise_error described_class::ParseError, error_message
      end
    end

    describe 'with an unclosed parameterized type' do
      let(:type) { 'Array<String' }
      let(:error_message) do
        'unterminated parameterized type - is there a missing ">" character?'
      end

      it 'should raise an exception' do
        expect { parser.parse(type) }
          .to raise_error described_class::ParseError, error_message
      end
    end

    describe 'with an ordered type' do
      let(:type) { 'Array<(Symbol, Integer)>' }
      let(:expected) do
        [
          array_type(
            name:    'Array',
            ordered: true,
            items:   [
              basic_type(name: 'Symbol'),
              basic_type(name: 'Integer')
            ]
          )
        ]
      end

      it { expect(parser.parse(type)).to be == expected }
    end

    describe 'with a nested ordered type' do
      let(:type) { 'Array<(String, Array<(Integer, Integer)>)>' }
      let(:expected) do
        [
          array_type(
            name:    'Array',
            ordered: true,
            items:   [
              basic_type(name: 'String'),
              array_type(
                name:    'Array',
                ordered: true,
                items:   [
                  basic_type(name: 'Integer'),
                  basic_type(name: 'Integer')
                ]
              )
            ]
          )
        ]
      end

      it { expect(parser.parse(type)).to be == expected }
    end

    describe 'with an improperly closed ordered type' do
      let(:type) { 'Array<(String))>' }
      let(:error_message) do
        %(invalid character `\)' at index 13: "\)>" must terminate an ) \
          'order-dependent list'
      end

      it 'should raise an exception' do
        expect { parser.parse(type) }
          .to raise_error described_class::ParseError, error_message
      end
    end

    describe 'with an improperly opened ordered type' do
      let(:type) { 'Array(String)' }
      let(:error_message) do
        %(invalid character `\(' at index 5: "<\(" must start an ) \
          'order-dependent list'
      end

      it 'should raise an exception' do
        expect { parser.parse(type) }
          .to raise_error described_class::ParseError, error_message
      end
    end

    describe 'with an partially closed ordered type' do
      let(:type) { 'Array<(String)' }
      let(:error_message) do
        %(invalid character `\)' at index 13: "\)>" must terminate an ) \
          'order-dependent list'
      end

      it 'should raise an exception' do
        expect { parser.parse(type) }
          .to raise_error described_class::ParseError, error_message
      end
    end

    describe 'with a key-value type' do
      let(:type) { 'Hash{String, Symbol=>Integer, nil}' }
      let(:expected) do
        [
          hash_type(
            name:   'Hash',
            keys:   [
              basic_type(name: 'String'),
              basic_type(name: 'Symbol')
            ],
            values: [
              basic_type(name: 'Integer'),
              basic_type(name: 'nil')
            ]
          )
        ]
      end

      it { expect(parser.parse(type)).to be == expected }
    end

    describe 'with a nested key-value type' do
      let(:type) { 'Hash{String => Hash{String => Hash{String => String}}}' }
      let(:expected) do
        [
          hash_type(
            name:   'Hash',
            keys:   [basic_type(name: 'String')],
            values: [
              hash_type(
                name:   'Hash',
                keys:   [basic_type(name: 'String')],
                values: [
                  hash_type(
                    name:   'Hash',
                    keys:   [basic_type(name: 'String')],
                    values: [basic_type(name: 'String')]
                  )
                ]
              )
            ]
          )
        ]
      end

      it { expect(parser.parse(type)).to be == expected }
    end

    describe 'with an improperly closed key-value type' do
      let(:type) { 'Hash{String=>String}}' }
      let(:error_message) do
        %(invalid character `}' at index 20: "}" must terminate a ) \
          'key-value type'
      end

      it 'should raise an exception' do
        expect { parser.parse(type) }
          .to raise_error described_class::ParseError, error_message
      end
    end

    describe 'with an improperly opened key-value type' do
      let(:type) { 'Hash{{String=>String}' }
      let(:error_message) do
        %(invalid character `{' at index 5: "{" must follow a token name)
      end

      it 'should raise an exception' do
        expect { parser.parse(type) }
          .to raise_error described_class::ParseError, error_message
      end
    end

    describe 'with an improperly unseparated key-value type' do
      let(:type) { 'Hash{String=String}' }
      let(:error_message) do
        %(invalid character `=' at index 11: "=>" must separate hash keys ) \
          'and values'
      end

      it 'should raise an exception' do
        expect { parser.parse(type) }
          .to raise_error described_class::ParseError, error_message
      end
    end

    describe 'with an unseparated key-value type' do
      let(:type) { 'Hash{String}' }
      let(:error_message) do
        %(unterminated key-value type - is there a missing "=>" character?)
      end

      it 'should raise an exception' do
        expect { parser.parse(type) }
          .to raise_error described_class::ParseError, error_message
      end
    end

    describe 'with an unclosed key-value type' do
      let(:type) { 'Hash{String=>String' }
      let(:error_message) do
        %(unterminated key-value type - is there a missing "}" character?)
      end

      it 'should raise an exception' do
        expect { parser.parse(type) }
          .to raise_error described_class::ParseError, error_message
      end
    end

    describe 'with a deeply nested type' do
      let(:type) do
        'String, Array<(Array<Integer>, Hash{String, Symbol => ' \
          'Array<(Integer, Integer)>}, Enumerable)>, true, false, nil'
      end
      let(:expected) do
        [
          basic_type(name: 'String'),
          array_type(
            name:    'Array',
            ordered: true,
            items:   [
              array_type(
                name:    'Array',
                ordered: false,
                items:   [basic_type(name: 'Integer')]
              ),
              hash_type(
                name:   'Hash',
                keys:   [
                  basic_type(name: 'String'),
                  basic_type(name: 'Symbol')
                ],
                values: [
                  array_type(
                    name:    'Array',
                    ordered: true,
                    items:   [
                      basic_type(name: 'Integer'),
                      basic_type(name: 'Integer')
                    ]
                  )
                ]
              ),
              basic_type(name: 'Enumerable')
            ]
          ),
          basic_type(name: 'true'),
          basic_type(name: 'false'),
          basic_type(name: 'nil')
        ]
      end

      it { expect(parser.parse(type)).to be == expected }
    end
  end

  describe '#registry' do
    include_examples 'should define private reader',
      :registry,
      -> { ::YARD::Registry }
  end
end
