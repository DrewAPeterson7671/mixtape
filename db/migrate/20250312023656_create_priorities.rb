class CreatePriorities < ActiveRecord::Migration[7.2]
  def change
    create_table :priorities do |t|
      t.string :name

      t.timestamps
    end
  end
end
