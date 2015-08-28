Run using Ruby v1.9.3 or later. Clone this repo, then cd into this directory and run "bundle install". To be extra safe, run "gem install rspec" and "gem install json". 

rates.json is the sample rate data provided in the challenge. To use a different set of rates, replace this file with one of your choice, but don't change the name to anything other than rates.json

To run the rate calculator, simply run "ruby rate_calculator.rb [start datetime] [end datetime]"

To run the tests, cd into the directory and run "gem install rspec", then run the test file with "rspec rate_calculator_spec.rb" 
