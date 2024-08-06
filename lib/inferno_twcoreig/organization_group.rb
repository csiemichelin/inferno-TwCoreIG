module InfernoTWCoreIG
  class OrganizationGroup < Inferno::TestGroup
    title 'Organization Tests'
    description 'Verify that the server makes Organization resources available'
    id :organization_group

    test do
      title 'Server returns requested Organization resource from the Organization read interaction'
      description %(
        Verify that Organization resources can be read from the server.
      )

      input :organization_id,
            title: 'Organization ID'

      # Named requests can be used by other tests
      makes_request :organization

      run do
        fhir_read(:organization, organization_id, name: :organization)

        assert_response_status(200)
        assert_resource_type(:organization)
        assert resource.id == organization_id,
               "Requested resource with id #{organization_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'Organization resource is valid'
      description %(
        Verify that the Organization resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :organization request in the
      # previous test
      uses_request :organization

      run do
        assert_resource_type(:organization)
        assert_valid_resource
      end
    end
  end
end
