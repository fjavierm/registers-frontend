class PopulateRegisterDataInDbJob < ApplicationJob
  queue_as :default

  def initialize
    @registers_client ||= RegistersClient::RegisterClientManager.new(cache_duration: 60)
  end

  def bulk_remove_existing_records(register, entry_type, record_keys)
    unless record_keys.empty?
      Record.where(spina_register_id: register.id, entry_type: entry_type, key: record_keys).delete_all
    end
  end

  def bulk_save(entries, records)
    Entry.import(entries)
    Record.import(records)
  end

  def populate_register(register)
    register_data = @registers_client.get_register(register.name.parameterize, register.register_phase)
    register_data.refresh_data

    populate_data(register, register_data, 'user')
    populate_data(register, register_data, 'system')

    register.fields = register_data.get_field_definitions.map { |field| field.item.value['field'] }.join(',')
    register.save
  end

  def populate_data(register, register_data, entry_type)
    entries = []
    records = []
    count = 0
    latest_entry = Entry.where(spina_register_id: register.id, entry_type: entry_type).order(:entry_number).reverse_order.limit(1).first
    latest_entry_number = latest_entry.nil? ? 0 : latest_entry.entry_number

    (entry_type == 'user' ? register_data.get_records_with_history(latest_entry_number) : register_data.get_metadata_records_with_history(latest_entry_number)).each do |record|
      previous_entry_number = nil


      record[:records].each_with_index do |value, idx|
        count += 1
        new_entry = Entry.new(spina_register: register, data: value.item.value, timestamp: value.entry.timestamp, hash_value: value.item.hash, entry_number: value.entry.entry_number, previous_entry_number: previous_entry_number, entry_type: entry_type, key: value.entry.key)
        entries.push(new_entry)
        if idx == record[:records].length - 1 # The last entry is the record
          records.push(Record.new(spina_register: register, data: value.item.value, timestamp: value.entry.timestamp, hash_value: value.item.hash, entry_number: value.entry.entry_number, entry_type: entry_type, key: value.entry.key))
        end

        previous_entry_number = value.entry.entry_number
      end

      next unless (count % 1000).zero?

      bulk_remove_existing_records(register, entry_type, records.map{ |record| record.key })
      bulk_save(entries, records)

      entries = []
      records = []
    end

    # Remaining objects less than 1000
    bulk_remove_existing_records(register, entry_type, records.map {|record| record.key})
    bulk_save(entries, records)
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

  def perform(*)
    Spina::Register.all.each do |register|
      populate_register(register)
    end
  end
end
