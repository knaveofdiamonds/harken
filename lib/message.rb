module Harken

module Message
  include Treetop::Runtime

  def root
    @root || :message
  end

  module Message0
    def interpret(vars=[])
      regex = Regexp.compile("^" + elements.map {|e| e.interpret(vars) }.join + "$")

	eigenclass = (class << regex; self; end)
	eigenclass.send(:define_method, :variables) do
	  vars
	end

	eigenclass.send(:define_method, :match) do
	  match = super
	  return if match.nil?
	  vars.each_with_index do |sym, i|
	    match.instance_eval "def #{sym}\n captures[#{i}]\n end"
	  end
	  match
	end

	regex
    end
  end

  def _nt_message
    start_index = index
    if node_cache[:message].has_key?(index)
      cached = node_cache[:message][index]
      @index = cached.interval.end if cached
      return cached
    end

    r0 = _nt_expression
    r0.extend(Message0)

    node_cache[:message][start_index] = r0

    return r0
  end

  def _nt_expression
    start_index = index
    if node_cache[:expression].has_key?(index)
      cached = node_cache[:expression][index]
      @index = cached.interval.end if cached
      return cached
    end

    s0, i0 = [], index
    loop do
      i1 = index
      r2 = _nt_word
      if r2
        r1 = r2
      else
        r3 = _nt_whitespace
        if r3
          r1 = r3
        else
          r4 = _nt_identifier
          if r4
            r1 = r4
          else
            r5 = _nt_optional
            if r5
              r1 = r5
            else
              self.index = i1
              r1 = nil
            end
          end
        end
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    if s0.empty?
      self.index = i0
      r0 = nil
    else
      r0 = SyntaxNode.new(input, i0...index, s0)
    end

    node_cache[:expression][start_index] = r0

    return r0
  end

  module Whitespace0
  end

  module Whitespace1
    def interpret(vars=[])
      "\\ +"
    end
  end

  def _nt_whitespace
    start_index = index
    if node_cache[:whitespace].has_key?(index)
      cached = node_cache[:whitespace][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    s1, i1 = [], index
    loop do
      if input.index(" ", index) == index
        r2 = (SyntaxNode).new(input, index...(index + 1))
        @index += 1
      else
        terminal_parse_failure(" ")
        r2 = nil
      end
      if r2
        s1 << r2
      else
        break
      end
    end
    if s1.empty?
      self.index = i1
      r1 = nil
    else
      r1 = SyntaxNode.new(input, i1...index, s1)
    end
    s0 << r1
    if r1
      i3 = index
      if input.index("[", index) == index
        r4 = (SyntaxNode).new(input, index...(index + 1))
        @index += 1
      else
        terminal_parse_failure("[")
        r4 = nil
      end
      if r4
        r3 = nil
      else
        self.index = i3
        r3 = SyntaxNode.new(input, index...index)
      end
      s0 << r3
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(Whitespace0)
      r0.extend(Whitespace1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:whitespace][start_index] = r0

    return r0
  end

  module Word0
    def interpret(vars=[])
      Regexp.escape(text_value)
    end
  end

  def _nt_word
    start_index = index
    if node_cache[:word].has_key?(index)
      cached = node_cache[:word][index]
      @index = cached.interval.end if cached
      return cached
    end

    s0, i0 = [], index
    loop do
      if input.index(Regexp.new('[^><\\[\\] ]'), index) == index
        r1 = (SyntaxNode).new(input, index...(index + 1))
        @index += 1
      else
        r1 = nil
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    if s0.empty?
      self.index = i0
      r0 = nil
    else
      r0 = SyntaxNode.new(input, i0...index, s0)
      r0.extend(Word0)
    end

    node_cache[:word][start_index] = r0

    return r0
  end

  module Identifier0
    def identifier_value
      elements[1]
    end

  end

  def _nt_identifier
    start_index = index
    if node_cache[:identifier].has_key?(index)
      cached = node_cache[:identifier][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    if input.index('<', index) == index
      r1 = (SyntaxNode).new(input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure('<')
      r1 = nil
    end
    s0 << r1
    if r1
      r2 = _nt_identifier_value
      s0 << r2
      if r2
        if input.index('>', index) == index
          r3 = (SyntaxNode).new(input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure('>')
          r3 = nil
        end
        s0 << r3
      end
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(Identifier0)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:identifier][start_index] = r0

    return r0
  end

  module IdentifierValue0
  end

  module IdentifierValue1
    def interpret(vars=[])
      vars << text_value.to_sym
      "(.+?)"
    end
  end

  def _nt_identifier_value
    start_index = index
    if node_cache[:identifier_value].has_key?(index)
      cached = node_cache[:identifier_value][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    if input.index(Regexp.new('[a-zA-Z_]'), index) == index
      r1 = (SyntaxNode).new(input, index...(index + 1))
      @index += 1
    else
      r1 = nil
    end
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        if input.index(Regexp.new('[a-zA-Z_0-9 ]'), index) == index
          r3 = (SyntaxNode).new(input, index...(index + 1))
          @index += 1
        else
          r3 = nil
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      r2 = SyntaxNode.new(input, i2...index, s2)
      s0 << r2
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(IdentifierValue0)
      r0.extend(IdentifierValue1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:identifier_value][start_index] = r0

    return r0
  end

  module Optional0
    def open_optional
      elements[0]
    end

    def expression
      elements[1]
    end

    def close_optional
      elements[2]
    end
  end

  def _nt_optional
    start_index = index
    if node_cache[:optional].has_key?(index)
      cached = node_cache[:optional][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_open_optional
    s0 << r1
    if r1
      r2 = _nt_expression
      s0 << r2
      if r2
        r3 = _nt_close_optional
        s0 << r3
      end
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(Optional0)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:optional][start_index] = r0

    return r0
  end

  module OpenOptional0
  end

  module OpenOptional1
    def interpret(vars=[])
      optional_left_space = (text_value.length != text_value.lstrip.length) ? "\\ +" : ""
      "(?:" + optional_left_space
    end
  end

  def _nt_open_optional
    start_index = index
    if node_cache[:open_optional].has_key?(index)
      cached = node_cache[:open_optional][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    s1, i1 = [], index
    loop do
      if input.index(" ", index) == index
        r2 = (SyntaxNode).new(input, index...(index + 1))
        @index += 1
      else
        terminal_parse_failure(" ")
        r2 = nil
      end
      if r2
        s1 << r2
      else
        break
      end
    end
    r1 = SyntaxNode.new(input, i1...index, s1)
    s0 << r1
    if r1
      if input.index("[", index) == index
        r3 = (SyntaxNode).new(input, index...(index + 1))
        @index += 1
      else
        terminal_parse_failure("[")
        r3 = nil
      end
      s0 << r3
    end
    if s0.last
      r0 = (SyntaxNode).new(input, i0...index, s0)
      r0.extend(OpenOptional0)
      r0.extend(OpenOptional1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:open_optional][start_index] = r0

    return r0
  end

  module CloseOptional0
  end

  module CloseOptional1
    def interpret(vars=[])
      " +)?"
    end
  end

  module CloseOptional2
    def interpret(vars=[])
      ")?"
    end
  end

  def _nt_close_optional
    start_index = index
    if node_cache[:close_optional].has_key?(index)
      cached = node_cache[:close_optional][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0 = index
    i1, s1 = index, []
    if input.index("]", index) == index
      r2 = (SyntaxNode).new(input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure("]")
      r2 = nil
    end
    s1 << r2
    if r2
      s3, i3 = [], index
      loop do
        if input.index(" ", index) == index
          r4 = (SyntaxNode).new(input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure(" ")
          r4 = nil
        end
        if r4
          s3 << r4
        else
          break
        end
      end
      if s3.empty?
        self.index = i3
        r3 = nil
      else
        r3 = SyntaxNode.new(input, i3...index, s3)
      end
      s1 << r3
      if r3
        i5 = index
        if input.index("[", index) == index
          r6 = (SyntaxNode).new(input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure("[")
          r6 = nil
        end
        if r6
          r5 = nil
        else
          self.index = i5
          r5 = SyntaxNode.new(input, index...index)
        end
        s1 << r5
      end
    end
    if s1.last
      r1 = (SyntaxNode).new(input, i1...index, s1)
      r1.extend(CloseOptional0)
      r1.extend(CloseOptional1)
    else
      self.index = i1
      r1 = nil
    end
    if r1
      r0 = r1
    else
      if input.index("]", index) == index
        r7 = (SyntaxNode).new(input, index...(index + 1))
        r7.extend(CloseOptional2)
        @index += 1
      else
        terminal_parse_failure("]")
        r7 = nil
      end
      if r7
        r0 = r7
      else
        self.index = i0
        r0 = nil
      end
    end

    node_cache[:close_optional][start_index] = r0

    return r0
  end

end

class MessageParser < Treetop::Runtime::CompiledParser
  include Message
end


end