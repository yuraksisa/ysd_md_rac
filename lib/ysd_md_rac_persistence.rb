module Users

  #
  # ResourceAccessControl for Persistence System
  #
  module ResourceAccessControlPersistence
        
     #
     # Updates the resource access control information if not has been set
     #
     def create
     
      profile = connected_user
      
      if connected_user and (attribute_get(:permission_owner).nil? or attribute_get(:permission_owner).to_s.strip.length == 0)
        attribute_set(:permission_owner, connected_user.username) 
      end

      if connected_user and connected_user.usergroups.length > 0 and (attribute_get(:permission_group).nil? or attribute_get(:permission_group).to_s.strip.length == 0)
        attribute_set(:permission_group, connected_user.usergroups.first) 
      end

      if attribute_get(:permission_modifier_owner).nil? or attribute_get(:permission_modifier_owner).to_s.strip.length == 0      
        attribute_set(:permission_modifier_owner, 6) 
      end
      
      if attribute_get(:permission_modifier_group).nil? or attribute_get(:permission_modifier_group).to_s.strip.length == 0
        attribute_set(:permission_modifier_group, 2) 
      end
      
      if attribute_get(:permission_modifier_all).nil? or attribute_get(:permission_modifier_all).to_s.strip.length == 0
        attribute_set(:permission_modifier_all, 2) 
      end
      
      super
     
     end
        
  end # ResourceAccessControlPersitence

end #Users