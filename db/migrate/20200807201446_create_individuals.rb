class CreateIndividuals < ActiveRecord::Migration[5.2]
  def change
    create_table :individuals do |t|
      t.integer :personal_id 
      t.integer :household_id
      t.integer :grade_level 
      t.string :surname
    end 
  end
end
