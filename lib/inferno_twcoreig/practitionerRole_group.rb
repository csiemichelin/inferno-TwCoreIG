module InfernoTWCoreIG
  class PractitionerRoleGroup < Inferno::TestGroup
    title 'PractitionerRole Tests'
    description 'Verify that the server makes PractitionerRole resources available'
    id :practitionerRole_group

    test do
      title 'Server returns requested PractitionerRole resource from the PractitionerRole read interaction'
      description %(
        Verify that PractitionerRole resources can be read from the server.
      )

      input :practitionerRole_id,
            title: 'PractitionerRole ID'

      # Named requests can be used by other tests
      makes_request :practitionerRole

      run do
        fhir_read(:practitionerRole, practitionerRole_id, name: :practitionerRole)

        assert_response_status(200)
        assert_resource_type(:practitionerRole)
        assert resource.id == practitionerRole_id,
               "Requested resource with id #{practitionerRole_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'PractitionerRole resource is valid'
      description %(
        Verify that the PractitionerRole resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :practitionerRole request in the
      # previous test
      uses_request :practitionerRole

      run do
        assert_resource_type(:practitionerRole)
        assert_valid_resource
      end
    end
  end
end
