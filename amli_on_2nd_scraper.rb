require 'selenium-webdriver'
require 'awesome_print'
require 'date'
require 'json'

class String
  def underscore
    self.gsub(/\W+/,'_').
    tr("-", "_").
    downcase
  end
end

class AmliScraper
  attr_accessor :url, :property_name

  def initialize(url, property_name)
    self.url = url
    self.property_name = property_name
  end

  def scrape
    driver = Selenium::WebDriver.for :firefox

    driver.navigate.to url
    fp_element_count = driver.find_elements(id: 'fpHolder').size
    fp_elements = driver.find_elements(id: 'fpHolder')

    info = []
    begin
      [*0..fp_element_count-1].each do |floor_plan_index|
        fp = driver.find_elements(id: 'fpHolder')[floor_plan_index]
        floor_plan_name = fp.text.strip.split(/\n/).first
        square_footage = fp.text.strip.split(/\n/)[4].split[0]
        bed_bath_count = fp.text.strip.split(/\n/)[3]
        fp.find_element(class: 'FpItemButton').click
        units = driver.find_element(class: 'tblSummary').find_elements(tag_name: 'tr')
        headers = units.slice!(0,1).first
        units.each_with_index do |unit, i|
          unit_summary = {floor_plan_name: floor_plan_name, property_name: property_name, retrieved: Time.now, square_footage: square_footage, bed_bath_count: bed_bath_count}
          unit.find_elements(tag_name: 'td').each_with_index do |cell, j|
            unit_summary[headers.find_elements(tag_name: 'th')[j].text.strip.underscore.to_sym] = cell.text
          end
          info << unit_summary
        end
      end
    rescue
      info << :error_in_scrape
    end
    driver.close
    info
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

File.open("amli_#{Date.today.iso8601}.json", 'w') { |file| JSON.dump(results, file) }