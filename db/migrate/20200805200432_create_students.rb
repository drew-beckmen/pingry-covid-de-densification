# This is really a single household
class CreateStudents < ActiveRecord::Migration[5.2]
  def change
    create_table :students do |t|
      t.string :household_name 
      t.integer :household
      t.integer :place_in_alphabet
      t.boolean :cohorted 
    end 
  end
end
