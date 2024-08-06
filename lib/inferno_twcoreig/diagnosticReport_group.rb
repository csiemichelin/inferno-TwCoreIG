module InfernoTWCoreIG
  class DiagnosticReportGroup < Inferno::TestGroup
    title 'DiagnosticReport Tests'
    description 'Verify that the server makes DiagnosticReport resources available'
    id :diagnosticReport_group

    test do
      title 'Server returns requested DiagnosticReport resource from the DiagnosticReport read interaction'
      description %(
        Verify that DiagnosticReport resources can be read from the server.
      )

      input :diagnosticReport_id,
            title: 'DiagnosticReport ID'

      # Named requests can be used by other tests
      makes_request :diagnosticReport

      run do
        fhir_read(:diagnosticReport, diagnosticReport_id, name: :diagnosticReport)

        assert_response_status(200)
        assert_resource_type(:diagnosticReport)
        assert resource.id == diagnosticReport_id,
               "Requested resource with id #{diagnosticReport_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'DiagnosticReport resource is valid'
      description %(
        Verify that the DiagnosticReport resource returned from the server is a valid FHIR resource.
      )
      # This test will use the response from the :diagnosticReport request in the
      # previous test
      uses_request :diagnosticReport

      run do
        assert_resource_type(:diagnosticReport)
        assert_valid_resource
      end
    end
  end
end
