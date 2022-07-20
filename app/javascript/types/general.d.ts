export interface IUserLogin {
	email: string;
	password: string;
}

export interface IRegisterUser extends IUserLogin {
	password_confirmation: string;
}

export interface ICurrentUser {
	id: number;
}

export interface IAnalysisTask {
	project_url: string;
	raw: boolean;
	enrich: boolean;
	metrics: boolean;
}
