require 'pry'
require 'set'
require 'uri'
require 'json'
require 'csv'

CSV.open('types.csv', 'w') do |csv|
  Dir['results/*'].each do |f|
    next if ['results/mk','results/none','results/unknown','results/Search'].include? f
    File.foreach(f).each do |line|
      line = line.chomp
      data = JSON.parse(line)
      csv << [f.split('/')[1], data.keys.first]
    end
  end
end

