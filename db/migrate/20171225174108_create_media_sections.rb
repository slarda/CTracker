class CreateMediaSections < ActiveRecord::Migration
  def change
    create_table :media_sections do |t|
      t.references :user
	  t.string :title
	  t.string :image_url
	  t.string :external_link
	  t.string :description
    end
  end
end
