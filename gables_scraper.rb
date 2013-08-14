gables = {
  gables: 'https://www.udr.com/floorplan.aspx?pid=35351'
}

require 'selenium-webdriver'
require 'awesome_print'

class String
  def underscore
    self.gsub(/\W+/,'_').
    tr("-", "_").
    downcase
  end
end


class UdrScraper
  attr_accessor :url, :property_name

  def initialize(url, property_name)
    self.url = url
    self.property_name = property_name
  end

  def scrape
    driver = Selenium::WebDriver.for :firefox
    driver.navigate.to url
    wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds
    wait.until {driver.find_element(id: 'page-title')}
    p "Looks like load is done!"
    info = []
    driver.find_elements(class: 'floorplan-description').each do |floorplan_cell|
      floor_plan_name = floorplan_cell.find(tag_name: 'h2').text.split('-')[0].strip
      bed_bath_count = floorplan_cell.find(tag_name: 'h2').text.split('-')[1].strip
      floorplan_cell.find_element(tag_name: 'tbody').find_elements(tag_name: 'tr').each do |unit|
        unit_summary = {floor_plan_name: floor_plan_name, property_name: property_name, retrieved: Time.now, square_footage: square_footage, bed_bath_count: bed_bath_count}
        unit_summary['text'] = unit.text
      end
    end
    driver.close
    info
  end

end


ap UdrScraper.new(ashton[:ashton], :ashton).scrape