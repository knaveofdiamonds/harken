class SimpleResponder < Harken::Responder
  listen "test" do
    "foo"
  end

  listen "test <variable>" do |m|
    "value is '#{m.variable}'"
  end
end

class DuplicateResponder < Harken::Responder
  listen "test" do
    "first"
  end

  listen "test" do
    "second"
  end
end
