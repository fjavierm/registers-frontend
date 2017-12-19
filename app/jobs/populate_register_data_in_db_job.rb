class PopulateRegisterDataInDbJob < ApplicationJob
  queue_as :default

 def initialize
  @registers_client ||= RegistersClient::RegisterClientManager.new(cache_duration: 600)
 end
 
  def populate_register(register)
    register_data = @registers_client.get_register(register.name.parameterize, register.register_phase)

    populate_user_data(register, register_data)
    populate_system_data(register, register_data)

    register.populated = true
    register.fields = register_data.get_field_definitions.map { |field| field.item.value['field'] }.join(',')
    register.save
  end

  def populate_user_data(register, register_data)
    entries = []
    records = []
    count = 0

    register_data.get_records_with_history.each do |record|
      record[:records].each_with_index do |value, idx|
        count += 1
        new_entry = Entry.new(spina_register: register, timestamp: value.entry.timestamp, hash_value: value.entry.hash, entry_type: 'user', key: record[:key], data: value.item.value)
        entries.push(new_entry)

        if idx == record[:records].length - 1 # The last entry is the record
          records.push(Record.new(spina_register: register, timestamp: value.entry.timestamp, hash_value: value.entry.hash, entry_type: 'user', key: record[:key], data: value.item.value))
        end
      end

      next unless (count % 1000).zero?

      bulk_save(entries, records)

      entries = []
      records = []
    end

    # Remaining objects less than 1000
    bulk_save(entries, records)
  end

  def populate_system_data(register, register_data)
    entries = []
    records = []

    register_data.get_metadata_records.each do |record|
      new_entry = Entry.new(spina_register: register, data: record.item.value, timestamp: record.entry.timestamp, hash_value: record.entry.hash, entry_type: 'system', key: record.entry.key)
      entries.push(new_entry)
      records.push(Record.new(spina_register: register, data: record.item.value, timestamp: record.entry.timestamp, hash_value: record.entry.hash, entry_type: 'system', key: record.entry.key))
    end

    bulk_save(entries, records)
  end

  def perform(*args)
    puts('in job')
    puts(Spina::Register.all.to_yaml)
    Spina::Register.all.each do |register|
      puts('IN HERE '+ register.to_yaml)
      populate_register(register)
    end
  end
end
