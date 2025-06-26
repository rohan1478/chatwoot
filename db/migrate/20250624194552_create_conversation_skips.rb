class CreateConversationSkips < ActiveRecord::Migration[7.1]
    def change
      create_table :conversation_skips do |t|
        t.references :conversation, null: false, foreign_key: true
        t.references :user, null: false, foreign_key: true
        t.text :reason, null: false
        t.timestamps
      end
      add_index :conversation_skips, [:conversation_id, :created_at]
    end
  end
  