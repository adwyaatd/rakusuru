Rails.application.routes.draw do

  get 's4tunos/index'
	root 'homes#top'
	get '/' => 'homes#top'

	resources :homes do
		collection do
			get :scr
			get :scr2
		end
	end

	resources :s1_switches do
	end

	resources :s2dmms do
	end

	resources :s3bases do
		collection do
			get "search"
		end
	end

	resources :s4tunos do
	end
end
