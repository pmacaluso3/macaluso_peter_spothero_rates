require "json"
require "date"


class DayExtractor
	attr_reader :start_date, :end_date, :start_day, :end_day

	def initialize
		@input = ARGV
		@start_date = DateTime.parse(@input[0])
		@end_date = DateTime.parse(@input[1])
		@day_map = {"1" => "mon",
								"2" => "tues",
								"3" => "wed",
								"4" => "thurs",
								"5" => "fri",
								"6" => "sat",
								"7" => "sun"}
		@start_day = @day_map[start_date.cwday.to_s]
		@end_day = @day_map[end_date.cwday.to_s]
	end
end

class RatesParser
	attr_reader :raw_rates_array
	attr_accessor :daily_rates

	def initialize(incoming_json)
		@raw_rates_array = JSON.parse(incoming_json)["rates"]
		@daily_rates = {"mon" => [], 
						 "tues" => [], 
						 "wed" => [], 
						 "thurs" => [], 
						 "fri" => [], 
						 "sat" => [], 
						 "sun" => []}
		self.assign_time_ranges_to_days
	end

	def assign_time_ranges_to_days
		raw_rates_array.each do |rate|
			rate["days"].split(",").each do |day|
				daily_rates[day] << {rate["times"] => rate["price"]}
			end
		end
	end
end
