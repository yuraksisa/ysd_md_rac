module Users
 
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
      
      #
      #
      #   
      def self.included(model)

        model.property :permission_owner, String, :field => 'permission_owner', :length => 32
        model.property :permission_group, String, :field => 'permission_group', :length => 32
        model.property :permission_modifier_owner, Integer, :field => 'permission_modifier_owner', :default => 6
        model.property :permission_modifier_group, Integer, :field => 'permission_modifier_group', :default => 2
        model.property :permission_modifier_all, Integer, :field => 'permission_modifier_all', :default => 0
  
        model.class_eval do
          class << self 
             alias_method :original_all, :all
             alias_method :original_count, :count
          end
        end         
 
        if Persistence::Model.descendants.include?(model)  
          model.send :include, ResourceAccessControlPersistence
          model.extend(AccessControlConditionsAppenderPersistence)   
        else
          if DataMapper::Model.descendants.include?(model)
            model.send :include, ResourceAccessControlDataMapper
            model.extend(AccessControlConditionsAppenderDataMapper)
          end
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
           can_access_group = (options.include?(attribute_get(:permission_modifier_group)) and profile.usergroups.include?(attribute_get(:permission_group))) 
           can_access_owner = (options.include?(attribute_get(:permission_modifier_owner)) and profile.username == attribute_get(:permission_owner))
           
           can_access_resource = (superuser_access or can_access_group or can_access_owner)
        end
        
        return can_access_resource
            
      end
       
  end # ResourceAccessControl

  
end #Users