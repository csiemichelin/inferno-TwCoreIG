module InfernoTWCoreIG
  class ProcedureGroup < Inferno::TestGroup
    title 'Procedure Tests'
    description 'Verify that the server makes Procedure resources available'
    id :procedure_group

    test do
      title 'Server returns requested Procedure resource from the Procedure read interaction'
      description %(
        Verify that Procedure resources can be read from the server.
      )

      input :procedure_id,
            title: 'Procedure ID'

      # Named requests can be used by other tests
      makes_request :procedure

      run do
        fhir_read(:procedure, procedure_id, name: :procedure)

        assert_response_status(200)
        assert_resource_type(:procedure)
        assert resource.id == procedure_id,
               "Requested resource with id #{procedure_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'Procedure resource is valid'
      description %(
        Verify that the Procedure resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :procedure request in the
      # previous test
      uses_request :procedure

      run do
        assert_resource_type(:procedure)
        assert_valid_resource
      end
    end
  end
end
