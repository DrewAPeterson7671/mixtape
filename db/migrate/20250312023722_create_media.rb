class CreateMedia < ActiveRecord::Migration[7.2]
  def change
    create_table :media do |t|
      t.string :name
      t.references :track
      t.references :album

      t.timestamps
    end
  end
end
