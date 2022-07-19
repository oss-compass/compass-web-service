import { AnalysisTask } from '@/types/general';
import { analyze } from '@/apis/analyze.api';

class AnalyzeService {
  async startAnalyze(task: AnalysisTask) {
    return analyze(task).then((response) => {
      if (response.data) {
        localStorage.setItem('status', response.data);
      }

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
