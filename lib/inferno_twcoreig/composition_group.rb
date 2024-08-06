module InfernoTWCoreIG
  class CompositionGroup < Inferno::TestGroup
    title 'Composition Tests'
    description 'Verify that the server makes Composition resources available'
    id :composition_group

    test do
      title 'Server returns requested Composition resource from the Composition read interaction'
      description %(
        Verify that Composition resources can be read from the server.
      )

      input :composition_id,
            title: 'Composition ID'

      # Named requests can be used by other tests
      makes_request :composition

      run do
        fhir_read(:composition, composition_id, name: :composition)

        assert_response_status(200)
        assert_resource_type(:composition)
        assert resource.id == composition_id,
               "Requested resource with id #{composition_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'Composition resource is valid'
      description %(
        Verify that the Composition resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :composition request in the
      # previous test
      uses_request :composition

      run do
        assert_resource_type(:composition)
        assert_valid_resource
      end
    end
  end
end
