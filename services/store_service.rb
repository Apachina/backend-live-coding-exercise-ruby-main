# frozen_string_literal: true

require 'pstore'

# StoreService storing in file any information(string, array etc.) by key
class StoreService
  attr_reader :store

  def initialize(file_name)
    @store = PStore.new(file_name)
  end

  # adding new data in array by key
  def merge_to_array_by_key(key, str)
    strs = read_by_key(key) || []
    save_by_key(key, strs << str)
  end

  # save data by key
  def save_by_key(key, str)
    store.transaction do
      store[key] = str
    end
  end

  # read data by key
  def read_by_key(key)
    store.transaction(true) do
      store[key]
    end
  end

  # array all values for any keys in store
  def all_stored
    store.transaction(true) do
      store.roots.map do |data_root_name|
        store[data_root_name]
      end
    end
  end

  # all keys in store
  def keys
    store.transaction(true) do
      store.roots
    end
  end
end
