require 'rails_helper'

RSpec.configure do |config|

config.before(:suite) do
  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.clean_with(:truncation)
end

config.around(:each) do |example|
  DatabaseCleaner.cleaning do
    example.run
  end
end
end

RSpec.describe PopulateRegisterDataInDbJob, type: :job do
  # country_data = File.read('./spec/support/country.rsf')
  # stub_request(:get, 'https://country.beta.openregister.org/download-rsf')
  # .with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip, deflate', 'Host' => 'country.beta.openregister.org' })
  # .to_return(status: 200, body: country_data, headers: {})



  ObjectsFactory.new.create_register('country', 'beta', 'Ministry of Justice')

  puts('in here')
  puts(Spina::Register.count)
  DatabaseCleaner.start
  PopulateRegisterDataInDbJob.perform_now
  DatabaseCleaner.clean
end

