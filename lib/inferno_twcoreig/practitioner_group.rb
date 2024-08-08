module InfernoTWCoreIG
  class PractitionerGroup < Inferno::TestGroup
    title 'Practitioner(健康照護服務提供者) Tests'
    description 'Verify that the server makes Practitioner resources available'
    id :practitioner_group

    # Define inputs here to ensure the correct order
    input :url,
    title: 'FHIR Server Base Url'
      
    input :credentials,
    title: 'OAuth Credentials',
    type: :oauth_credentials,
    optional: true

    # 建議應該（SHOULD） 支援透過查詢參數 _id 查詢所有Practitioner：
    test do
      title '[GET] Server returns valid results for Practitioner search by _id'
      description %(
        A server SHALL support searching by _id on the Practitioner resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core Practitioner）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Practitioner-twcore.html)
        )

      input :practitioner_id,
        title: 'Practitioner _id'

      # Named requests can be used by other tests
      makes_request :practitioner

      run do
        fhir_search('Practitioner', params: { _id: practitioner_id }, name: :practitioner)

        assert_response_status(200)
        assert_resource_type('Practitioner')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 identifier 查詢所有Practitioner：
    test do
      title '[GET] Server returns valid results for Practitioner search by identifier'
      description %(
        A server SHALL support searching by identifier on the Practitioner resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        [臺灣核心-病人（TW Core Practitioner）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Practitioner-twcore.html)
        )

      input :practitioner_identifier,
            title: 'Practitioner identifier'

      run do
        fhir_search('Practitioner', params: { 'identifier': practitioner_identifier })

        assert_response_status(200)
        assert_resource_type('Practitioner')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 name 查詢所有Practitioner：
    test do
      title '[GET] Server returns valid results for Practitioner search by name'
      description %(
        A server SHALL support searching by name on the Practitioner resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        [臺灣核心-病人（TW Core Practitioner）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Practitioner-twcore.html)
        )

      input :practitioner_nam,
            title: 'Practitioner name'

      run do
        fhir_search('Practitioner', params: { 'name': practitioner_name })

        assert_response_status(200)
        assert_resource_type('Practitioner')
      end
    end

    # 驗證查詢 _id 的 Practitioner resource 是否合規
    test do
      title '[GET] Practitioner resource is valid'
      description %(
        Verify that the Practitioner resource search by _id returned from the server is a valid FHIR resource.

        * Verifying the HTTP status code of a response.
        
        * Verifying that a string is valid JSON.
        
        * Validating a FHIR Resource.

        [臺灣核心-病人（TW Core Practitioner）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Practitioner-twcore.html)
      )
      # This test will use the response from the :practitioner request in the
      # previous test
      uses_request :practitioner

      run do
        assert_response_status(200)
        assert_resource_type('Practitioner')
        assert_valid_resource
      end
    end

    # 驗證輸入的Resource是否合規
    test do 
      title '[POST] Input Practitioner resource is valid'
      description %(
        Verify that the Practitioner resource input is a valid FHIR resource.

        * Verifying the HTTP status code of a response.
        
        * Verifying that a string is valid JSON.
        
        * Validating a FHIR Resource.

        [臺灣核心-病人（TW Core Practitioner）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Practitioner-twcore.html)
      )
      input :practitioner_resource,
            title: 'Practitioner Resource'
      
      output :practitioner_value
      
      run do 
        assert_valid_json(practitioner_resource) # For safety
        resource_hash = JSON.parse(practitioner_resource)
        practitioner_resource = FHIR::Practitioner.new(resource_hash)
        # output practitioner_value: practitioner_resource
        assert_valid_resource(resource: practitioner_resource)
        # if resource_is_valid?(resource: practitioner_resource)
        # end
      end 
    end 

    # 發送POST請求包含Transaction Practitioners(支援多個Resource驗證)的Body給FHIR Server
    test do 
      title '[POST] Send Practitioner Resource to FHIR Server'
      description %(
        Send a input Transaction Practitioner(Support multiple Resource verification) to a FHIR server database.

        [臺灣核心-病人（TW Core Practitioner）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Practitioner-twcore.html)
      )

      input :practitioner_resource,
            title: 'Practitioner Resource'

      run do 
        resource_hash = JSON.parse(practitioner_resource)
        response = fhir_create FHIR::Practitioner.new(resource_hash)
        assert response.status == 201
      end
    end
  end
end
