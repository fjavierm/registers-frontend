namespace :registers_frontend do
  desc "clean previous entries"
  task clean_previous_entry: :environment do
    Spina::Register.find_each do |register|
      entries = Entry.where(spina_register_id: register.id)
      equal_value_entries =  entries.select{|e| e.entry_number.equal? e.previous_entry_number}
      equal_value_entries.each do |entry|
        puts("setting previous entry for register: #{register.name} key: #{entry.key}, entry: #{entry.entry_number} to nil")
        Entry.update(entry.id, previous_entry_number: nil)
      end
    end
  end
end
