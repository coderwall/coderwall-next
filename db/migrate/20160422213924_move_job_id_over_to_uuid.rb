class MoveJobIdOverToUuid < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'

    add_column :jobs, :uuid, :uuid, default: "uuid_generate_v4()", null: false

    change_table :jobs do |t|
      t.remove :id
      t.rename :uuid, :id
    end

    execute "ALTER TABLE jobs ADD PRIMARY KEY (id);"  
  end
end
