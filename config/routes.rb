Rails.application.routes.draw do

	root 's3bases#index'
	get '/' => 's3bases#index'

	resources :homes do
		collection do
			get "top"
			get "scr"
			get "scr2"
		end
	end

	resources :s1_switches do
	end

	resources :s2dmms do
	end

	resources :s3bases do
		collection do
			get "collect"
			get "search"
			get "submit"
			post "invoke_base_scraping_lambda"
			post "bulk_submission"
			post "invoke_bulk_submission_lambda"
			post "confirm"
		end
	end

	resources :s3_sender_infos do
		collection do
			post "activate"
		end
	end

	resources :s4tunos do
	end
end
