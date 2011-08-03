# coding: utf-8

require 'quiche/methods'

module Quiche

  class Connection < EventMachine::Connection

    include Methods

    attr_accessor :request_stack

    def initialize
      send_data "welcome to quiche ver 0.0.1\r\n"
      @request_stack = []
    end

    def error
      "ERROR\r\n"
    end

    def client_error(message)
      "CLIENT_ERROR #{message}\r\nERROR\r\n"
    end

    def server_error(message)
      "SERVER_ERROR #{message}\r\nERROR\r\n"
    end

    def receive_data(data)

      method = data.split.shift

      if query = self.request_stack.pop
        method, *query = query
      end

      status, result = __send__(method, query, data) rescue NameError

      case status
      when :responce
        send_data result
      when :queuing
        self.request_stack << result
      when :client_error
        send_data client_error(result)
      when :server_error
        send_data server_error(result)
      when :quit
        close_connection
      else
        send_data error
      end
    end
  end
end
