module InfernoTWCoreIG
  class SpecimenGroup < Inferno::TestGroup
    title 'Specimen Tests'
    description 'Verify that the server makes Specimen resources available'
    id :specimen_group

    test do
      title 'Server returns requested Specimen resource from the Specimen read interaction'
      description %(
        Verify that Specimen resources can be read from the server.
      )

      input :specimen_id,
            title: 'Specimen ID'

      # Named requests can be used by other tests
      makes_request :specimen

      run do
        fhir_read(:specimen, specimen_id, name: :specimen)

        assert_response_status(200)
        assert_resource_type(:specimen)
        assert resource.id == specimen_id,
               "Requested resource with id #{specimen_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'Specimen resource is valid'
      description %(
        Verify that the Specimen resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :specimen request in the
      # previous test
      uses_request :specimen

      run do
        assert_resource_type(:specimen)
        assert_valid_resource
      end
    end
  end
end
