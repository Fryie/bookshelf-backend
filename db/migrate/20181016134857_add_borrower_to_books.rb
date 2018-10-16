class AddBorrowerToBooks < ActiveRecord::Migration[5.2]
  def change
    add_column :books, :borrower, :string
  end
end
