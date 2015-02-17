def array_contains arr, expected_values
  expected_values.each do |val|
    return false unless arr.include? val
  end
  return true
end