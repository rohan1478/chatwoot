class Api::V1::Accounts::Conversations::ConversationSkipsController < Api::V1::Accounts::Conversations::BaseController
    before_action :set_conversation
  
    # GET /api/v1/accounts/:account_id/conversations/:conversation_id/conversation_skips
    def index
      @conversation_skips = @conversation.conversation_skips.includes(:user).order(created_at: :desc)
      skips_with_user = @conversation_skips.map do |skip|
        {
          id: skip.id,
          reason: skip.reason,
          created_at: skip.created_at,
          updated_at: skip.updated_at,
          user: {
            id: skip.user.id,
            name: skip.user.name,
            email: skip.user.email
          }
        }
      end
      render json: skips_with_user
    end
  
    # POST /api/v1/accounts/:account_id/conversations/:conversation_id/conversation_skips
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
  