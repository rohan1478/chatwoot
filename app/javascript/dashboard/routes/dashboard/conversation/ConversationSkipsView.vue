<template>
    <div class="flex w-full flex-col h-full bg-white dark:bg-slate-800 rounded-lg shadow-sm border border-slate-200 dark:border-slate-700">
      <div class="flex items-center justify-between p-5 border-b border-slate-200 dark:border-slate-700">
        <h2 class="text-xl font-semibold text-slate-800 dark:text-slate-100">
          {{ $t('CONVERSATION_SKIPS.TITLE') }}
        </h2>
        <div class="w-80">
          <select 
            v-model="selectedConversationId" 
            class="w-full px-3 py-2.5 bg-white dark:bg-slate-700 border border-slate-300 dark:border-slate-600 rounded-md shadow-sm 
                   text-slate-700 dark:text-slate-200 placeholder-slate-400 dark:placeholder-slate-500
                   focus:outline-none focus:ring-2 focus:ring-woot-500 focus:border-woot-500
                   disabled:bg-slate-100 dark:disabled:bg-slate-800/50 disabled:cursor-not-allowed disabled:text-slate-400 dark:disabled:text-slate-500
                   transition duration-150 ease-in-out"
            :disabled="isLoadingConversations"
          >
            <option value="" class="text-slate-400 dark:text-slate-500">
              {{ isLoadingConversations 
                ? $t('CONVERSATION_SKIPS.LOADING_CONVERSATIONS') 
                : $t('CONVERSATION_SKIPS.SELECT_CONVERSATION') 
              }}
            </option>
            <option 
              v-for="conversation in allConversations" 
              :key="conversation.id" 
              :value="conversation.id"
              class="text-slate-700 dark:text-slate-200 bg-white dark:bg-slate-700"
            >
              {{ conversation.id }} - {{ conversation.meta?.sender?.name || 'Unknown' }}
            </option>
          </select>
        </div>
      </div>
  
      <div class="flex-1 p-5 overflow-hidden">
        <div v-if="loading || isLoadingConversations" 
             class="flex items-center justify-center h-full">
          <spinner class="w-8 h-8 text-woot-500" />
        </div>
  
        <div v-else-if="skips.length" 
             class="h-full overflow-auto rounded-lg border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800">
          <table class="w-full divide-y divide-slate-200 dark:divide-slate-700">
            <thead class="bg-slate-50 dark:bg-slate-700/50">
              <tr>
                <th class="sticky top-0 px-5 py-3.5 text-left text-sm font-semibold text-slate-700 dark:text-slate-200 bg-slate-50 dark:bg-slate-700/50 backdrop-blur">
                  {{ $t('CONVERSATION_SKIPS.REASON') }}
                </th>
                <th class="sticky top-0 px-5 py-3.5 text-left text-sm font-semibold text-slate-700 dark:text-slate-200 bg-slate-50 dark:bg-slate-700/50 backdrop-blur">
                  {{ $t('CONVERSATION_SKIPS.SKIPPED_BY') }}
                </th>
                <th class="sticky top-0 px-5 py-3.5 text-left text-sm font-semibold text-slate-700 dark:text-slate-200 bg-slate-50 dark:bg-slate-700/50 backdrop-blur">
                  {{ $t('CONVERSATION_SKIPS.SKIPPED_AT') }}
                </th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-200 dark:divide-slate-700">
              <tr v-for="skip in skips" 
                  :key="skip.id" 
                  class="hover:bg-slate-50 dark:hover:bg-slate-700/30 transition-colors duration-150">
                <td class="px-5 py-3.5 text-sm text-slate-700 dark:text-slate-300">
                  {{ skip.reason }}
                </td>
                <td class="px-5 py-3.5 text-sm font-medium text-woot-500 dark:text-woot-400">
                  <div class="flex items-center gap-2">
                    <img 
                      v-if="skip.user.avatar_url" 
                      :src="skip.user.avatar_url" 
                      :alt="skip.user.name"
                      class="w-6 h-6 rounded-full"
                    />
                    <div>
                      <div class="font-medium">{{ skip.user.name }}</div>
                      <div class="text-xs text-slate-500 dark:text-slate-400">{{ skip.user.email }}</div>
                    </div>
                  </div>
                </td>
                <td class="px-5 py-3.5 text-sm text-slate-500 dark:text-slate-400">
                  {{ new Date(skip.created_at).toLocaleString() }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
  
        <div v-else 
             class="flex items-center justify-center h-full rounded-lg border-2 border-dashed border-slate-300 dark:border-slate-600 
                    bg-slate-50 dark:bg-slate-800/30 text-slate-500 dark:text-slate-400 text-sm p-8 text-center">
          <div>
            <span v-if="selectedConversationId" class="block mb-1.5">
              {{ $t('CONVERSATION_SKIPS.NO_SKIPS') }}
            </span>
            <span v-else class="block">
              {{ $t('CONVERSATION_SKIPS.SELECT_TO_VIEW') }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted, watch, computed } from 'vue';
  import { useStore } from 'vuex';
  import conversationSkipsAPI from '../../../api/conversation/conversationSkips';
  
  const store = useStore();
  const loading = ref(false);
  const skips = ref([]);
  const selectedConversationId = ref('');
  const isLoadingConversations = ref(true);
  
  const allConversations = computed(() => store.getters.getAllConversations);
  
  onMounted(async () => {
      await store.dispatch('clearConversationFilters');
      await store.dispatch('conversationPage/reset');
      await store.dispatch('clearSelectedState');
    try {
      isLoadingConversations.value = true;
      await store.dispatch('fetchAllConversations');
    } catch (error) {
      // TODO: Handle error
    } finally {
      isLoadingConversations.value = false;
    }
  });
  
  watch(selectedConversationId, async (newId) => {
    if (!newId) {
      skips.value = [];
      return;
    }
    
    loading.value = true;
    try {
      const response = await conversationSkipsAPI.get(newId);
      skips.value = response.data;
    } catch (error) {
      // TODO: Handle error
    } finally {
      loading.value = false;
    }
  });
  </script> 