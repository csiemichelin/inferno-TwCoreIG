module InfernoTWCoreIG
  class MedicationRequestGroup < Inferno::TestGroup
    title 'MedicationRequest Tests'
    description 'Verify that the server makes MedicationRequest resources available'
    id :medicationRequest_group

    test do
      title 'Server returns requested MedicationRequest resource from the MedicationRequest read interaction'
      description %(
        Verify that MedicationRequest resources can be read from the server.
      )

      input :medicationRequest_id,
            title: 'MedicationRequest ID'

      # Named requests can be used by other tests
      makes_request :medicationRequest

      run do
        fhir_read(:medicationRequest, medicationRequest_id, name: :medicationRequest)

        assert_response_status(200)
        assert_resource_type(:medicationRequest)
        assert resource.id == medicationRequest_id,
               "Requested resource with id #{medicationRequest_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'MedicationRequest resource is valid'
      description %(
        Verify that the MedicationRequest resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :medicationRequest request in the
      # previous test
      uses_request :medicationRequest

      run do
        assert_resource_type(:medicationRequest)
        assert_valid_resource
      end
    end
  end
end
