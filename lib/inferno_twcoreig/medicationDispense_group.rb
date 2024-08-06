module InfernoTWCoreIG
  class MedicationDispenseGroup < Inferno::TestGroup
    title 'MedicationDispense Tests'
    description 'Verify that the server makes MedicationDispense resources available'
    id :medicationDispense_group

    test do
      title 'Server returns requested MedicationDispense resource from the MedicationDispense read interaction'
      description %(
        Verify that MedicationDispense resources can be read from the server.
      )

      input :medicationDispense_id,
            title: 'MedicationDispense ID'

      # Named requests can be used by other tests
      makes_request :medicationDispense

      run do
        fhir_read(:medicationDispense, medicationDispense_id, name: :medicationDispense)

        assert_response_status(200)
        assert_resource_type(:medicationDispense)
        assert resource.id == medicationDispense_id,
               "Requested resource with id #{medicationDispense_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'MedicationDispense resource is valid'
      description %(
        Verify that the MedicationDispense resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :medicationDispense request in the
      # previous test
      uses_request :medicationDispense

      run do
        assert_resource_type(:medicationDispense)
        assert_valid_resource
      end
    end
  end
end
