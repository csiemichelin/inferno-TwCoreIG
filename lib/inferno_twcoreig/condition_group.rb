module InfernoTWCoreIG
  class ConditionGroup < Inferno::TestGroup
    title 'Condition(病情、問題或診斷) Tests'
    description 'Verify that the server makes Condition resources available'
    id :condition_group

    # 建議應該（SHOULD） 支援透過查詢參數 _id 查詢所有Condition：
    test do
      title '[GET] Server returns valid results for Condition search by _id'
      description %(
        A server SHALL support searching by _id on the Condition resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core Condition）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Condition-twcore.html)
        )

      input :condition_id,
        title: 'Condition _id'

      # Named requests can be used by other tests
      makes_request :condition

      run do
        fhir_search('Condition', params: { _id: condition_id }, name: :condition)

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 clinical-status 查詢所有Condition：
    test do
      title '[GET] Server returns valid results for Condition search by clinical-status'
      description %(
        A server SHALL support searching by clinical-status on the Condition resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core Condition）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Condition-twcore.html)
        )

      input :condition_clinicalStatus,
        title: 'Condition clinical-status'

      run do
        fhir_search('Condition', params: { 'clinical-status': condition_clinicalStatus })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 code 查詢所有Condition：
    test do
      title '[GET] Server returns valid results for Condition search by code'
      description %(
        A server SHALL support searching by code on the Condition resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core Condition）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Condition-twcore.html)
        )

      input :condition_code,
        title: 'Condition code'

      run do
        fhir_search('Condition', params: { code: condition_code })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 subject 查詢所有Condition：
    test do
      title '[GET] Server returns valid results for Condition search by subject'
      description %(
        A server SHALL support searching by subject on the Condition resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core Condition）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Condition-twcore.html)
        )

      input :condition_subject,
        title: 'Condition subject'

      run do
        fhir_search('Condition', params: { subject: condition_subject })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 onset-date 查詢所有Condition：
    test do
      title '[GET] Server returns valid results for Condition search by onset-date'
      description %(
        A server SHALL support searching by onset-date on the Condition resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core Condition）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Condition-twcore.html)
        )

      input :condition_onsetDate,
        title: 'Condition onset-date'

      run do
        fhir_search('Condition', params: { 'onset-date': condition_onsetDate })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 abatement-date 查詢所有Condition：
    test do
      title '[GET] Server returns valid results for Condition search by abatement-date'
      description %(
        A server SHALL support searching by abatement-date on the Condition resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core Condition）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Condition-twcore.html)
        )

      input :condition_abatementDate,
        title: 'Condition abatement-date'

      run do
        fhir_search('Condition', params: { 'abatement-date': condition_abatementDate })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 severity 查詢所有Condition：
    test do
      title '[GET] Server returns valid results for Condition search by severity'
      description %(
        A server SHALL support searching by severity on the Condition resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core Condition）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Condition-twcore.html)
        )

      input :condition_severity,
        title: 'Condition severity'

      run do
        fhir_search('Condition', params: { severity: condition_severity })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 驗證查詢 _id 的 Condition resource 是否合規
    test do
      title '[GET] Condition resource is valid'
      description %(
        Verify that the Condition resource search by _id returned from the server is a valid FHIR resource.

        * Verifying the HTTP status code of a response.
        
        * Verifying that a string is valid JSON.
        
        * Validating a FHIR Resource.

        [臺灣核心-病人（TW Core Condition）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Condition-twcore.html)
      )
      # This test will use the response from the :condition request in the
      # previous test
      uses_request :condition

      run do
        assert_response_status(200)
        assert_resource_type('Bundle')
        assert_valid_resource
      end
    end

    # 驗證輸入的Resource是否合規
    test do 
      title '[POST] Input Condition resource is valid'
      description %(
        Verify that the Condition resource input is a valid FHIR resource.

        * Verifying the HTTP status code of a response.
        
        * Verifying that a string is valid JSON.
        
        * Validating a FHIR Resource.

        [臺灣核心-病人（TW Core Condition）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Condition-twcore.html)
      )
      input :condition_resource,
            title: 'Condition Resource'
      
      output :condition_value
      
      run do 
        assert_valid_json(condition_resource) # For safety
        resource_hash = JSON.parse(condition_resource)
        condition_resource = FHIR::Condition.new(resource_hash)
        # output condition_value: condition_resource
        assert_valid_resource(resource: condition_resource)
        # if resource_is_valid?(resource: condition_resource)
        # end
      end 
    end 

    # 發送POST請求包含Resource Body給FHIR Server
    test do 
      title '[POST] Send Condition Resource to FHIR Server'
      description %(
        Send a input Condition resource to a FHIR server database.

        [臺灣核心-病人（TW Core Condition）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Condition-twcore.html)
      )

      input :condition_resource,
            title: 'Condition Resource'

      run do 
        resource_hash = JSON.parse(condition_resource)
        response = fhir_create FHIR::Condition.new(resource_hash)
        assert response.status == 201
      end
    end
  end
end
