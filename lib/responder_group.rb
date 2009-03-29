module Harken
  # Allows you to composite Responders into a group.
  #
  # A ResponderGroup shares the same interface as a Responder
  class ResponderGroup
    def initialize(klasses=Responder.all)
      @responders = klasses.map {|klass| klass.new }
    end

    def receive(message)
      @responders.map {|r| r.receive(message) }.flatten
    end
  end
end
