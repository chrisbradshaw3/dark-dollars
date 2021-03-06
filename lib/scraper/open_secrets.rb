# require 'HTTParty'
# require 'Nokogiri'
# require 'pry'

module Scraper
  class OpenSecrets
    attr_reader :parse_page
    attr_reader :year

    def initialize(year)
      page = HTTParty.get("https://www.opensecrets.org/outsidespending/summ.php?cycle=#{year}&disp=I&type=A")
      @year = year
      @parse_page ||= Nokogiri::HTML(page) # memorized the @parse_page so it only gets assigned once (the very first time)
    end

# def as_json(options={})
#   super(:only => [:first_name,:last_name,:city,:state],
#         :include => {
#           :employers => {:only => [:title]},
#           :roles => {:only => [:name]}
#         }
#   )
# end

 def as_json(options={})
  name = get_industry
  total = get_total
  org = from_organizations
  indiv = from_individuals
  lib = to_liberals
  cons = to_conservatives
  result = []

  (0...total.size).inject([]) do |results, index|
    result.push({
      :year => self.year,
      :industry => name[index],
      :total => total[index],
      :from_organizations => org[index],
      :from_individuals => indiv[index],
      :to_liberals => lib[index],
      :to_conservatives => cons[index]
    })
  end
  # Rails.logger.debug result
  result
 end

    private
    def get_industry
      ind = item_container.css("tr").map{|name| name.children[1].text if name.text}.compact
      ind = ind[1..ind.size]
      return ind
    end

    def get_total
      # ind = item_container.css(".tablesorter tbody tr").map{|total| total.css(".number")[0].text if total.text}.compact
      ind = item_container.css("tbody tr").map{|total| total.css(".number")[0].text if total.text}.compact
      ind = ind[1..ind.size]
      return ind
    end

    def from_organizations
      ind = item_container.css("tbody tr").map{|total| total.css(".number")[1].text if total.text}.compact
      ind = ind[1..ind.size]
      return ind
    end

    def from_individuals
      ind = item_container.css("tbody tr").map{|total| total.css(".number")[2].text if total.text}.compact
      ind = ind[1..ind.size]
      return ind
    end

    def to_liberals
      ind = item_container.css("tbody tr").map{|total| total.css(".number")[3].text if total.text}.compact
      ind = ind[1..ind.size]
      return ind
    end

    def to_conservatives
      ind = item_container.css("tbody tr").map{|total| total.css(".number")[4].text if total.text}.compact
      ind = ind[1..ind.size]
      return ind
    end

    def item_container
      parse_page.css("#summary_A")
    end

  end
end

 # scraper = Scraper::OpenSecrets.new

 # name = scraper.get_industry
 # total = scraper.get_total
 # org = scraper.from_organizations
 # ind = scraper.from_individuals
  # lib = scraper.to_liberals
  # cons = scraper.to_conservatives

  # (0...total.size).each do |index|
  # puts "- - -  index: #{index + 1} - - - "
  # puts "Industry: #{name[index]}"
  # puts "total: #{total[index]}"
  # puts "From Organizations: #{org[index]}"
  # puts "From Individuals: #{ind[index]}"
  # puts "To Liberals: #{lib[index]}"
  # puts "To Conservatives: #{cons[index]}"
  # puts " "
  # end




# (0...image_links.size).each do |index| #three dots don't include last digit. Behave like 0..image_links -1
#   puts "- - -  index: #{index + 1} - - - "
#   puts "Name: #{names[index]} | price: #{prices[index]} | description: #{descriptions[index]} | image_link: #{image_links[index]}"
# end
