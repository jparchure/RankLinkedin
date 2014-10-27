class CreateAuthorizes < ActiveRecord::Migration
  def change
    create_table :authorizes do |t|

      t.timestamps
    end
  end
end
