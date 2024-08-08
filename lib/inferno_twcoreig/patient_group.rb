module InfernoTWCoreIG
  class PatientGroup < Inferno::TestGroup
    title 'Patient(病人) Tests '
    description 'Verify that the server makes Patient resources available'
    id :patient_group

    # Define inputs here to ensure the correct order
    input :url,
    title: 'FHIR Server Base Url'
      
    input :credentials,
    title: 'OAuth Credentials',
    type: :oauth_credentials,
    optional: true

    # 建議應該（SHOULD） 支援透過查詢參數 _id 查詢所有Patient：
    test do
      title '[GET] Server returns valid results for Patient search by _id'
      description %(
        A server SHALL support searching by _id on the Patient resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core Patient）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Patient-twcore.html)
        )

      input :patient_id,
        title: 'Patient _id'

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
      title '[GET] Server returns valid results for Patient search by birthdate'
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
      title '[GET] Server returns valid results for Patient search by gender'
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
      title '[GET] Server returns valid results for Patient search by identifier'
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
      title '[GET] Server returns valid results for Patient search by name'
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

    # 驗證查詢 _id 的 Patient resource 是否合規
    test do
      title '[GET] Patient resource is valid'
      description %(
        Verify that the Patient resource search by _id returned from the server is a valid FHIR resource.

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
        assert_resource_type('Bundle')
        assert_valid_resource
      end
    end

    # 驗證輸入的Resource是否合規
    test do 
      title '[POST] Input Patient resource is valid'
      description %(
        Verify that the Patient resource input is a valid FHIR resource.

        * Verifying the HTTP status code of a response.
        
        * Verifying that a string is valid JSON.
        
        * Validating a FHIR Resource.

        [臺灣核心-病人（TW Core Patient）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Patient-twcore.html)
      )
      input :patient_resource,
            title: 'Patient Resource'
      
      output :patient_value
      
      run do 
        assert_valid_json(patient_resource) # For safety
        resource_hash = JSON.parse(patient_resource)
        patient_resource = FHIR::Patient.new(resource_hash)
        # output patient_value: patient_resource
        assert_valid_resource(resource: patient_resource)
        # if resource_is_valid?(resource: patient_resource)
        # end
      end 
    end 

    # 發送POST請求包含Resource Body給FHIR Server
    test do 
      title '[POST] Send Patient Resource to FHIR Server'
      description %(
        Send a input Patient resource to a FHIR server database.

        [臺灣核心-病人（TW Core Patient）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Patient-twcore.html)
      )

      input :patient_resource,
            title: 'Patient Resource'

      run do 
        resource_hash = JSON.parse(patient_resource)
        response = fhir_create FHIR::Patient.new(resource_hash)
        assert response.status == 201
      end
    end
  end
end
