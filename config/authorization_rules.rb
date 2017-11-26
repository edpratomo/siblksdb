authorization do
  role :guest do
    # add permissions for guests here, e.g.
    # has_permission_on :conferences, :to => :read
  end
  
  # permissions on other roles, such as
  role :sysadmin do
    [:students, :programs, :pkgs, :schedules, 
     :users, :settings, :instructors, 
     :courses, :grades, :students_records].each do |controller|
      has_permission_on controller, :to => :manage
    end
    has_permission_on :changes, :to => :read
  end

  role :admin do
    has_permission_on :instructors, :to => :manage
    has_permission_on :users,       :to => :manage
    has_permission_on :grades,      :to => :read
    has_permission_on :courses,     :to => :read
    has_permission_on :students_records, :to => :read
  end

  role :instructor do
    has_permission_on :students, :to => :read
    has_permission_on :grades,   :to => :manage
    has_permission_on :courses,  :to => :read
  end

  role :staff do
    has_permission_on :students, :to => :manage
    has_permission_on :grades,   :to => :read
    has_permission_on :courses,  :to => :read
    has_permission_on :students_records, :to => :manage
  end
  # role :admin do
  #   has_permission_on :conferences, :to => :manage
  # end
  # role :user do
  #   has_permission_on :conferences, :to => [:read, :create]
  #   has_permission_on :conferences, :to => [:update, :delete] do
  #     if_attribute :user_id => is {user.id}
  #   end
  # end
  # See the readme or GitHub for more examples
end

privileges do
  # default privilege hierarchies to facilitate RESTful Rails apps
  privilege :manage, :includes => [:create, :read, :delete,
                                   :update, :update_schedule]
  privilege :read, :includes => [:index, :show, :options_for_result, :name_suggestions,
                                 :district_suggestions, :regency_suggestions, :index_all,
                                 :show_by_component]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :update_schedule, :includes => :edit_schedule
  privilege :delete, :includes => :destroy
end
