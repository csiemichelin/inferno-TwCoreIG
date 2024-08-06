module InfernoTWCoreIG
  class DocumentReferenceGroup < Inferno::TestGroup
    title 'DocumentReference Tests'
    description 'Verify that the server makes DocumentReference resources available'
    id :documentReference_group

    test do
      title 'Server returns requested DocumentReference resource from the DocumentReference read interaction'
      description %(
        Verify that DocumentReference resources can be read from the server.
      )

      input :documentReference_id,
            title: 'DocumentReference ID'

      # Named requests can be used by other tests
      makes_request :documentReference

      run do
        fhir_read(:documentReference, documentReference_id, name: :documentReference)

        assert_response_status(200)
        assert_resource_type(:documentReference)
        assert resource.id == documentReference_id,
               "Requested resource with id #{documentReference_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'DocumentReference resource is valid'
      description %(
        Verify that the DocumentReference resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :documentReference request in the
      # previous test
      uses_request :documentReference

      run do
        assert_resource_type(:documentReference)
        assert_valid_resource
      end
    end
  end
end
