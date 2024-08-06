module InfernoTWCoreIG
  class ObservationGroup < Inferno::TestGroup
    title 'Observation Tests'
    description 'Verify that the server makes Observation resources available'
    id :observation_group

    test do
      title 'Server returns requested Observation resource from the Observation read interaction'
      description %(
        Verify that Observation resources can be read from the server.
      )

      input :observation_id,
            title: 'Observation ID'

      # Named requests can be used by other tests
      makes_request :observation

      run do
        fhir_read(:observation, observation_id, name: :observation)

        assert_response_status(200)
        assert_resource_type(:observation)
        assert resource.id == observation_id,
               "Requested resource with id #{observation_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'Observation resource is valid'
      description %(
        Verify that the Observation resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :observation request in the
      # previous test
      uses_request :observation

      run do
        assert_resource_type(:observation)
        assert_valid_resource
      end
    end
  end
end
