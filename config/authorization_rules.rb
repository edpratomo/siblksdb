authorization do
  role :guest do
    # add permissions for guests here, e.g.
    # has_permission_on :conferences, :to => :read
  end
  
  # permissions on other roles, such as
  role :sysadmin do
    [:students, :pkgs, :schedules, :users, :settings, :instructors, :grades].each do |controller|
      has_permission_on controller, :to => :manage
    end
    has_permission_on :changes, :to => :read
  end

  role :admin do
    has_permission_on :instructors, :to => :manage
    has_permission_on :users,       :to => :manage
  end

  role :instructor do
    has_permission_on :students, :to => :read
    has_permission_on :grades,   :to => :manage
  end

  role :staff do
    has_permission_on :students, :to => :manage
    has_permission_on :grades,   :to => :read
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
  privilege :manage, :includes => [:create, :read, :update, :update_schedule, :delete]
  privilege :read, :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :update_schedule, :includes => :edit_schedule
  privilege :delete, :includes => :destroy
end
