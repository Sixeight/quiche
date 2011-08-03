# coding: utf-8

require 'quiche/storage'

module Quiche

  # format: [:status, result]
  # statuses:
  #   :responce, :queuing, :client_error, :server_error, :none, :quit
  module Methods

    def set(query, value)

      if query.nil?
        _, key, flag, exptime, bytes, chunk = value.split
        if [key, flag, exptime, bytes].any?(&:nil?)
          return [:none, nil]
        end
        return [:queuing, ['set', key, flag, exptime, bytes]]
      end

      key, flag, exptime, bytes, chunk = query
      value = chunk << value unless chunk.nil?
      data_bytes  = value.chomp.bytes.count
      query_bytes = bytes.to_i
      if data_bytes > query_bytes
        return [:client_error, 'bad data chunk']
      end
      if data_bytes < query_bytes
        return [:queuing, ['set', key, flag, exptime, bytes, value]]
      end
      Storage.store(key, value.chomp, flag, exptime, bytes)
      [:responce, "STORED\r\n"]
    end

    def add(query, data)
      [:server_error, 'not implemented']
    end

    def replace(query, data)
      [:server_error, 'not implemented']
    end

    def append(query, data)
      [:server_error, 'not implemented']
    end

    def prepend(query, data)
      [:server_error, 'not implemented']
    end

    def get(_, query)
      method, *keys = query.split
      result = ''
      keys.each do |key|
        data, flag, exptime, bytes = Storage.retrieve(key)
        next if data.nil?
        result << "VALUE #{key} #{flag} #{bytes}\r\n#{data}\r\n"
      end
      result << "END\r\n"
      [:responce, result]
    end
    alias gets get

    def quit(query, data)
      [:quit, nil]
    end
  end
end
