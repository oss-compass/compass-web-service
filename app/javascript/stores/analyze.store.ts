import { AxiosResponse } from 'axios';
import { acceptHMRUpdate, defineStore } from 'pinia';
import AnalyzeService from '@/services/analyze.service';
import { AnalysisTask } from '@/types/general';

interface IState {
  status: string | null;
}

const initialState: IState = { status: AnalyzeService.getStatus() };

export const useAnalyzeStore = defineStore('analyze.store', {
  state: (): IState => ({ ...initialState }),
  getters: {
    isFinshed: (state: IState) => !!state.status,
  },
  actions: {
    start(task: AnalysisTask) {
      return AnalyzeService.startAnalyze(task).then(
        (response: AxiosResponse) => {
          this.status = response.data;
          return Promise.resolve(response);
        },
        (error) => {
          return Promise.reject(error);
        },
      );
    },
  },
});

if (import.meta.hot) {
  import.meta.hot.accept(acceptHMRUpdate(useAnalyzeStore, import.meta.hot));
}
