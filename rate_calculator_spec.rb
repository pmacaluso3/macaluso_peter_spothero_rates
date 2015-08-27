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
expected_daily_rates = {"mon"=>[{"0600-1800"=>1500}],
												"tues"=>[{"0600-1800"=>1500}],
												"wed"=>[{"0600-1800"=>1500}],
												"thurs"=>[{"0600-1800"=>1500}],
												"fri"=>[{"0600-1800"=>1500}],
												"sat"=>[{"0600-2000"=>2000}],
												"sun"=>[{"0600-2000"=>2000}]}

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