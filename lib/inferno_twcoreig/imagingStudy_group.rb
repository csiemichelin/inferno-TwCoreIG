module InfernoTWCoreIG
  class ImagingStudyGroup < Inferno::TestGroup
    title 'ImagingStudy Tests'
    description 'Verify that the server makes ImagingStudy resources available'
    id :imagingStudy_group

    test do
      title 'Server returns requested ImagingStudy resource from the ImagingStudy read interaction'
      description %(
        Verify that ImagingStudy resources can be read from the server.
      )

      input :imagingStudy_id,
            title: 'ImagingStudy ID'

      # Named requests can be used by other tests
      makes_request :imagingStudy

      run do
        fhir_read(:imagingStudy, imagingStudy_id, name: :imagingStudy)

        assert_response_status(200)
        assert_resource_type(:imagingStudy)
        assert resource.id == imagingStudy_id,
               "Requested resource with id #{imagingStudy_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'ImagingStudy resource is valid'
      description %(
        Verify that the ImagingStudy resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :imagingStudy request in the
      # previous test
      uses_request :imagingStudy

      run do
        assert_resource_type(:imagingStudy)
        assert_valid_resource
      end
    end
  end
end
