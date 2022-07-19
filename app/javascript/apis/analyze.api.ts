import { AxiosResponse } from 'axios';
import { http } from '@/services/http.service';
import { AnalysisTask } from '@/types/general';

export const analyze = (task: AnalysisTask): Promise<AxiosResponse> => {
  return http.post('analyze', task);
};
