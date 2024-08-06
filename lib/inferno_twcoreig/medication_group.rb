module InfernoTWCoreIG
  class MedicationGroup < Inferno::TestGroup
    title 'Medication Tests'
    description 'Verify that the server makes Medication resources available'
    id :medication_group

    test do
      title 'Server returns requested Medication resource from the Medication read interaction'
      description %(
        Verify that Medication resources can be read from the server.
      )

      input :medication_id,
            title: 'Medication ID'

      # Named requests can be used by other tests
      makes_request :medication

      run do
        fhir_read(:medication, medication_id, name: :medication)

        assert_response_status(200)
        assert_resource_type(:medication)
        assert resource.id == medication_id,
               "Requested resource with id #{medication_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'Medication resource is valid'
      description %(
        Verify that the Medication resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :medication request in the
      # previous test
      uses_request :medication

      run do
        assert_resource_type(:medication)
        assert_valid_resource
      end
    end
  end
end
