<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useStore } from 'vuex';
import ConversationBox from 'dashboard/components/widgets/conversation/ConversationBox.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';

const props = defineProps({
  inboxId: {
    type: [String, Number],
    default: 0,
  }
});

const store = useStore();
const currentIndex = ref(0);

const chatList = computed(() => store.getters.getAllConversations);
const totalConversations = computed(() => chatList.value.length);

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

const fetchConversations = async () => {
  await store.dispatch('fetchAllConversations');
};

async function resetAndFetchData() {
  await store.dispatch('clearConversationFilters');
  await store.dispatch('setChatListFilters', {});
  await store.dispatch('conversationPage/reset');
  await store.dispatch('emptyAllConversations');
  await fetchConversations();
  if (chatList.value.length > 0) {
    setConversationAtIndex(0);
  }
}

watch(
  () => props.label,
  () => resetAndFetchData()
);
watch(
  () => props.conversationType,
  () => resetAndFetchData()
);

onMounted(async () => {
  await store.dispatch('conversationPage/reset');
  await store.dispatch('clearSelectedState');
  await store.dispatch('clearConversationFilters');
  await resetAndFetchData();
});
</script>

<template>
  <div class="flex flex-col w-full h-full">
    <div class="flex-1 min-h-0 h-full w-full">
      <ConversationBox
        :inbox-id="props.inboxId"
        :is-on-expanded-layout="props.isOnExpandedLayout"
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
        :label="$t ? $t('Skip Conversation') : 'Skip Conversation'"
        color="blue"
        variant="solid"
        size="md"
        :disabled="currentIndex === totalConversations - 1"
        @click="navigateNext"
      />
    </div>
  </div>
</template>
