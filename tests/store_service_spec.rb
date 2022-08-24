# frozen_string_literal: true

require './services/store_service'
require 'rspec'

RSpec.describe StoreService do
  let(:file_name) { 'file_name.pstore' }
  let(:key) { 'key' }
  let(:another_key) { 'another_key' }
  let(:store) { store_service.store }

  subject(:store_service) { described_class.new(file_name) }

  before do
    stub_const('UserQuestionnaireService::ANSWERS_STORE_NAME', 'test.answers.pstore')
  end

  after(:each) do
    File.delete(file_name) if File.exist?(file_name)
  end

  describe '#merge_to_array_by_key' do
    let(:old_value) { 'old_value' }

    before do
      store_service.merge_to_array_by_key(key, 'value')
    end

    context 'when store is empty' do
      it 'adds new string' do
        expect(
          store.transaction(true) do
            store.roots.map do |data_root_name|
              store[data_root_name]
            end
          end
        ).to include(['value'])
      end

      it 'returns nil by another key' do
        expect(
          store.transaction(true) do
            store[another_key]
          end
        ).to eq nil
      end
    end

    context 'when store has data' do
      before do
        store.transaction do
          store[key] << old_value
        end
      end

      it 'saves previous array and adds new string' do
        expect(
          store.transaction(true) do
            store.roots.map do |data_root_name|
              store[data_root_name]
            end
          end
        ).to include(include(old_value, 'value'))
      end
    end

    context 'when store has data and saves by another key' do
      before do
        store.transaction do
          store[key] << old_value
        end

        store.transaction do
          store[another_key] = ['another_value']
        end
      end

      it 'saves previous array and adds new string' do
        expect(
          store.transaction(true) do
            store.roots.map do |data_root_name|
              store[data_root_name]
            end
          end
        ).to include(include(old_value, 'value'), include('another_value'))
      end
    end
  end

  describe '#save_by_key' do
    before do
      store_service.save_by_key(key, 'value')
    end

    context 'when before value is nil' do
      it 'saves new value' do
        expect(
          store.transaction(true) do
            store[key]
          end
        ).to eq 'value'
      end
    end

    context 'when before value is not nil' do
      it 'saves new value' do
        store_service.save_by_key(key, 'another_value')

        expect(
          store.transaction(true) do
            store[key]
          end
        ).to eq 'another_value'
      end
    end
  end

  describe '#read_by_key' do
    context 'when value is nil' do
      it 'returns nil' do
        expect(store_service.read_by_key(key)).to eq nil
      end
    end

    context 'when value is not nil' do
      it 'returns value' do
        store_service.save_by_key(key, 'value')
        expect(store_service.read_by_key(key)).to eq 'value'
      end
    end
  end

  describe '#all_stored' do
    context 'when value is nil' do
      it 'returns empty array' do
        expect(store_service.all_stored).to eq []
      end
    end

    context 'when value is not nil' do
      it 'returns all values' do
        store_service.save_by_key(key, 'value')
        store_service.save_by_key(another_key, 'another_value')
        expect(store_service.all_stored).to include('value', 'another_value')
      end
    end
  end

  describe '#keys' do
    context 'when has not keys' do
      it 'returns empty array' do
        expect(store_service.keys).to eq []
      end
    end

    context 'when has keys' do
      it 'returns all values' do
        store_service.save_by_key(key, 'value')
        store_service.save_by_key(another_key, 'another_value')
        expect(store_service.keys).to include('key', 'another_key')
      end
    end
  end
end
