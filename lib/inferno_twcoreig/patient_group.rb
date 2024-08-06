module InfernoTWCoreIG
  class PatientGroup < Inferno::TestGroup
    title 'Patient Tests'
    description 'Verify that the server makes Patient resources available'
    id :patient_group

    # 建議應該（SHOULD） 支援透過查詢參數 _id 查詢所有Patient：
    test do
      title 'Server returns valid results for Patient search by _id'
      description %(
        A server SHALL support searching by _id on the Patient resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core Patient）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Patient-twcore.html)
        )

      input :patient_id,
            title: 'Patient ID'

      # Named requests can be used by other tests
      makes_request :patient

      run do
        fhir_search('Patient', params: { _id: patient_id }, name: :patient)

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 birthdate 查詢所有Patient：
    test do
      title 'Server returns valid results for Patient search by birthdate'
      description %(
        A server SHALL support searching by birthdate on the Patient resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        [臺灣核心-病人（TW Core Patient）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Patient-twcore.html)
        )

      input :patient_birthdate,
            title: 'Patient Birthdate'

      run do
        fhir_search('Patient', params: { birthdate: patient_birthdate })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 gender 查詢所有Patient：
    test do
      title 'Server returns valid results for Patient search by gender'
      description %(
        A server SHALL support searching by gender on the Patient resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        [臺灣核心-病人（TW Core Patient）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Patient-twcore.html)
        )

      input :patient_gender,
            title: 'Patient Gender'

      run do
        fhir_search('Patient', params: { gender: patient_gender })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 identifier 查詢所有Patient：
    test do
      title 'Server returns valid results for Patient search by identifier'
      description %(
        A server SHALL support searching by identifier on the Patient resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        [臺灣核心-病人（TW Core Patient）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Patient-twcore.html)
        )

      input :patient_identifier,
            title: 'Patient Identifier'

      run do
        fhir_search('Patient', params: { identifier: patient_identifier })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 name 查詢所有Patient：
    test do
      title 'Server returns valid results for Patient search by name'
      description %(
        A server SHALL support searching by name on the Patient resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        [臺灣核心-病人（TW Core Patient）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Patient-twcore.html)
        )

      input :patient_name,
            title: 'Patient Name'

      run do
        fhir_search('Patient', params: { name: patient_name })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    test do
      title 'Patient resource is valid'
      description %(
        Verify that the Patient resource returned from the server is a valid FHIR resource.

        * Verifying the HTTP status code of a response.
        
        * Verifying that a string is valid JSON.
        
        * Validating a FHIR Resource.

        [臺灣核心-病人（TW Core Patient）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Patient-twcore.html)
      )
      # This test will use the response from the :patient request in the
      # previous test
      uses_request :patient

      run do
        assert_response_status(200)
        assert_resource_type(:patient)
        assert_valid_resource
      end
    end
  end
end
