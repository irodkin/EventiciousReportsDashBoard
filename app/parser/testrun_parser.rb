require 'optparse'
require 'nokogiri'

options = {}

optparse = OptionParser.new do |opts|
  opts.on('--platform', '--platform android') do |f|
    options[:platform] = f
  end
  opts.on('--server', '--server production') do |f|
    options[:server] = f
  end
  opts.on('--appid', '--appid 4193') do |f|
    options[:appid] = f
  end
  opts.on('--suite', '--suite Networking') do |f|
    options[:suite] = f
  end
  opts.on('--tests', '--tests all') do |f|
    options[:tests] = f
  end
  opts.on('--device', '--device nexus 4s') do |f|
    options[:device] = f
  end
  opts.on('--branch', '--branch default') do |f|
    options[:branch] = f
  end
  opts.on('--link', '--link http://ya.ru') do |f|
    options[:link] = f
  end
  opts.on('--buildurl', '--buildurl http://ya.ru') do |f|
    options[:buildurl] = f
  end
  opts.on('--build', '--build 387') do |f|
    options[:build] = f
  end
  opts.on('--job', '--job TestDefault') do |f|
    options[:job] = f
  end
  opts.on('--user', '--user Vasya Pupkin') do |f|
    options[:user] = f
  end
end

optparse.parse!

docs = Dir['/Users/user/Jenkins/workspace/allure-results/*-testsuite.xml']
#docs = Dir['/Users/migrate/EventiciousReportsDashBoard/app/controllers/*-testsuite.xml']

failed = 0
all = 0
failed_scenarios = []
pending_scenarios = []
failed_tests = []
pending_tests = []

docs.each do |d|
  doc = File.open(d)
  xml = Nokogiri::XML(doc)
  f_names = xml.xpath("//test-case[@status='failed']/name")
  f_names.each { |n| failed_scenarios.push n.text}
  p_names = xml.xpath("//test-case[@status='pending']/name")
  p_names.each { |n| pending_scenarios.push n.text}
  failed+=names.size
  all+= xml.xpath("//test-case").size
end

failed_scenarios.uniq.each do |s|
  scenario = Test.where(title: s).first
  failed_tests.push scenario.tags unless scenario.nil?
end

pending_scenarios.uniq.each do |s|
  scenario = Test.where(title: s).first
  pending_tests.push scenario.tags unless scenario.nil?
end

r = Report.new(:date=>Time.now+14400,
               :platform=>options[:platform],
               :server=>options[:server],
               :device=>options[:device],
               :suite=>options[:suite],
               :tests=>options[:tests],
               :link=>options[:link],
               :buildurl=>options[:buildurl],
               :build=>options[:build],
               :job=>options[:job],
               :branch=>options[:branch],
               :user=>options[:user],
               :appid=>options[:appid],
               :all => all,
               :failed => failed,
               :failed_tests => failed_tests.join("&&"),
               :pending_tests => pending_tests.join("&&"))
r.save
