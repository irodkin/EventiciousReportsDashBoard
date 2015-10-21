require 'optparse'

options = {}

optparse = OptionParser.new do |opts|
  opts.on('--platform', '--platform android') do |f|
    options[:platform] = f
  end
  opts.on('--server', '--server production') do |f|
    options[:server] = f
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
end

optparse.parse!

r = Report.new(:date=>Time.now+14400,
               :platform=>options[:platform],
               :server=>options[:server],
               :device=>options[:device],
               :suite=>options[:suite],
               :tests=>options[:tests],
               :link=>options[:link],
               :branch=>options[:branch])
r.save