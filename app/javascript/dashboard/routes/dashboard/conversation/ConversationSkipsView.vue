<template>
    <div class="column content-box">
      <div class="header-wrapper">
        <h2 class="page-title">
          {{ $t('CONVERSATION_SKIPS.TITLE') }}
        </h2>
      </div>
      <div class="content-wrapper">
        <div v-if="loading" class="text-center">
          <spinner />
        </div>
        <div v-else-if="skips.length" class="table-container">
          <table class="woot-table">
            <thead>
              <tr>
                <th>{{ $t('CONVERSATION_SKIPS.REASON') }}</th>
                <th>{{ $t('CONVERSATION_SKIPS.SKIPPED_AT') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="skip in skips" :key="skip.id" class="skip-row">
                <td class="reason">{{ skip.reason }}</td>
                <td class="timestamp">{{ new Date(skip.created_at).toLocaleString() }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else class="text-center empty-state">
          {{ $t('CONVERSATION_SKIPS.NO_SKIPS') }}
        </div>
      </div>
    </div>
  </template>
  
  <script>
  import { mapGetters } from 'vuex';
  import conversationSkipsAPI from '../../../api/conversation/conversationSkips';
  
  export default {
    data() {
      return {
        loading: true,
        skips: [],
      };
    },
    computed: {
      ...mapGetters({
        currentConversation: 'getSelectedChat',
      }),
    },
    async mounted() {
      try {
        if (this.currentConversation?.id) {
          const response = await conversationSkipsAPI.get(this.currentConversation.id);
          this.skips = response.data;
        }
      } catch (error) {
        // Handle error
      } finally {
        this.loading = false;
      }
    },
  };
  </script>
  
  <style lang="scss" scoped>
  .content-wrapper {
    height: 100%;
    display: flex;
    flex-direction: column;
  }
  
  .table-container {
    flex-grow: 1;
    margin: 0;
    background: var(--color-background);
    height: 100%;
    overflow: auto;
  }
  
  .woot-table {
    width: 100%;
    border-collapse: collapse;
    background: var(--color-background);
  
    th, td {
      padding: var(--space-small) var(--space-normal);
      text-align: left;
      border-bottom: 1px solid var(--color-border-dark);
    }
  
    th {
      position: sticky;
      top: 0;
      background: var(--color-background-dark);
      color: var(--color-heading);
      font-weight: var(--font-weight-medium);
      z-index: 1;
    }
  
    .skip-row {
      &:hover {
        background: var(--color-background-dark);
      }
  
      td {
        color: var(--color-body);
      }
  
      .timestamp {
        color: var(--color-text-light);
        font-size: var(--font-size-small);
      }
    }
  }
  
  .empty-state {
    padding: var(--space-large);
    color: var(--color-text-light);
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .text-center {
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  </style> 