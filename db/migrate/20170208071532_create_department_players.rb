class CreateDepartmentPlayers < ActiveRecord::Migration
  def change
    create_table :department_players do |t|
      t.references :department, index: true, foreign_key: true
      t.string :username, index: true, unique: true

      t.timestamps null: false
    end
  end
end