class ConversationSkip < ApplicationRecord
    belongs_to :conversation
    belongs_to :user
    
    validates :reason, presence: true, length: { maximum: 500 }
  end