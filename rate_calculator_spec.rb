ARGV = ["2015-07-04T07:00:00Z", "2015-07-04T20:00:00Z"]

require 'rspec'
require_relative 'rate_calculator'

argument_handler = ArgumentHandler.new
day_extractor = DayExtractor.new
incoming_json = '{
  "rates": [
    {
      "days": "mon,tues,wed,thurs,fri",
      "times": "0600-1800",
      "price": 1500
    },
    {
      "days": "sat,sun",
      "times": "0600-2000",
      "price": 2000
    }
  ]
}'
expected_daily_rates = {"mon"=>{"0600-1800"=>1500},
												"tues"=>{"0600-1800"=>1500},
												"wed"=>{"0600-1800"=>1500},
												"thurs"=>{"0600-1800"=>1500},
												"fri"=>{"0600-1800"=>1500},
												"sat"=>{"0600-2000"=>2000},
												"sun"=>{"0600-2000"=>2000}}

rates_parser = RatesParser.new(incoming_json)

describe ArgumentHandler do
	it "grabs the arguments correctly" do
		expect(argument_handler.start_date.class).to eq(DateTime)
		expect(argument_handler.end_date.class).to eq(DateTime)
		expect(argument_handler.start_date.to_s).to eq("2015-07-04T07:00:00+00:00")
		expect(argument_handler.end_date.to_s).to eq("2015-07-04T20:00:00+00:00")
	end
end

describe DayExtractor do
	it "determines the correct day" do
		expect(day_extractor.get_day(argument_handler.start_date)).to eq("sat")
		expect(day_extractor.get_day(argument_handler.end_date)).to eq("sat")
	end
end

describe RatesParser do
	it "assigns rates to days correctly" do
		expect(rates_parser.daily_rates).to eq(expected_daily_rates)
	end
end

describe TimeChecker do
	two = DateTime.parse("2015-07-04T02:00:00Z")
	four = DateTime.parse("2015-07-04T04:00:00Z")
	six = DateTime.parse("2015-07-04T06:00:00Z")
	eight = DateTime.parse("2015-07-04T08:00:00Z")

	it "determines that 4 - 6 is within 2 - 8" do
		time_checker = TimeChecker.new({"subrange_low" => four, "subrange_high" => six, "superrange" => "0200-0800"})
		expect(time_checker.is_subrange_in_superrange?).to eq(true)
	end

	it "determines that 2 - 8 is not within 4 - 6" do
		time_checker = TimeChecker.new({"subrange_low" => two, "subrange_high" => eight, "superrange" => "0400-0600"})
		expect(time_checker.is_subrange_in_superrange?).to eq(false)
	end

	it "determines that 4 - 6 is within 4 - 6" do
		time_checker = TimeChecker.new({"subrange_low" => four, "subrange_high" => six, "superrange" => "0400-0600"})
		expect(time_checker.is_subrange_in_superrange?).to eq(true)
	end

	it "determines that 4 - 8 is not within 4 - 6" do
		time_checker = TimeChecker.new({"subrange_low" => four, "subrange_high" => eight, "superrange" => "0400-0600"})
		expect(time_checker.is_subrange_in_superrange?).to eq(false)
	end
end

describe Director do
	it "returns 2000 for Friday 10:00 - 12:00" do
		ARGV = ["2015-07-10T10:00:00Z", "2015-07-10T12:00:00Z"]
		director = Director.new
		expect(director.direct).to eq(2000)
	end

	it "returns unavailable for Friday 03:00 - 12:00" do
		ARGV = ["2015-07-10T03:00:00Z", "2015-07-10T12:00:00Z"]
		director = Director.new
		expect(director.direct).to eq("unavailable")		
	end

	it "returns invalid range for Friday 03:00 - 12:00" do
		ARGV = ["2015-07-10T12:00:00Z", "2015-07-10T03:00:00Z"]
		director = Director.new
		expect(director.direct).to eq("invalid range")		
	end

end