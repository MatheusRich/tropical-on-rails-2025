def assert_equal(expected, actual)
  if expected != actual
    raise "Expected #{expected.inspect} but got #{actual.inspect}"
  end
end

def assert_raises(msg)
  begin
    yield
  rescue => exception
    if msg === exception.message
      return
    else
      raise "Expected exception message to be #{msg.inspect} but got #{exception.message.inspect}"
    end
  end

  raise "Expected an exception but got none"
end
