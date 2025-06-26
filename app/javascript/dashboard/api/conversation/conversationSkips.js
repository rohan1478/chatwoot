/* global axios */
import ApiClient from '../ApiClient';

class ConversationSkipsAPI extends ApiClient {
  constructor() {
    super('conversations', { accountScoped: true });
  }

  create(conversationId, reason) {
    return axios.post(`${this.url}/${conversationId}/conversation_skips`, {
      conversation_skip: {
        reason,
      },
    });
  }

  get(conversationId) {
    return axios.get(`${this.url}/${conversationId}/conversation_skips`);
  }
}

export default new ConversationSkipsAPI(); 