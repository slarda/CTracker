class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    can :dashboard
    can :custom_dashboard

    if user and user.super_admin
      can :read, :all
      can :index, :all
      can :export, :all
      can :history, :all
      can :destroy, :all
      can :update, :all
      can :manage, :all
    else
      # Scope normal access to stuff within your own organisation
      # models = [Association, Club, Division, Equipment, Game, League, PlayerEquipment, PlayerPosition, PlayerProfile,
      #           PlayerResult, Position, Team, User]

      # Org-level users can do anything to their own stuff
      #can [:read, :index, :export, :history, :destroy, :update, :manage], models,
      #    :organisation_id => user.organisation_id if user.present?

      # Users can do anything to their own user details, and player results, and player equipment
      can [:read, :index, :export, :history, :destroy, :update, :manage], User, :id => user.id if user.present?
      can [:read, :index, :export, :history, :destroy, :update, :manage], PlayerResult, :player_id => user.id if user.present?
      can [:read, :index, :create, :update, :destroy, :manage], PlayerEquipment, :user_id => user.id if user.present?

      # Teams, Clubs, Games and Associations are all public (for now)
      can :read, Team
      can :read, Club
      can :read, Game
      can :read, Association
      can :read, PlayerResult
      can :read, League

      # All Users are public (for now)
      can :read, User

      # Positions are all public
      can :read, Position

      # Articles are all publicly readable
      can :read, Article

      # Brands and Equipment are publicly readable
      can :read, Equipment
      can :read, Brand

    end

    # Any user can unimpersonate (it's difficult to get true_user here in the model)
    can :unimpersonate, :all

    # Anyone can create a new user
    can :create, User

  end
end
