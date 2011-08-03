# coding: utf-8

require 'eventmachine'
require 'quiche/connection'

module Quiche

  class Runner
    def self.run(args)
      EventMachine.run do
        EventMachine.start_server 'localhost', 11311, Connection
      end
    end
  end
end
