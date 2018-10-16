class AddLocationFieldsToBooks < ActiveRecord::Migration[5.2]
  def change
    add_column :books, :physical_location, :string
    add_column :books, :ebook_url, :string
  end
end
