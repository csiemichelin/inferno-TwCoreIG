module InfernoTWCoreIG
  class PractitionerGroup < Inferno::TestGroup
    title 'Practitioner Tests'
    description 'Verify that the server makes Practitioner resources available'
    id :practitioner_group

    test do
      title 'Server returns requested Practitioner resource from the Practitioner read interaction'
      description %(
        Verify that Practitioner resources can be read from the server.
      )

      input :practitioner_id,
            title: 'Practitioner ID'

      # Named requests can be used by other tests
      makes_request :practitioner

      run do
        fhir_read(:practitioner, practitioner_id, name: :practitioner)

        assert_response_status(200)
        assert_resource_type(:practitioner)
        assert resource.id == practitioner_id,
               "Requested resource with id #{practitioner_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'Practitioner resource is valid'
      description %(
        Verify that the Practitioner resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :practitioner request in the
      # previous test
      uses_request :practitioner

      run do
        assert_resource_type(:practitioner)
        assert_valid_resource
      end
    end
  end
end
