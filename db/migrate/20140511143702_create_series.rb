class CreateSeries < ActiveRecord::Migration
  def change
    create_table :series do |t|
      t.string :name
      t.integer :publisher_id
      t.string :year

      t.timestamps
    end
  end
end
