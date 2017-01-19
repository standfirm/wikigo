class AddColumnToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :provider, :string, default: '', null: false
    add_column :users, :uid, :string, default: '', null: false
  end
end
