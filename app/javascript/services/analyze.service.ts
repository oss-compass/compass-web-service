import { IAnalysisTask } from '@/types/general';
import { analyze, check } from '@/apis/analyze.api';

class AnalyzeService {
  async startAnalyze(task: IAnalysisTask) {
    return analyze(task).then((response) => {
      if (response.data) {
        localStorage.setItem('status', response.data.status);
      }
      return response.data;
    });
  }

	async checkAnalyze(projectUrl: string) {
		return check(projectUrl).then((response) => {
      return response.data;
    });
	}

  getStatus() {
    const status = localStorage.getItem('status');

    if (status) {
      try {
        return status;
      } catch {
        return null;
      }
    }

    return null;
  }
}

const instance = new AnalyzeService();

export default instance;
