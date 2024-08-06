module InfernoTWCoreIG
  class MessageHeaderGroup < Inferno::TestGroup
    title 'MessageHeader Tests'
    description 'Verify that the server makes MessageHeader resources available'
    id :messageHeader_group

    test do
      title 'Server returns requested MessageHeader resource from the MessageHeader read interaction'
      description %(
        Verify that MessageHeader resources can be read from the server.
      )

      input :messageHeader_id,
            title: 'MessageHeader ID'

      # Named requests can be used by other tests
      makes_request :messageHeader

      run do
        fhir_read(:messageHeader, messageHeader_id, name: :messageHeader)

        assert_response_status(200)
        assert_resource_type(:messageHeader)
        assert resource.id == messageHeader_id,
               "Requested resource with id #{messageHeader_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'MessageHeader resource is valid'
      description %(
        Verify that the MessageHeader resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :messageHeader request in the
      # previous test
      uses_request :messageHeader

      run do
        assert_resource_type(:messageHeader)
        assert_valid_resource
      end
    end
  end
end
