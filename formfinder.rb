require 'pry'
require 'set'
require 'uri'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'typhoeus'

hydra = Typhoeus::Hydra.new

urls = File.readlines(ARGV[0]).map(&:chomp)

urls.each do |url|
  request = Typhoeus::Request.new(url, timeout: 15000)
  request.on_complete do |response|
    if response.success?
      doc = Nokogiri::HTML(response.body)
      forms = doc.xpath('//form')
      puts JSON.generate({ url => forms.map(&:to_s) }) unless forms.empty?
    end
  end
  hydra.queue(request)
end

hydra.run
