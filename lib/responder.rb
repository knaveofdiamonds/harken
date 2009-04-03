module Harken
  # Base class for responding to messages directed at the chat room bot.
  # This should be subclassed and appropriate actions to be listened to
  # defined with <code>listen</code>.
  #
  # A hello world example:
  #
  #     class Hello < Harken::Responder
  #       listen "greet <person>" do |m|
  #         "Hello, #{m.person}!"
  #       end
  #     end
  #
  # See the README for a description of how to write a "listen" string
  #
  # Subclasses can implement initialize, but if they do <b>they should not require
  # parameters</b>.
  class Responder
    # Stores every subclass
    @@responders = []

    # The format parser
    @@parser = MessageParser.new
    
    class << self
      attr_reader :listeners

      def inherited(klass) # :nodoc:
        @@responders << klass
        klass.class_eval { @listeners = {} }
      end

      # Listen for a message and call the given block if it matches the format string.
      #
      # Raises an exception if the format string could not be parsed successfully.
      def listen(format, &block)
        matcher = @@parser.interpret(format)
        raise "Could not listen for '#{format}'" unless matcher
        @listeners[matcher] = block
      end
      
      # Returns an array with all Responder subclasses.
      def all
        @@responders
      end
    end

    # Receive a message and call any blocks that have been registered with <code>listen</code>
    # if the message matches the format.
    def receive(message)
      self.class.listeners.map do |matcher, block|
        match = matcher.match(message)
        block.call(match) if match
      end.compact
    end
  end
end
