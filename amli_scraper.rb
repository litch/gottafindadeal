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