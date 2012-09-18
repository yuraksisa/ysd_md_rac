require 'ysd_md_system' unless defined?Model::System::Request
require 'ysd_md_comparison' unless defined?Conditions::Comparison

module Users

  # AccessControlConditionsAppender
  #
  # It's an extension which builds the conditions that will allow retrieve only the
  # information which belongs to us or which we have access to.
  #
  # It includes the YSD::System::Request module to access request information
  #
  # Not use this module directly. Use your concrete ORM implementation
  #
  module AccessControlConditionsAppender
      include Model::System::Request
                
        #
        # Create the query conditions to access the resource
        #
        # @params [Profile]
        #
        #  the user profile we can check
        #
        # @return [Conditions::Comparison]
        #
        #  A Comparison which have to be matched to access the resource
        #
        #
        def access_control_conditions
      
          conditions = []
      
          profile = connected_user
      
          if profile
       
            conditions_owner = Conditions::JoinComparison.new('$and', 
                                 [Conditions::Comparison.new(:permission_owner, '$eq', profile.username),
                                  Conditions::Comparison.new(:permision_modifier_owner, '$in', [2,6])])
          
            conditions << conditions_owner        
       
            if (profile_groups=profile.usergroups).length > 0
       
              conditions_group = Conditions::JoinComparison.new('$and',
                                   [Conditions::Comparison.new(:permission_group, '$in', profile_groups),
                                    Conditions::Comparison.new(:permission_modifier_group, '$in', [2,6])])    
            
              conditions << conditions_group
            end
        
          end
        
          conditions_all = Conditions::Comparison.new(:permission_modifier_all, '$in', [2,6])       
          conditions << conditions_all


          if conditions.length > 1
            conditions = Conditions::JoinComparison.new('$or', conditions)
          else        
            conditions.first
          end
          
        end
        
                  
   end

end