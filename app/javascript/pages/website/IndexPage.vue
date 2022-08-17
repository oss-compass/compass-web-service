<template>
  <div class="flex flex-col container content-center mx-auto place-content-center min-h-screen-sm">
    <div class="flex flex-col justify-center">
      <h1 class="text-2xl font-semibold italic">Welcome to Compass Web Service</h1>
      <div class="mt-2 mb-3 w-128">
        <div class="input-group relative flex flex-wrap items-stretch w-full mb-4">
          <input
            v-model="task.project_url"
            type="search"
            class="form-control relative flex-auto min-w-0 block w-full px-3 py-1.5 text-base font-normal text-gray-700 bg-white bg-clip-padding border border-solid border-gray-300 rounded transition ease-in-out m-0 focus:text-gray-700 focus:bg-white focus:border-blue-600 focus:outline-none"
            placeholder="Please input project url"
            aria-label="Search"
            aria-describedby="button-addon3"
          />
          <button
            id="button-addon3"
            class="px-6 py-2 mt-6 border-2 border-blue-600 text-blue-600 font-medium text-xs rounded hover:bg-black hover:bg-opacity-5 focus:outline-none focus:ring-0 transition duration-150 ease-in-out flex flex-row"
            type="button"
            :disabled="analyzing"
            @click.prevent="submit"
          >
            <svg
              v-if="analyzing"
              xmlns="http://www.w3.org/2000/svg"
              class="w-5 h-5 animate-spin"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fill-rule="evenodd"
                d="M4 2a1 1 0 011 1v2.101a7.002 7.002 0 0111.601 2.566 1 1 0 11-1.885.666A5.002 5.002 0 005.999 7H9a1 1 0 010 2H4a1 1 0 01-1-1V3a1 1 0 011-1zm.008 9.057a1 1 0 011.276.61A5.002 5.002 0 0014.001 13H11a1 1 0 110-2h5a1 1 0 011 1v5a1 1 0 11-2 0v-2.101a7.002 7.002 0 01-11.601-2.566 1 1 0 01.61-1.276z"
                clip-rule="evenodd"
              />
            </svg>
            <svg
              v-else
              aria-hidden="true"
              focusable="false"
              data-prefix="fas"
              data-icon="search"
              class="w-4"
              role="img"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 512 512"
            >
              <path
                fill="currentColor"
                d="M505 442.7L405.3 343c-4.5-4.5-10.6-7-17-7H372c27.6-35.3 44-79.7 44-128C416 93.1 322.9 0 208 0S0 93.1 0 208s93.1 208 208 208c48.3 0 92.7-16.4 128-44v16.3c0 6.4 2.5 12.5 7 17l99.7 99.7c9.4 9.4 24.6 9.4 33.9 0l28.3-28.3c9.4-9.4 9.4-24.6.1-34zM208 336c-70.7 0-128-57.2-128-128 0-70.7 57.2-128 128-128 70.7 0 128 57.2 128 128 0 70.7-57.2 128-128 128z"
              ></path>
            </svg>
            <span class="font-semibold text-sm mt-2">快速分析</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, watch } from 'vue';
import { useAnalyzeStore } from '@/stores/analyze.store';
import { IAnalysisTask } from '@/types/general';
import { showToast } from '@/utils/showToast';

const analyzeStore = useAnalyzeStore();
const analyzing = ref(false);
const manual = ref(false)
const showTips = ref(true);

const task = reactive<IAnalysisTask>({
  project_url: '',
  raw: true,
  enrich: true,
  metrics: true,
 });

 watch(() => task.project_url, () => {
   spellCheck();
 });

 const check = () => {
   analyzeStore.check(task.project_url).then(
     (response) => {
       if (response.status === 'failed') {
         analyzing.value = false
         showToast(response.message, 'error');
       } else if (response.status === 'finished') {
         analyzing.value = false
         showToast(response.message, 'success');
       } else {
         analyzing.value = true;
         if (showTips.value) {
           showToast(response.message, 'warning');
           showTips.value = false
         }
         if (!manual.value) {
           setTimeout(() => { check(); }, 5000);
         }
       }
     }
   )
 }

 const spellCheck = () => {
   manual.value = true
   showTips.value = true
   check()
   manual.value = false
 }

 const submit = () => {
  analyzing.value = true;
  analyzeStore.start(task).then(
    (response) => {
      showToast(response.message, 'success');
      check()
    },
    (error) => {
      showToast(error, 'error');
      analyzing.value = false;
    },
  );
};
</script>
