class AddUserIdToLookupTables < ActiveRecord::Migration[7.2]
  def change
    tables = %i[genres tags editions media phases priorities release_types]

    tables.each do |table|
      add_reference table, :user, null: true, foreign_key: true

      # System records: name must be unique when user_id IS NULL
      add_index table, :name,
                unique: true,
                where: "user_id IS NULL",
                name: "index_#{table}_on_name_system"

      # User records: name must be unique per user
      add_index table, %i[name user_id],
                unique: true,
                where: "user_id IS NOT NULL",
                name: "index_#{table}_on_name_user"
    end
  end
end
