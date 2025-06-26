class Api::V1::Accounts::Conversations::ConversationSkipsController < Api::V1::Accounts::Conversations::BaseController
    before_action :set_conversation
  
    def index
      @conversation_skips = @conversation.conversation_skips.order(created_at: :desc)
      render json: @conversation_skips
    end
  
    def create
      @conversation_skip = @conversation.conversation_skips.new(conversation_skip_params)
      @conversation_skip.user = current_user
      if @conversation_skip.save
        render json: @conversation_skip, status: :created
      else
        render json: { errors: @conversation_skip.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private
  
    def set_conversation
      @conversation = Conversation.find(params[:conversation_id])
    end
  
    def conversation_skip_params
      params.require(:conversation_skip).permit(:reason)
    end
  end
  