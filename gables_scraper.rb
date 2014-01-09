require 'nokogiri'
require 'awesome_print'
require 'open-uri'
require 'date'
require 'json'

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
