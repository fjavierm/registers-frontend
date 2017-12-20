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
  before(:each) do
    ObjectsFactory.new.create_register('country', 'beta', 'Ministry of Justice')
    country_data = File.read('./spec/support/country.rsf')
    stub_request(:get, "https://country.beta.openregister.org/download-rsf").
    with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'country.beta.openregister.org', 'User-Agent'=>'rest-client/2.0.2 (darwin15.6.0 x86_64) ruby/2.4.2p198'}).
    to_return(status: 200, body: country_data, headers: {})
  end

  describe 'populate register data job' do
    it 'populates data' do
      puts('in here')
      puts(Spina::Register.count)
      PopulateRegisterDataInDbJob.perform_now
    end
  end
end
