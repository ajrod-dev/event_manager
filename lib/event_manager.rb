require 'csv'

p 'Event Manager Initialized!'

def clean_zipcode(zip_code)
  if zip_code.nil?
    zip_code = "00000"
  elsif zip_code.length < 5
    zip_code = zip_code.rjust(5, "0")
  elsif zip_code.length > 5
    zip_code = row[:zipcode].slice(0..5)
  end
  zip_code
end


if File.exist?('../event_attendees.csv')
  contents = CSV.open(
    '../event_attendees.csv', 
    headers: true, 
    header_converters: :symbol
    ) 
  contents.each do |row|
    name = row[:first_name]
    zip_code = clean_zipcode(row[:zipcode])
    
    
    p "#{name} lives in #{zip_code}"
  end
end




