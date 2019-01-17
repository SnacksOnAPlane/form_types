require 'pry'
require 'set'
require 'uri'

host_urls = {}

def dequery(url)
  url.split('?').first.split('#').first
end

File.foreach(ARGV[0]).each do |line|
  begin
    line = line.chomp
    parsed = URI(line)
    (host_urls[parsed.host] ||= []) << line
  rescue => e
  end
end

host_urls.values.each { |urls| puts urls.sample }
