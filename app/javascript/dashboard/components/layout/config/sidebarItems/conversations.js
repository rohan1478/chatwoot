import { frontendURL } from '../../../../helper/URLHelper';

const conversations = accountId => ({
  parentNav: 'conversations',
  routes: [
    'home',
    'inbox_dashboard',
    'inbox_conversation',
    'conversation_through_inbox',
    'notifications_dashboard',
    'label_conversations',
    'conversations_through_label',
    'team_conversations',
    'conversations_through_team',
    'conversation_mentions',
    'conversation_through_mentions',
    'conversation_participating',
    'conversation_through_participating',
    'folder_conversations',
    'conversations_through_folders',
    'conversation_unattended',
    'conversation_through_unattended',
    'conversation_playmode',
    'conversation_through_playmode',
    'conversation_skips',
  ],
  menuItems: [
    {
      icon: 'chat',
      label: 'ALL_CONVERSATIONS',
      key: 'conversations',
      toState: frontendURL(`accounts/${accountId}/dashboard`),
      toolTip: 'Conversation from all subscribed inboxes',
      toStateName: 'home',
    },
    {
      icon: 'mention',
      label: 'MENTIONED_CONVERSATIONS',
      key: 'conversation_mentions',
      toState: frontendURL(`accounts/${accountId}/mentions/conversations`),
      toStateName: 'conversation_mentions',
    },
    {
      icon: 'mail-unread',
      label: 'UNATTENDED_CONVERSATIONS',
      key: 'conversation_unattended',
      toState: frontendURL(`accounts/${accountId}/unattended/conversations`),
      toStateName: 'conversation_unattended',
    },
    {
      icon: 'play-circle',
      label: 'PLAYMODE_CONVERSATIONS',
      key: 'conversation_playmode',
      toState: frontendURL(`accounts/${accountId}/playmode/conversations`),
      toStateName: 'conversation_playmode',
    },
    {
      icon: 'skip-forward',
      label: 'CONVERSATION_SKIPS.MENU_ITEM',
      key: 'conversation_skips',
      toState: frontendURL(`accounts/${accountId}/dashboard/conversation/skips`),
      toStateName: 'conversation_skips',
    },
  ],
});

export default conversations;
