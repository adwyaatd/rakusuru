Rails.application.routes.draw do

	root 'homes#top'
	get '/' => 'homes#top'

	resources :homes do
		collection do
			get :scr
			get :scr2
		end
	end
end
