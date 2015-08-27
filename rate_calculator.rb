require "json"
require "date"

class ArgumentHandler
	attr_reader :start_date, :end_date

	def initialize
		@start_date = DateTime.parse(ARGV[0])
		@end_date = DateTime.parse(ARGV[1])
	end
end

class DayExtractor
	attr_reader :day_map

	def initialize
		@day_map = {"1" => "mon",
								"2" => "tues",
								"3" => "wed",
								"4" => "thurs",
								"5" => "fri",
								"6" => "sat",
								"7" => "sun"}
	end

	def get_day(datetime_object)
		self.day_map[datetime_object.cwday.to_s]
	end
end

class RatesParser
	attr_reader :raw_rates_array
	attr_accessor :daily_rates

	def initialize(incoming_json)
		@raw_rates_array = JSON.parse(incoming_json)["rates"]
		@daily_rates = {"mon" => {}, 
						 "tues" => {}, 
						 "wed" => {}, 
						 "thurs" => {}, 
						 "fri" => {}, 
						 "sat" => {}, 
						 "sun" => {}}
		self.assign_time_ranges_to_days
	end

	def assign_time_ranges_to_days
		raw_rates_array.each do |rate|
			rate["days"].split(",").each do |day|
				daily_rates[day][rate["times"]] = rate["price"]
			end
		end
	end
end

class TimeChecker
	attr_reader :subrange_low, :subrange_high, :superrange

	def initialize(args)
		@subrange_low = self.datetime_object_to_four_digit_time(args["subrange_low"])
		@subrange_high = self.datetime_object_to_four_digit_time(args["subrange_high"])
		@superrange = args["superrange"]
	end

	def datetime_object_to_four_digit_time(datetime_object)
		time_with_colons = datetime_object.to_time.to_s.split(" ")[1]
		four_digit_time = time_with_colons.split(":")[0..1].join.to_i
	end

	def is_subrange_in_superrange?
		time_range = superrange.split("-").map{|t|t.to_i}
		time_range[0] <= (self.subrange_low + 500)%2400 && time_range[1] >= (self.subrange_high + 500)%2400
	end
end

class Director
	attr_accessor :argument_handler, :day_extractor, :rates_parser, :time_range

	def initialize
		@argument_handler = ArgumentHandler.new
		@day_extractor = DayExtractor.new
		@rates_parser = RatesParser.new(File.read('rates.json'))
	end

	def direct
		start_day = day_extractor.get_day(argument_handler.start_date)
		end_day = day_extractor.get_day(argument_handler.end_date)
		return "invalid range" if argument_handler.start_date.to_time.to_i >= argument_handler.end_date.to_time.to_i
		return "unavailable" if start_day != end_day
		this_day_rates = rates_parser.daily_rates[start_day]
		this_day_rates.each do |range, price|
			this_args = {"subrange_low" => argument_handler.start_date,
									 "subrange_high" => argument_handler.end_date,
									 "superrange" => range}
			time_checker = TimeChecker.new(this_args)
			if time_checker.is_subrange_in_superrange?
				return price
			end
		end
		return "unavailable"
	end
end

director = Director.new
p director.direct

# p RatesParser.new(File.read("rates.json")).daily_rates