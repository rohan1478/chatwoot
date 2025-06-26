<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useStore } from 'vuex';
import { useMapGetter } from 'dashboard/composables/store.js';
import { useSnakeCase, useCamelCase } from 'dashboard/composables/useTransformKeys';
import { useTrack } from 'dashboard/composables';
import filterQueryGenerator from 'dashboard/helper/filterQueryGenerator';
import ConversationBox from 'dashboard/components/widgets/conversation/ConversationBox.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';
import ConversationSkipsAPI from '../../../api/conversation/conversationSkips';
import ConversationBasicFilter from 'dashboard/components/widgets/conversation/ConversationBasicFilter.vue';
import ConversationFilter from 'dashboard/components-next/filter/ConversationFilter.vue';
import wootConstants from 'dashboard/constants/globals';
import { CONVERSATION_EVENTS } from 'dashboard/helper/AnalyticsHelper/events';
import { useFilter } from 'shared/composables/useFilter';

const props = defineProps({
  inboxId: {
    type: [String, Number],
    default: 0,
  },
  isOnExpandedLayout: {
    type: Boolean,
    default: false,
  }
});

const store = useStore();
const currentIndex = ref(0);
const activeStatus = ref(wootConstants.STATUS_TYPE.OPEN);
const activeSortBy = ref(wootConstants.SORT_BY_TYPE.LAST_ACTIVITY_AT_DESC);
const appliedFilter = ref([]);
const showAdvancedFilters = ref(false);
const hasActiveFolders = ref(false);
const activeFolderName = ref('');
const foldersQuery = ref({});

const chatList = computed(() => store.getters.getAllConversations);
const totalConversations = computed(() => chatList.value.length);
const appliedFilters = useMapGetter('getAppliedConversationFiltersV2');
const currentFiltersPage = useMapGetter('conversationPage/getCurrentPageFilter', 'appliedFilters');

const hasAppliedFilters = computed(() => {
  return appliedFilters.value.length !== 0;
});

const conversationFilters = computed(() => {
  return {
    inboxId: props.inboxId || undefined,
    status: activeStatus.value,
    sortBy: activeSortBy.value,
  };
});

const setConversationAtIndex = (index) => {
  const conversation = chatList.value[index];
  if (conversation) {
    store.dispatch('setActiveChat', { data: conversation });
    currentIndex.value = index;
  }
};

const navigateNext = () => {
  if (currentIndex.value < totalConversations.value - 1) {
    setConversationAtIndex(currentIndex.value + 1);
  }
};

const onBasicFilterChange = async (value, type) => {
  if (type === 'status') {
    activeStatus.value = value;
  } else {
    activeSortBy.value = value;
  }
  await resetAndFetchData();
};

const fetchConversations = async () => {
  await store.dispatch('updateChatListFilters', conversationFilters.value);
  await store.dispatch('fetchAllConversations');
  if (chatList.value.length > 0) {
    setConversationAtIndex(0);
  }
};

async function resetAndFetchData() {
  await store.dispatch('clearConversationFilters');
  await store.dispatch('conversationPage/reset');
  await store.dispatch('clearSelectedState');
  await store.dispatch('emptyAllConversations');
  await fetchConversations();
}

watch([activeStatus, activeSortBy], () => {
  store.dispatch('updateChatListFilters', conversationFilters.value);
});

watch(
  () => props.label,
  () => resetAndFetchData()
);
watch(
  () => props.conversationType,
  () => resetAndFetchData()
);

const isSkipModalOpen = ref(false);
const skipReason = ref('');

const openSkipModal = () => {
  isSkipModalOpen.value = true;
  skipReason.value = '';
};
const closeSkipModal = () => {
  isSkipModalOpen.value = false;
  skipReason.value = '';
};
const submitSkipReason = async () => {
  try {
    const currentConversation = chatList.value[currentIndex.value];
    await ConversationSkipsAPI.create(currentConversation.id, skipReason.value);
    closeSkipModal();
    navigateNext();
  } catch (error) {
    console.error('Error submitting skip reason:', error);
  }
};

const fetchFilteredConversations = async (payload) => {
  payload = useSnakeCase(payload);
  const page = currentFiltersPage.value + 1;
  await store.dispatch('setConversationFilters', payload);
  await store.dispatch('fetchFilteredConversations', {
    queryData: filterQueryGenerator(payload),
    page,
  });
  if (chatList.value.length > 0) {
    setConversationAtIndex(0);
  }
  showAdvancedFilters.value = false;
};

const onApplyFilter = async (payload) => {
  payload = useSnakeCase(payload);
  foldersQuery.value = filterQueryGenerator(payload);
  await store.dispatch('conversationPage/reset');
  await store.dispatch('emptyAllConversations');
  await fetchFilteredConversations(payload);
  useTrack(CONVERSATION_EVENTS.APPLY_FILTER, {
    appliedFilters: payload.map(filter => ({
      key: filter.attributeKey,
      operator: filter.filterOperator,
      queryOperator: filter.queryOperator,
    })),
  });
};

const resetFilters = async () => {
  appliedFilter.value = [];
  await store.dispatch('clearConversationFilters');
  await resetAndFetchData();
};

const {
  initializeStatusAndAssigneeFilterToModal,
  initializeInboxTeamAndLabelFilterToModal,
} = useFilter({
  filteri18nKey: 'FILTER',
  attributeModel: 'conversation_attribute',
});

const initializeExistingFilterToModal = () => {
  const filters = conversationFilters.value;
  initializeStatusAndAssigneeFilterToModal(filters, appliedFilter);
  initializeInboxTeamAndLabelFilterToModal(filters, appliedFilter);
};

const initalizeAppliedFiltersToModal = () => {
  appliedFilter.value = useCamelCase(appliedFilters.value);
};

const onToggleAdvanceFiltersModal = () => {
  if (showAdvancedFilters.value === true) {
    closeAdvanceFiltersModal();
    return;
  }

  if (!hasAppliedFilters.value) {
    initializeExistingFilterToModal();
  } else {
    initalizeAppliedFiltersToModal();
  }

  showAdvancedFilters.value = true;
};

const onUpdateSavedFilter = () => {
  // Not implemented for play mode
};

const closeAdvanceFiltersModal = () => {
  showAdvancedFilters.value = false;
  appliedFilter.value = [];
};

onMounted(async () => {
  await store.dispatch('setChatListFilters', {});
  await store.dispatch('clearConversationFilters');
  await store.dispatch('conversationPage/reset');
  await store.dispatch('clearSelectedState');
  await resetAndFetchData();
});
</script>

<template>
  <div class="flex flex-col w-full h-full">
    <div class="flex items-center justify-between gap-2 px-3 h-12">
      <div class="flex items-center gap-1">
        <div class="relative">
          <NextButton
            id="toggleConversationFilterButton"
            v-tooltip.right="$t('FILTER.TOOLTIP_LABEL')"
            icon="i-lucide-list-filter"
            slate
            xs
            faded
            @click="onToggleAdvanceFiltersModal"
          />
          <div
            id="conversationFilterTeleportTarget"
            class="absolute z-40 mt-2"
            :class="{ 'ltr:right-0 rtl:left-0': isOnExpandedLayout }"
          >
            <ConversationFilter
              v-if="showAdvancedFilters"
              v-model="appliedFilter"
              :folder-name="activeFolderName"
              :is-folder-view="hasActiveFolders"
              @apply-filter="onApplyFilter"
              @update-folder="onUpdateSavedFilter"
              @close="closeAdvanceFiltersModal"
            />
          </div>
        </div>
        <template v-if="hasAppliedFilters">
          <NextButton
            v-tooltip.top-end="$t('FILTER.CLEAR_BUTTON_LABEL')"
            icon="i-lucide-circle-x"
            ruby
            faded
            xs
            @click="resetFilters"
          />
        </template>
        <ConversationBasicFilter
          :is-on-expanded-layout="isOnExpandedLayout"
          @change-filter="onBasicFilterChange"
        />
      </div>
    </div>
    <div class="flex-1 min-h-0 h-full w-full">
      <ConversationBox
        :inbox-id="inboxId"
        :is-on-expanded-layout="isOnExpandedLayout"
        class="h-full w-full"
      />
    </div>
    <div class="flex justify-between items-center p-4 bg-n-container border-b border-n-weak">
      <div class="flex gap-2 items-center flex-1 justify-center">
        <Icon
          v-for="(chat, idx) in totalConversations"
          :key="idx"
          :icon="'i-lucide-circle'"
          :class="[
            'size-4 transition-colors',
            idx === currentIndex ? 'text-n-brand' : 'text-n-slate-5'
          ]"
        />
      </div>
      <NextButton
        v-if="totalConversations > 0"
        :label="$t ? $t('Skip Conversation') : 'Skip Conversation'"
        color="blue"
        variant="solid"
        size="md"
        @click="openSkipModal"
      />
    </div>

    <div v-if="isSkipModalOpen" class="fixed inset-0 z-50 flex items-center justify-center">
      <div class="bg-n-container-dark rounded-lg shadow-lg p-6 w-full max-w-md border dark:bg-slate-800">
        <h2 class="text-lg font-semibold mb-4 text-n-contrast">{{$t ? $t('Skip Conversation') : 'Skip Conversation'}}</h2>
        <label class="block mb-2 font-medium text-n-contrast">{{$t ? $t('Reason for skipping') : 'Reason for skipping'}}</label>
        <textarea
          v-model="skipReason"
          class="w-full border border-n-weak-dark rounded p-2 mb-4 min-h-[80px] bg-n-container-dark text-n-contrast placeholder-n-weak-dark"
          :placeholder="$t ? $t('Enter your reason...') : 'Enter your reason...'"
        ></textarea>
        <div class="flex justify-end gap-2">
          <button
            class="px-4 py-2 rounded border border-n-weak-dark bg-n-container-dark hover:bg-n-weak-dark text-n-contrast"
            @click="closeSkipModal"
            type="button"
          >{{$t ? $t('Cancel') : 'Cancel'}}</button>
          <button
            class="px-4 py-2 rounded bg-blue-500 text-n-contrast hover:bg-blue-600 disabled:opacity-50"
            :disabled="!skipReason"
            @click="submitSkipReason"
            type="button"
          >{{$t ? $t('Submit & Skip') : 'Submit & Skip'}}</button>
        </div>
      </div>
    </div>
  </div>
</template>
