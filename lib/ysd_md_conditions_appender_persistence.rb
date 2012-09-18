module Users
   #
   # Conditions for a Persistence::Resource
   #
   # It's a module which can be extended by a datamapper resource to "inject"
   # the conditions to access only those resource which we have access   
   #  
   module AccessControlConditionsAppenderPersistence
         include AccessControlConditionsAppender
         
        #
        # Override the method to append the conditions
        #
        def all(options = {})

          upgraded_options = build_access_control_conditions(options)
          original_all(upgraded_options)                  

        end         
         
        def count(options = {})
        
          upgraded_options = build_access_control_conditions(options)
          count = original_count(upgraded_options)
        
          count
          
        end
        
        private
        
        def build_access_control_conditions(options)
        
          # Get the access control conditions
          ac_conditions = access_control_conditions
          
          # Merge with the conditions
          
          conditions = if options.has_key?(:conditions)
                          Conditions::JoinComparison.new('$and', [options.fetch(:conditions), ac_conditions])
                       else
                          ac_conditions
                       end
 
          # Prepare the query
       
          upgraded_options = options.dup
          upgraded_options.store(:conditions, conditions)
        
          upgraded_options
          
        end 
         
   end #AccessControlConditionsAppenderPersistence
   
end #Users
