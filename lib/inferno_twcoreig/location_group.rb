module InfernoTWCoreIG
  class LocationGroup < Inferno::TestGroup
    title 'Location Tests'
    description 'Verify that the server makes Location resources available'
    id :location_group

    test do
      title 'Server returns requested Location resource from the Location read interaction'
      description %(
        Verify that Location resources can be read from the server.
      )

      input :location_id,
            title: 'Location ID'

      # Named requests can be used by other tests
      makes_request :location

      run do
        fhir_read(:location, location_id, name: :location)

        assert_response_status(200)
        assert_resource_type(:location)
        assert resource.id == location_id,
               "Requested resource with id #{location_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'Location resource is valid'
      description %(
        Verify that the Location resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :location request in the
      # previous test
      uses_request :location

      run do
        assert_resource_type(:location)
        assert_valid_resource
      end
    end
  end
end
