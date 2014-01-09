require 'selenium-webdriver'
require 'awesome_print'
require 'date'
require 'json'
require_relative 'amli_scraper'
require_relative 'gables_scraper'

class String
  def underscore
    self.gsub(/\W+/,'_').
    tr("-", "_").
    downcase
  end
end

results = {}

amlis = {
  amli_on_2nd: "http://www.amli.com/apartments/austin/downtown/austin/2nd-street/floorplans",
  amli_5350: "http://www.amli.com/apartments/austin/central-austin/austin/5350/floorplans",
  amli_downtown: 'http://www.amli.com/apartments/austin/2nd-street-district/austin/downtown/floorplans',
  amli_south_shore: 'http://www.amli.com/apartments/austin/central-east-austin/austin/south-shore/floorplans',
  amli_lantana_hills: 'http://www.amli.com/apartments/austin/southwest-austin/austin/lantana-hills/floorplans',
  amli_300: 'http://www.amli.com/apartments/austin/downtown/austin/300/floorplans',
  amli_eastside: 'http://www.amli.com/apartments/austin/downtown/austin/eastside/floorplans'
}

amlis.each do |property_name, url|
  results[property_name] = AmliScraper.new(url, property_name).scrape
end

File.open("data/amli_#{Date.today.iso8601}.json", 'w') { |file| JSON.dump(results, file) }

results = {}

gables = {
  gables_fifth_st_commons: 931,
  gables_central_park: 'http://gables.com/find/floorplans_serp?utf8=%E2%9C%93&floorplans=any&query=Austin&property_id=51&page=1',
  gables_grandview: 'http://gables.com/find/floorplans_serp?utf8=%E2%9C%93&floorplans=any&query=Austin&property_id=121&page=1',
  gables_at_the_terrace: 'http://gables.com/find/floorplans_serp?utf8=%E2%9C%93&floorplans=any&query=Austin&property_id=281&page=1',
  gables_west_ave: 'http://gables.com/find/floorplans_serp?utf8=%E2%9C%93&floorplans=any&query=Austin&property_id=361&page=1',
  gables_pressler: 'http://gables.com/find/floorplans_serp?utf8=%E2%9C%93&floorplans=any&query=Austin&property_id=1071&page=1',
  gables_park_plaza: 'http://gables.com/find/floorplans_serp?utf8=%E2%9C%93&floorplans=any&query=Austin&property_id=1191&page=1',
  gables_park_tower: 'http://gables.com/find/floorplans_serp?utf8=%E2%9C%93&floorplans=any&query=Austin&property_id=2161&page=1'
}

gables.each do |property_name, url|
  results[property_name] = GablesScraper.new(url, property_name).scrape
end

File.open("data/gables_#{Date.today.iso8601}.json", 'w') { |file| JSON.dump(results, file) }
