require 'pry'
require 'set'

urls = Set.new()

def dequery(url)
  url.split('?').first.split('#').first
end

File.foreach(ARGV[0]).each do |line|
  urls.add(dequery(line)) if line.start_with?('http')
end

puts urls.sort
