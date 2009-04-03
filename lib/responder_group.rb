module Harken
  # Allows you to compose Responders into a group.
  class ResponderGroup
    # Creates a new ResponderGroup.
    #
    # Can be constructed with specific Responder classes or, if left blank
    # every loaded Responder will be composed.
    def initialize(*klasses)
      klasses = Responder.all if klasses.empty?
      @responders = klasses.map {|klass| klass.new }
    end

    # Receives a message from the chat room
    #
    # Returns an array of replies for the room
    def receive(message)
      @responders.map {|r| r.receive(message) }.flatten
    end
  end
end
