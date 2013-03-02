require 'ysd-md-profile' 
require 'ysd-persistence'

module Users
 
  module AccessConditionsAppender
      include Users::ConnectedUser # To access the connected user

      #
      # Create the query conditions to access the resource
      #
      #
      # @return [Conditions::Comparison]
      #
      #  A Comparison which have to be matched to access the resource
      #
      #
      def access_control_conditions
      
        conditions = []
      
        if connected_user
          conditions << Conditions::JoinComparison.new('$and', 
                               [Conditions::Comparison.new(:permission_owner, '$eq', connected_user.username),
                                Conditions::Comparison.new(:permission_modifier_owner, '$in', [2,6])])
       
          if connected_user.usergroups.length > 0
            conditions << Conditions::JoinComparison.new('$and',
                                 [Conditions::Comparison.new(:permission_group, '$in', connected_user.usergroups.map {|item| item.group}),
                                  Conditions::Comparison.new(:permission_modifier_group, '$in', [2,6])])    
          end
        
        end
        
        conditions << Conditions::Comparison.new(:permission_modifier_all, '$in', [2,6])       

        if conditions.length > 1
          conditions = Conditions::JoinComparison.new('$or', conditions)
        else        
          conditions.first
        end
          
      end

  end

  #
  # It represents the resource access control to check if a profile can access a resource
  #
  # If we want to control the access to a resource we only have to include this module in the
  # resource
  #
  # By default a resource can be read/write by the owner, read by the group and not allowed by the others
  #
  # We have created three properties to represents each of the permission modifiers to make the query process easy
  #
  #                    User   -     Group    -    All
  #  
  #                    W R X        W R X        W R X 
  #                    -----        -----        -----
  #   No permission    0 0 0        0 0 0        0 0 0
  #   Read             0 1 0        0 1 0        0 1 0
  #   Write            1 0 0        0 1 0        0 1 0
  #   Read and Write   1 1 0        0 1 0        0 1 0
  #
  #
  #
  module ResourceAccessControl
      include Users::ConnectedUser
      extend Users::AccessConditionsAppender
      
      def self.updated_connected_user
        
        if @models
        @models.each do |model|   
          if Persistence::Model.descendants.include?(model)  
            model.default_scope.update(access_control_conditions)
          else
            if DataMapper::Model.descendants.include?(model)
              model.default_scope.update({:conditions => access_control_conditions.build_sql})
            end
          end 
        end
        end

      end

      #
      #
      #   
      def self.included(model)

        if model.respond_to?(:property)
          model.property :permission_owner, String, :field => 'permission_owner', :length => 20
          model.property :permission_group, String, :field => 'permission_group', :length => 32
          model.property :permission_modifier_owner, Integer, :field => 'permission_modifier_owner', :default => 6
          model.property :permission_modifier_group, Integer, :field => 'permission_modifier_group', :default => 2
          model.property :permission_modifier_all, Integer, :field => 'permission_modifier_all', :default => 0
        end

        if model.respond_to?(:before)
          model.before :create do |data|
            init_rac_data
          end
        end

        # Add the permissions conditions
        if model.respond_to?(:default_scope)
          @models ||= []
          @models << model
        end
         
      end
  
      #
      # Check if the profile can read the resource
      #
      # @params [Users::Profile]
      #
      #  The user profile (or nil for anonymous user)
      #
      def can_read?(profile)
      
        can_access?(profile, [2,6])
        
      end
 
      #
      # Check if the profile can write the resource
      #
      # @params [Users::Profile]
      #
      #  The user profile (or nil for anonymous user)
      #     
      def can_write?(profile)
      
        can_access?(profile, [4,6])
      
      end
         
      private
      
      #
      # Check if the user can access the resource 
      #
      # @param [Users::Profile] profile
      #   
      #   The user profile
      #
      # @param [Array] options
      #
      #   Array which represents the modifiers
      #
      # @return [Boolean]
      #
      #   True if the profile can access the resource
      #
      #
      def can_access?(profile, options)
        
        can_access_resource = options.include?(attribute_get(:permission_modifier_all)) 
        
        if profile and not can_access_resource
           superuser_access = profile.is_superuser?
           can_access_group = (options.include?(attribute_get(:permission_modifier_group)) and profile.usergroups.map{|item| item.group }.include?(attribute_get(:permission_group))) 
           can_access_owner = (options.include?(attribute_get(:permission_modifier_owner)) and profile.username == attribute_get(:permission_owner))
           
           can_access_resource = (superuser_access or can_access_group or can_access_owner)
        end
        
        return can_access_resource
            
      end

      #
      # Initialize the data on an creation operation 
      #
      def init_rac_data
        
        if connected_user and (self.permission_owner.nil? or self.permission_owner.empty?)
          self.permission_owner = connected_user.username
        end

        if connected_user and connected_user.usergroups.length > 0 and (self.permission_group.nil? or self.permission_group.empty?)
          self.permission_group = connected_user.usergroups.first.group 
        end

        if self.permission_modifier_owner.nil?   
          self.permission_modifier_owner = 6 
        end
      
        if self.permission_modifier_group.nil?
          self.permission_modifier_group = 2 
        end
      
        if self.permission_modifier_all.nil?
          self.permission_modifier_all = 0
        end 

      end


  end # ResourceAccessControl
  
end #Users