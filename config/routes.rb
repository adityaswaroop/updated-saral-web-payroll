UpdatedSaralWebPayroll::Application.routes.draw do

  resources :leave_takens do
    get 'upload', :on => :collection
    post 'upload_parse_validate', :on => :collection
    post 'save', :on => :collection
    get 'generate_sample_excel_template',  :on => :collection
  end

  resources :leave_opening_balances do
    get "upload", :on => :collection
    post "save_uploaded_data", :on => :collection
  end
  resources :option_settings, :only => [:index, :edit, :update] do
    get 'currency', :on => :collection

  end

  resources :leave_definitions

  resources :company_documents , :except => [:index, :show] do
    get 'download', :on => :collection
  end

  resources :employee_statutories, :except => [:index,:show,:destroy]

  resources :hr_masters, :except => [:index, :show]

  resources :hr_category_details, :except => [:show]

  resources :hr_categories, :except => [:show]

  resources :financial_institutions

  resources :pt_group_rates, :only => [:new, :create]

  resources :esi_group_rates, :except => [:show]

  resources :branches do
    resources :pt_details, :except => [:index, :show]
    resources :pf_details, :except => [:index, :show]
    resources :esi_details, :except => [:index, :show]
  end

  resources :pf_group_rates

  resources :esi_groups, :except => [:show]

  resources :pf_groups, :except => [:show]

  resources :classifications, :except => [:show]

  resources :classification_headings, :except => [:show]

  resources :holidays

  resources :attendance_configurations, :except => [:show]

  resources :pt_rates, :except => [:show]

  resources :pt_groups

  resources :paymonths, :except => [:edit, :update] do
    post "save",:on => :collection
  end

  resources :states, :except => [:show]

  resources :employee_details

  resources :employees do
    resource :employee_statutories, :only => [:new, :edit]
    get "upload",  :on => :collection
    post "upload_parse_validate",  :on => :collection
    post "save", :on => :collection

    get "report",  :on => :collection

    get "pf_contribution_restrict", :on => :collection

    put "pf_restrict_update", :on => :collection

    get 'generate_sample_excel_template',  :on => :collection
  end




  resources :leave_details do
    get 'upload', :on => :collection
    post 'upload_parse_validate', :on => :collection
    post 'save', :on => :collection
    get 'generate_sample_excel_template',  :on => :collection
  end

  resources :companies, :except => [:show, :destroy] do
    get 'documents_list', :on => :collection
    get 'backup', :on => :collection
    get 'upload', :on => :collection
    post 'restore', :on => :collection
    post 'backup_option', :on => :collection
    post 'restore_backup', :on => :collection
  end

  resources :salary_group_details do
    get 'group_details', :on => :collection
  end

  resources :salary_heads, :except => [:show]

  resources :salary_groups, :except => [:show]

  resources :salary_allotments, :only => [:edit, :update, :index] do
    put :update, :on => :collection

    get 'upload', :on => :collection
    post 'upload_parse_validate', :on => :collection
    get 'generate_sample_excel_template',  :on => :collection
  end

  root :to => 'welcome#index'

  match 'login' => 'sessions#new', :as => :login
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'welcome' => 'welcome#index', :as => :welcome

  resources :lops, :only => [:index, :create] do
    post 'file_upload', :on => :collection
  end

  resources :sessions, :only => [:new, :create, :destroy]
  resources :users
  resources :salaries do
    get 'edit', :on => :collection
    put :update, :on => :collection
    post "save_every_month_comp", :on => :collection

    get "salary_sheet",  :on => :collection
  end

  #resources :employee_statutories do
  # # match 'employee_statutories/new/:id' => 'employee_statutories/new', :as => :new_employee_statutories
  #end


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
