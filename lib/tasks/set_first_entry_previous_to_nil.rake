namespace :registers_frontend do
  desc 'set previous entry number to nil for first entry for key'
  task first_entry_previous_nullify: :environment do
    Spina::Register.find_each do |register|
      entries_by_key = Entry.where(spina_register_id: register.id).group_by(&:key)
      entries_by_key.each do |key, entries|
        first_entry_for_key = entries.sort_by(&:entry_number).first
        if first_entry_for_key.previous_entry_number != nil
          puts("setting entry #{first_entry_for_key.entry_number} for key #{key} previous entry number to nil")
          Entry.update(first_entry_for_key.id, previous_entry_number: nil)
        end
      end
    end
  end
end
