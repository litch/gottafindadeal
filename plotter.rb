require 'json'
require 'google_visualr'
require 'date'

vaughns = []
hollys = []
gables_park_tower_b2 = []
Dir.glob("data/amli*json").each do |filename|
  map = JSON.parse(File.read filename)
  vaughns.concat map.first[1].select{|o| o.has_value? "Vaughn"}
  hollys.concat map.first[1].select{|o| o.has_value? "Holly"}
end

Dir.glob("data/gables*json").each do |filename|
  map = JSON.parse(File.read filename)
  next unless map['gables_park_tower']
  gables_park_tower_b2.concat map['gables_park_tower'].select{|o| o.has_value?("B2") && o.has_value?("GABLES PARK TOWER")}
end


data_table = GoogleVisualr::DataTable.new
data_table.new_column('date', 'Date' )
data_table.new_column('number', 'Vaughn Rent')
data_table.new_column('number', 'Holly Rent')
data_table.new_column('number', 'Gables Park Tower B2 Rent')

vaughns.each do |vaughn|
  date = Date.parse(vaughn['retrieved'])
  rent = vaughn['starting_rent'].gsub(/\D/,'').to_i
  unit = vaughn['unit']
  data_table.add_row([date, {v: rent, f: "Vaughn - Unit: #{unit || '?'}, Rent: $#{rent}"}, nil, nil])
end

hollys.each do |holly|
  date = Date.parse(holly['retrieved'])
  rent = holly['starting_rent'].gsub(/\D/,'').to_i
  unit = holly['unit']
  data_table.add_row([date, nil,{v: rent, f: "Holly - Unit: #{unit || '?'}, Rent: $#{rent}"}, nil])
end

gables_park_tower_b2.each do |b2|
  date = Date.parse(b2['retrieved'])
  rent = b2['rent'].gsub(/\D/,'').to_i
  unit = b2['unit']
  data_table.add_row([date, nil, nil, {v: rent, f: "Gables Park Tower B2 - Unit: #{unit || '?'}, Rent: $#{rent}"}])
end

opts   = { :width => 800, :height => 600, :title => 'AMLI Unit Prices',
             :hAxis => { :title => 'Date'},
             :vAxis => { :title => 'Price'},
             :legend => 'none' }
chart = GoogleVisualr::Interactive::ScatterChart.new(data_table, opts)

File.open('amli_plot.html', 'w') { |file|
  file.puts("<script src='https://www.google.com/jsapi'></script>")
  file.puts("<div id='chart'></div>")
  file.puts(chart.to_js('chart'))
}


