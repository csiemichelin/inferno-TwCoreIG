module InfernoTWCoreIG
  class MedicationStatementGroup < Inferno::TestGroup
    title 'MedicationStatement Tests'
    description 'Verify that the server makes MedicationStatement resources available'
    id :medicationStatement_group

    test do
      title 'Server returns requested MedicationStatement resource from the MedicationStatement read interaction'
      description %(
        Verify that MedicationStatement resources can be read from the server.
      )

      input :medicationStatement_id,
            title: 'MedicationStatement ID'

      # Named requests can be used by other tests
      makes_request :medicationStatement

      run do
        fhir_read(:medicationStatement, medicationStatement_id, name: :medicationStatement)

        assert_response_status(200)
        assert_resource_type(:medicationStatement)
        assert resource.id == medicationStatement_id,
               "Requested resource with id #{medicationStatement_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'MedicationStatement resource is valid'
      description %(
        Verify that the MedicationStatement resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :medicationStatement request in the
      # previous test
      uses_request :medicationStatement

      run do
        assert_resource_type(:medicationStatement)
        assert_valid_resource
      end
    end
  end
end
