require 'nokogiri'
#reg = Regexp.new(/\w*-\w*-\w*-\w*-\w*-testsuite.xml/)

docs = Dir['*-testsuite.xml']

failed_sum = 0
all_sum = 0

docs.each do |d|
  doc = File.open(d)
  xml = Nokogiri::XML(doc)
  failed_sum+= xml.xpath("//test-case[@status='failed']").size
  all_sum+= xml.xpath("//test-case").size
end

  puts "#{failed_sum}/#{all_sum}"
