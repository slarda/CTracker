class CreateAwards < ActiveRecord::Migration
  def change
    create_table :awards do |t|
	  t.references :user
	  t.references :team
	  t.string :year
	  t.string :award
    end
  end
end
