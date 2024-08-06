module InfernoTWCoreIG
  class MediaGroup < Inferno::TestGroup
    title 'Media Tests'
    description 'Verify that the server makes Media resources available'
    id :media_group

    test do
      title 'Server returns requested Media resource from the Media read interaction'
      description %(
        Verify that Media resources can be read from the server.
      )

      input :media_id,
            title: 'Media ID'

      # Named requests can be used by other tests
      makes_request :media

      run do
        fhir_read(:media, media_id, name: :media)

        assert_response_status(200)
        assert_resource_type(:media)
        assert resource.id == media_id,
               "Requested resource with id #{media_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'Media resource is valid'
      description %(
        Verify that the Media resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :media request in the
      # previous test
      uses_request :media

      run do
        assert_resource_type(:media)
        assert_valid_resource
      end
    end
  end
end
