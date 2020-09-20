Rails.application.routes.draw do

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
	end
end
