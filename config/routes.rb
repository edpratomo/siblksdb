Rails.application.routes.draw do

  resources :password_resets
  resources :exams

  resources :grades, :except => [:edit, :update, :show] do
    member do
      get 'options_for_exam'
    end
  end

  patch 'grades/update_component'

  get 'grades/all' => 'grades#index_all'

  get 'report/new_monthly_generic'
  
  get 'report/create_monthly_generic_summary'
  
  get 'report/create_monthly_generic'
  
  get 'report/new_disnaker'

  get 'report/create_disnaker'

  get 'settings/edit'

  patch 'settings/update'

  resources :students_records, :except => [:new, :index] do
    collection do
      get 'new/:id' => 'students_records#new', as: "new"
    end
    member do
      get 'grade_point'
    end
  end

  resources :changes

  get 'profile/show'

  get 'profile/edit'

  patch 'profile/update'

  resources :instructors_schedules

  resources :programs_instructors

  resources :instructors do
    member do
      get 'edit_schedule'
      patch 'update_schedule'
    end
  end

  controller :presence_sheet do
    get 'presence_sheet/new'
    get 'presence_sheet/create'
  end
  
  get 'help/index'

  resources :student_schedule, :except => [:edit] do
    collection do
      get ':id/:pkg_id/edit' => 'student_schedule#edit', as: "edit"
      get ':id/brief' => 'student_schedule#brief'
    end
  end
  
  get 'welcome/index'

  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end

  get 'sessions/create'

  get 'sessions/destroy'

  resources :students do
    member do
      delete ':pid/remove_pkg' => 'students#remove_pkg', as: 'remove_pkg'
      delete ':pid/finish_pkg' => 'students#finish_pkg', as: "finish_pkg"
    end

    collection do
      get 'name_suggestions'
      get 'district_suggestions'
      get 'regency_suggestions'
      get 'search'

      get ':id/attending' => 'students#attending', as: "attending"
    end
  end

  resources :schedules

  resources :pkgs

  resources :programs

  resources :users

  resources :groups

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
