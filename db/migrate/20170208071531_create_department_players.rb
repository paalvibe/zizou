class CreateDepartmentPlayers < ActiveRecord::Migration
  def change
    create_table :department_players do |t|
      t.references :team, index: true, foreign_key: true
      t.string :username, index: true

      t.timestamps null: false
    end
  end
end