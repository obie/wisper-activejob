require 'wisper'
require 'wisper/active_job/version'
require 'active_job'

module Wisper
  class ActiveJobBroadcaster
    def broadcast(subscriber, publisher, event, *args, **kwargs)
      Wrapper.perform_later(subscriber.name, event, *args, **kwargs)
    end

    class Wrapper < ::ActiveJob::Base
      queue_as :default

      def perform(class_name, event, *args, **kwargs)
        listener = class_name.constantize
        listener.public_send(event, *args, **kwargs)
      end
    end

    def self.register
      Wisper.configure do |config|
        config.broadcaster :active_job, ActiveJobBroadcaster.new
        config.broadcaster :async,      ActiveJobBroadcaster.new
      end
    end
  end
end

Wisper::ActiveJobBroadcaster.register