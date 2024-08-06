module InfernoTWCoreIG
  class EncounterGroup < Inferno::TestGroup
    title 'Encounter Tests'
    description 'Verify that the server makes Encounter resources available'
    id :encounter_group

    test do
      title 'Server returns requested Encounter resource from the Encounter read interaction'
      description %(
        Verify that Encounter resources can be read from the server.
      )

      input :encounter_id,
            title: 'Encounter ID'

      # Named requests can be used by other tests
      makes_request :encounter

      run do
        fhir_read(:encounter, encounter_id, name: :encounter)

        assert_response_status(200)
        assert_resource_type(:encounter)
        assert resource.id == encounter_id,
               "Requested resource with id #{encounter_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'Encounter resource is valid'
      description %(
        Verify that the Encounter resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :encounter request in the
      # previous test
      uses_request :encounter

      run do
        assert_resource_type(:encounter)
        assert_valid_resource
      end
    end
  end
end
