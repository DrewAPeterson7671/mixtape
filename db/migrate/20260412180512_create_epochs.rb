class CreateEpochs < ActiveRecord::Migration[7.2]
  def change
    create_table :epochs do |t|
      t.string :name, null: false
      t.integer :sequence
      t.text :definition
      t.integer :year_start
      t.integer :year_end
      t.integer :replay
      t.integer :weight
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :epochs, %i[name user_id], unique: true
  end
end
