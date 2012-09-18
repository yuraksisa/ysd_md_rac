module Users

   #
   # Conditions for DataMapper::Resource
   #
   # It's a module which can be extended by a datamapper resource to "inject"
   # the conditions to access only those resource which we have access
   #
   module AccessControlConditionsAppenderDataMapper
         include AccessControlConditionsAppender

        #
        # Override the method to append the conditions
        #
        def all(options = {})
                   
          original_all(options)                  

        end
      
   end #AccessControlConditionsAppenderDataMapper

end #Users