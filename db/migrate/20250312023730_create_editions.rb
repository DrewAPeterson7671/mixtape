class CreateEditions < ActiveRecord::Migration[7.2]
  def change
    create_table :editions do |t|
      t.string :name

      t.timestamps
    end
  end
end
