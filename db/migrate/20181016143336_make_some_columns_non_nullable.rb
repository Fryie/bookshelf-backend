class MakeSomeColumnsNonNullable < ActiveRecord::Migration[5.2]
  def up
    Book.where(borrower: nil).update_all(borrower: "")
    change_column :books, :borrower, :string, null: false, default: ""
    Book.where(physical_location: nil).update_all(physical_location: "")
    change_column :books, :physical_location, :string, null: false, default: ""
    Book.where(ebook_url: nil).update_all(ebook_url: "")
    change_column :books, :ebook_url, :string, null: false, default: ""
  end

  def down
    change_column :books, :borrower, :string, null: true, default: nil
    change_column :books, :physical_location, :string, null: true, default: nil
    change_column :books, :ebook_url, :string, null: true, default: nil
  end
end
