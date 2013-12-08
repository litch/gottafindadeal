ashton = {
  ashton: 'https://property.onesite.realpage.com/oll/Unit/Search/?siteId=2335204&model=%7B%22SearchSetup%22%3A%7B%22PriceRangeLow%22%3A400%2C%22PriceRangeHigh%22%3A20000%2C%22LeaseTerms%22%3A%5B3%2C4%2C5%2C6%2C7%2C8%2C9%2C10%2C11%2C12%5D%2C%22Beds%22%3A%5B1%2C2%2C3%5D%2C%22Baths%22%3A%5B%221.00%22%2C%221.50%22%2C%222.00%22%2C%222.50%22%2C%223.50%22%5D%2C%22MinMoveInDate%22%3A%22%2FDate(1376352000000)%2F%22%2C%22MaxMoveInDate%22%3A%22%2FDate(1386637200000)%2F%22%2C%22DesiredMoveInDate%22%3A%22%2FDate(1376352000000)%2F%22%7D%7D&_=1376442527551'
}

#   https://www.udr.com/floorplan.aspx?pid=35351'
# }

# https://property.onesite.realpage.com/oll/Unit/SearchSetup?siteId=2335204
# https://property.onesite.realpage.com/oll/Unit/Search/?siteId=2335204&model=%7B%22SearchSetup%22%3A%7B%22PriceRangeLow%22%3A400%2C%22PriceRangeHigh%22%3A20000%2C%22LeaseTerms%22%3A%5B3%2C4%2C5%2C6%2C7%2C8%2C9%2C10%2C11%2C12%5D%2C%22Beds%22%3A%5B1%2C2%2C3%5D%2C%22Baths%22%3A%5B%221.00%22%2C%221.50%22%2C%222.00%22%2C%222.50%22%2C%223.50%22%5D%2C%22MinMoveInDate%22%3A%22%2FDate(1376352000000)%2F%22%2C%22MaxMoveInDate%22%3A%22%2FDate(1386637200000)%2F%22%2C%22DesiredMoveInDate%22%3A%22%2FDate(1376352000000)%2F%22%7D%7D&_=1376442527551

require 'httparty'
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
    HTTParty.get(url)
    {floor_plan_name: floor_plan_name, property_name: property_name, retrieved: Time.now, square_footage: square_footage, bed_bath_count: bed_bath_count}
    info
  end

end


ap UdrScraper.new(ashton[:ashton], :ashton).scrape