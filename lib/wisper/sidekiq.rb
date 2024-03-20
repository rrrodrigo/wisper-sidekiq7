require 'wisper'
require 'sidekiq'

require 'wisper/sidekiq/version'

module Wisper
  class SidekiqBroadcaster
    attr_reader :options

    def initialize(options = {})
      @options = options == true ? {} : options
    end

    def broadcast(subscriber, _publisher, event, args)
      BroadcastJob.perform_async(
        'subscriber' => subscriber.name,
        'event' => event,
        'args' => args
      )
    end

    def self.register
      Wisper.configure do |config|
        config.broadcaster :sidekiq, Proc.new { |options| SidekiqBroadcaster.new(options) }
        config.broadcaster :async,   Proc.new { |options| SidekiqBroadcaster.new(options) }
      end
    end
  end
end

Wisper::SidekiqBroadcaster.register
