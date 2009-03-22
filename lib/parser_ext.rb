# Extensions to Syntax nodes and the treetop-generated parser.

module Harken
  # Make every node in the syntax tree respond to "interpret"
  module PassThroughInterpret
    def interpret(vars=[])
      elements.map {|e| e.interpret(vars) }.join if nonterminal?
    end
  end
  Treetop::Runtime::SyntaxNode.send(:include, PassThroughInterpret)


  class MessageParser
    # Interprets a message format string and returns an object with a #match method.
    def interpret(str)
      syntax_tree = parse(str)
      syntax_tree.interpret if syntax_tree
    end
  end
end
