class CreatePhases < ActiveRecord::Migration[7.2]
  def change
    create_table :phases do |t|
      t.string :name
      t.references :artist

      t.timestamps
    end
  end
end
