require 'nokogiri'
require 'awesome_print'
require 'open-uri'
require 'date'
require 'json'

class String
  def underscore
    self.gsub(/\W+/,'_').
    tr("-", "_").
    downcase
  end
end


class GablesScraper
  attr_accessor :property_id, :property_name

  def initialize(property_id, property_name)
    self.property_id = property_id
    self.property_name = property_name
  end

  def scrape
    info = []
    page = 1
    prev_first_plan= nil
    while doc = Nokogiri::HTML(open(url_for(property_id, page)))
      begin
        first_plan = doc.css('.floorplan').css('.thumb').first.children.css('a').first.attributes['href'].value
      rescue
        break
      end
      break if prev_first_plan == first_plan
      info.concat(parse_page(doc))
      prev_first_plan = first_plan
      page += 1
    end
    info
  end

  def url_for(property_id, page)
    "http://gables.com/find/floorplans_serp?utf8=%E2%9C%93&floorplans=any&query=Austin&property_id=#{property_id}&page=#{page}"
  end

  def parse_page(doc)
    units = []
    doc.css('.floorplan').each do |floorplan|
      floorplan.css('caption').first.content.scan(/^(\w+)\s(.+)\s\/\s(.+)$/)
      floor_plan_name = $1
      bed_bath_count = "#{$2}, #{$3}"
      unit_summary = {floor_plan_name: floor_plan_name, property_name: property_name, retrieved: Time.now, bed_bath_count: bed_bath_count}
      floorplan.css('tbody tr').each do |unit|
        cells = unit.content.split(/\n/)
        unit_specs = {building: cells[1], floor: cells[2], unit: cells[3], square_footage: cells[5], rent: cells[7], available: cells[8]}
        units << unit_summary.merge(unit_specs)
      end
    end
    units
  end
end

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
