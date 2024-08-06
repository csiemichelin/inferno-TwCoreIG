module InfernoTWCoreIG
  class BundleGroup < Inferno::TestGroup
    title 'Bundle Tests'
    description 'Verify that the server makes Bundle resources available'
    id :bundle_group

    test do
      title 'Server returns requested Bundle resource from the Bundle read interaction'
      description %(
        Verify that Bundle resources can be read from the server.
      )

      input :bundle_id,
            title: 'Bundle ID'

      # Named requests can be used by other tests
      makes_request :bundle

      run do
        fhir_read(:bundle, bundle_id, name: :bundle)

        assert_response_status(200)
        assert_resource_type(:bundle)
        assert resource.id == bundle_id,
               "Requested resource with id #{bundle_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'Bundle resource is valid'
      description %(
        Verify that the Bundle resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :bundle request in the
      # previous test
      uses_request :bundle

      run do
        assert_resource_type(:bundle)
        assert_valid_resource
      end
    end
  end
end
