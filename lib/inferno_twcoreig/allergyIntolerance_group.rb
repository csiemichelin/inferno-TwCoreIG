module InfernoTWCoreIG
  class AllergyIntoleranceGroup < Inferno::TestGroup
    title 'AllergyIntolerance Tests'
    description 'Verify that the server makes AllergyIntolerance resources available'
    id :allergyIntolerance_group

    test do
      title 'Server returns requested AllergyIntolerance resource from the AllergyIntolerance read interaction'
      description %(
        Verify that AllergyIntolerance resources can be read from the server.
      )

      input :allergyIntolerance_id,
            title: 'AllergyIntolerance ID'

      # Named requests can be used by other tests
      makes_request :allergyIntolerance

      run do
        fhir_read(:allergyIntolerance, allergyIntolerance_id, name: :allergyIntolerance)

        assert_response_status(200)
        assert_resource_type(:allergyIntolerance)
        assert resource.id == allergyIntolerance_id,
               "Requested resource with id #{allergyIntolerance_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'AllergyIntolerance resource is valid'
      description %(
        Verify that the AllergyIntolerance resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :allergyIntolerance request in the
      # previous test
      uses_request :allergyIntolerance

      run do
        assert_resource_type(:allergyIntolerance)
        assert_valid_resource
      end
    end
  end
end
