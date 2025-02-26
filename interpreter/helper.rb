def assert_equal(expected, actual)
  if expected != actual
    caller_location = caller_locations(1,1)[0]
    abort "Expected #{expected.inspect} but got #{actual.inspect}\nDiff:\n- #{expected.inspect}\n+ #{actual.inspect}\nat: #{__method__} #{caller_location}"
  end
end

def assert_raises(msg)
  caller_location = caller_locations(1,1)[0]
  begin
    yield
  rescue => exception
    if msg === exception.message
      return
    else
      abort "Expected exception message to be #{msg.inspect} but got #{exception.message.inspect}\nat: #{__method__} #{caller_location}"
    end
  end

  abort "Expected an exception but got none\nat: #{__method__} on #{caller_location}"
end
