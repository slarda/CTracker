class CreateArticle < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :category
      t.text :url
      t.timestamps              null: false
    end
  end
end
