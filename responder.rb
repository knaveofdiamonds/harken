module Harken
  # Base class for responding to messages directed at the chat room bot.
  # This should be subclassed and appropriate actions to be listened to
  # defined with <code>listen</code>.
  #
  # A hello world example:
  #
  # <pre><code>
  # class Hello < Harken::Responder
  #   listen "greet <person>" do |m|
  #     "Hello, #{m.person}!"
  #   end
  # end
  # </code></pre>
  class Responder
    # Stores every subclass
    @@responders = []

    # The format parser
    @@parser = MessageParser.new
    
    class << self
      attr_reader :listeners

      def inherited(klass)
        @@responders << klass
        klass.class_eval { @listeners = {} }
      end

      # Listen for a message and call the given block if it matches the format string.
      #
      # Raises an exception if the format string could not be parsed successfully
      def listen(format, &block)
        matcher = @@parser.interpret(format)
        raise "Could not listen for '#{format}'" unless matcher
        @listeners[matcher] = block
      end
      
      # Returns an array with all Responder subclasses.
      def all_responders 
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
