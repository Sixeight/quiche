# coding: utf-8

require 'singleton'

module Quiche

  class Storage

    include Singleton

    attr_accessor :storage

    class << self

      def store(key, data, *rest)
        storage[key] = [data, rest].flatten
      end

      def retrieve(key, flag = nil)
        storage[key]
      end

      private
      def storage
        instance.storage ||= {}
      end
    end
  end
end
