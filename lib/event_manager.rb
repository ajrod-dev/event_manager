require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require './api_key.rb'
require 'time'

busiest_hours = {}
busiest_days = {}


def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = $API_KEY

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def clean_phone_number(phone_number)
  phone_number = phone_number.to_s.gsub(/\D/, '')
  if phone_number.length == 11 and phone_number[0] == '1'
    phone_number = phone_number[1..10]
  elsif phone_number.length == 10
    phone_number
  else
    phone_number = 'XXX-XXX-XXXX'
  end 
  phone_number
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_time(day, time)
  day = day.split("/")
  time = time.split(":")
  t = Time.new(
    ("20#{day[2]}".to_i),
    day[0].to_i, 
    day[1].to_i, 
    time[0], 
    time[1]
    )
  t
end

def hour_targeting(my_hash, time_obj)

  if my_hash.has_key?(time_obj.hour)
    my_hash[time_obj.hour] += 1
  else
    my_hash[time_obj.hour] = 1
  end
  my_hash
end

def get_busiest_hours(busiest_hours)
  result = ""
  max = busiest_hours.values.max
  count = busiest_hours.select { |k, v| v == max}
  if count.length > 1
    result = "The busiest hours where most people registered were at the hours of #{count.keys}"
  else 
    result = "The busiest hour most people registered at was at #{count.keys}"
  end
    result
end

def day_targeting(my_hash, time_obj)
  if my_hash.has_key?(time_obj.strftime("%A"))
    my_hash[time_obj.strftime("%A")] += 1
  else
    my_hash[time_obj.strftime("%A")] = 1
  end
  my_hash
end

def get_busiest_days(busiest_days)
  max_key = busiest_days.max_by { |k, v| v}.first
  max_key
end


puts 'EventManager initialized.'

contents = CSV.open(
  '../event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('../form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  phone_number = clean_phone_number(row[:homephone])
  time = clean_time(row[1].split(" ")[0], row[1].split(" ")[1])
  
  
  hours_most_registered = hour_targeting(busiest_hours, time)
  days_most_registered = day_targeting(busiest_days,time)
  # get_busiest_days(days_most_registered)
  # p get_busiest_days
  p get_busiest_hours(hours_most_registered)
  

  # p "Busiest day of the week is: #{busiest_day} "

  



  



  

  # form_letter = erb_template.result(binding)

  # save_thank_you_letter(id,form_letter)
end


