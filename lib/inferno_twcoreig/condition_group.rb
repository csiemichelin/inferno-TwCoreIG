module InfernoTWCoreIG
  class ConditionGroup < Inferno::TestGroup
    title 'Condition Tests'
    description 'Verify that the server makes Condition resources available'
    id :condition_group

    test do
      title 'Server returns requested Condition resource from the Condition read interaction'
      description %(
        Verify that Condition resources can be read from the server.
      )

      input :condition_id,
            title: 'Condition ID'

      # Named requests can be used by other tests
      makes_request :condition

      run do
        fhir_read(:condition, condition_id, name: :condition)

        assert_response_status(200)
        assert_resource_type(:condition)
        assert resource.id == condition_id,
               "Requested resource with id #{condition_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'Condition resource is valid'
      description %(
        Verify that the Condition resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :condition request in the
      # previous test
      uses_request :condition

      run do
        assert_resource_type(:condition)
        assert_valid_resource
      end
    end

    test do
      title 'Condition bundle is valid'
      description %(
        Verify that the Condition bundle returned from the server is a valid FHIR bundle.
        
        * Verifying the HTTP status code of a response.
        
        * Verifying that a string is valid JSON.
        
        * Validating a FHIR Condition Bundle.

        [臺灣核心-病人（TW Core Patient）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Condition-twcore.html)
      )
      # This test will use the response from the :condition request in the
      # previous test

      input :patient_id,
            title: 'Patient ID'
    
      run do
        fhir_search('Condition', params: { subject: patient_id })

        assert_response_status(200)
        assert_resource_type('Bundle')
        info(resource.to_json)
        assert_valid_bundle_entries
      end
    end
  end
end
