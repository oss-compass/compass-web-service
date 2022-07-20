import { AxiosResponse } from 'axios';
import { http } from '@/services/http.service';
import { IAnalysisTask } from '@/types/general';

export const analyze = (task: IAnalysisTask): Promise<AxiosResponse> => {
	return http.post('analyze', task);
};

export const check = (projectUrl: string): Promise<AxiosResponse> => {
	return http.get('check', {
		params: {
			project_url: projectUrl
		}
	});
};
