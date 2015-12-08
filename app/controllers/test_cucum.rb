array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
to_delete = [5,6,7]
to_delete.each do |d|
  a = array
  a.delete(d)
end
puts "array"
p array
