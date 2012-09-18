module Users

  #
  # ResourceAccessControl for DataMapper
  #
  module ResourceAccessControlDataMapper
    include ResourceAccessControl
    
      #
      # When the resource is included
      #
      def self.included(model)    
     
        ResourceAccessControl.prepare_model(model)
        model.extend(AccessControlConditionsAppenderDataMapper)  
     
     end
           
  end #ResourceAccessControlDataMapper

end #Users