module InfernoTWCoreIG
  class EncounterGroup < Inferno::TestGroup
    title 'Encounter(就醫事件) Tests'
    description 'Verify that the server makes Encounter resources available'
    id :encounter_group

    # 建議應該（SHOULD） 支援透過查詢參數 _id 查詢所有Encounter：
    test do
      title '[GET] Server returns valid results for Encounter search by _id'
      description %(
        A server SHALL support searching by _id on the Encounter resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core Encounter）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Encounter-twcore.html)
        )

      input :encounter_id,
        title: 'Encounter _id'

      # Named requests can be used by other tests
      makes_request :encounter

      run do
        fhir_search('Encounter', params: { _id: encounter_id }, name: :encounter)

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 class 查詢所有Encounter：
    test do
      title '[GET] Server returns valid results for Encounter search by class'
      description %(
        A server SHALL support searching by class on the Encounter resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core Encounter）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Encounter-twcore.html)
        )

      input :encounter_class,
        title: 'Encounter class'

      run do
        fhir_search('Encounter', params: { 'class': encounter_class })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 date 查詢所有Encounter：
    test do
      title '[GET] Server returns valid results for Encounter search by date'
      description %(
        A server SHALL support searching by date on the Encounter resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core Encounter）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Encounter-twcore.html)
        )

      input :encounter_date,
        title: 'Encounter date'

      run do
        fhir_search('Encounter', params: { date: encounter_date })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 identifier 查詢所有Encounter：
    test do
      title '[GET] Server returns valid results for Encounter search by identifier'
      description %(
        A server SHALL support searching by identifier on the Encounter resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core Encounter）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Encounter-twcore.html)
        )

      input :encounter_identifier,
        title: 'Encounter identifier'

      run do
        fhir_search('Encounter', params: { 'identifier': encounter_identifier })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 location 查詢所有Encounter：
    test do
      title '[GET] Server returns valid results for Encounter search by location'
      description %(
        A server SHALL support searching by location on the Encounter resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core Encounter）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Encounter-twcore.html)
        )

      input :encounter_location,
        title: 'Encounter location'

      run do
        fhir_search('Encounter', params: { 'location': encounter_location })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 subject 查詢所有Encounter：
    test do
      title '[GET] Server returns valid results for Encounter search by subject'
      description %(
        A server SHALL support searching by subject on the Encounter resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core Encounter）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Encounter-twcore.html)
        )

      input :encounter_subject,
        title: 'Encounter subject'

      run do
        fhir_search('Encounter', params: { subject: encounter_subject })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 status 查詢所有Encounter：
    test do
      title '[GET] Server returns valid results for Encounter search by status'
      description %(
        A server SHALL support searching by status on the Encounter resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core Encounter）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Encounter-twcore.html)
        )

      input :encounter_status,
        title: 'Encounter status'

      run do
        fhir_search('Encounter', params: { status: encounter_status })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 驗證查詢 _id 的 Encounter resource 是否合規
    test do
      title '[GET] Encounter resource is valid'
      description %(
        Verify that the Encounter resource search by _id returned from the server is a valid FHIR resource.

        * Verifying the HTTP status code of a response.
        
        * Verifying that a string is valid JSON.
        
        * Validating a FHIR Resource.

        [臺灣核心-病人（TW Core Encounter）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Encounter-twcore.html)
      )
      # This test will use the response from the :encounter request in the
      # previous test
      uses_request :encounter

      run do
        assert_response_status(200)
        assert_resource_type('Bundle')
        assert_valid_resource
      end
    end

    # 驗證輸入的Resource是否合規
    test do 
      title '[POST] Input Encounter resource is valid'
      description %(
        Verify that the Encounter resource input is a valid FHIR resource.

        * Verifying the HTTP status code of a response.
        
        * Verifying that a string is valid JSON.
        
        * Validating a FHIR Resource.

        [臺灣核心-病人（TW Core Encounter）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Encounter-twcore.html)
      )
      input :encounter_resource,
            title: 'Encounter Resource'
      
      output :encounter_value
      
      run do 
        assert_valid_json(encounter_resource) # For safety
        resource_hash = JSON.parse(encounter_resource)
        encounter_resource = FHIR::Encounter.new(resource_hash)
        # output encounter_value: encounter_resource
        assert_valid_resource(resource: encounter_resource)
        # if resource_is_valid?(resource: encounter_resource)
        # end
      end 
    end 

    # 發送POST請求包含Resource Body給FHIR Server
    test do 
      title '[POST] Send Encounter Resource to FHIR Server'
      description %(
        Send a input Encounter resource to a FHIR server database.

        [臺灣核心-病人（TW Core Encounter）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Encounter-twcore.html)
      )

      input :encounter_resource,
            title: 'Encounter Resource'

      run do 
        resource_hash = JSON.parse(encounter_resource)
        response = fhir_create FHIR::Encounter.new(resource_hash)
        assert response.status == 201
      end
    end
  end
end
