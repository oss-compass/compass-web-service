import { AxiosResponse } from 'axios';
import { acceptHMRUpdate, defineStore } from 'pinia';
import AnalyzeService from '@/services/analyze.service';
import { IAnalysisTask } from '@/types/general';

interface IState {
  project_url: string | null;
  status: string | null;
  message: string | null;
}

const initialState: IState = {
  project_url: '',
  status: '',
  message: ''
};

export const useAnalyzeStore = defineStore('analyze.store', {
  state: (): IState => ({ ...initialState }),
  getters: {
    isFinshed: (state: IState) => state.status === 'finished' || state.status === 'failed',
  },
  actions: {
    updateState(projectUrl: string, data: any) {
      this.$patch((state) => {
	state.status = data?.status
	state.message = data?.message
	state.project_url = projectUrl
      })
    },
    start(task: IAnalysisTask) {
      return AnalyzeService.startAnalyze(task).then(
        (response: AxiosResponse) => {
	  this.updateState(task.project_url, response.data);
          return Promise.resolve(response);
        },
        (error) => {
          return Promise.reject(error);
        },
      );
    },
    check(projectUrl: string) {
      return AnalyzeService.checkAnalyze(projectUrl).then(
        (response: AxiosResponse) => {
	  this.updateState(projectUrl, response.data);
          return Promise.resolve(response);
        },
        (error) => {
          return Promise.reject(error);
        },
      );
    }
  },
});

if (import.meta.hot) {
  import.meta.hot.accept(acceptHMRUpdate(useAnalyzeStore, import.meta.hot));
}
