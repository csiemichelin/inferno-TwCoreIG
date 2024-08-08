module InfernoTWCoreIG
  class DocumentReferenceGroup < Inferno::TestGroup
    title 'DocumentReference(文件參照) Tests'
    description 'Verify that the server makes DocumentReference resources available'
    id :documentReference_group

    # 建議應該（SHOULD） 支援透過查詢參數 _id 查詢所有DocumentReference：
    test do
      title '[GET] Server returns valid results for DocumentReference search by _id'
      description %(
        A server SHALL support searching by _id on the DocumentReference resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core DocumentReference）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-DocumentReference-twcore.html)
        )

      input :documentReference_id,
        title: 'DocumentReference _id'

      # Named requests can be used by other tests
      makes_request :documentReference

      run do
        fhir_search('DocumentReference', params: { _id: documentReference_id }, name: :documentReference)

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 status 查詢所有DocumentReference：
    test do
      title '[GET] Server returns valid results for DocumentReference search by status'
      description %(
        A server SHALL support searching by status on the DocumentReference resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core DocumentReference）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-DocumentReference-twcore.html)
        )

      input :documentReference_status,
        title: 'DocumentReference status'

      run do
        fhir_search('DocumentReference', params: { 'status': documentReference_status })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 建議應該（SHOULD） 支援透過查詢參數 subject 查詢所有DocumentReference：
    test do
      title '[GET] Server returns valid results for DocumentReference search by subject'
      description %(
        A server SHALL support searching by subject on the DocumentReference resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

        Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

        Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

        [臺灣核心-病人（TW Core DocumentReference）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-DocumentReference-twcore.html)
        )

      input :documentReference_subject,
        title: 'DocumentReference subject'

      run do
        fhir_search('DocumentReference', params: { subject: documentReference_subject })

        assert_response_status(200)
        assert_resource_type('Bundle')
      end
    end

    # 驗證查詢 _id 的 DocumentReference resource 是否合規
    test do
      title '[GET] DocumentReference resource is valid'
      description %(
        Verify that the DocumentReference resource search by _id returned from the server is a valid FHIR resource.

        * Verifying the HTTP status code of a response.
        
        * Verifying that a string is valid JSON.
        
        * Validating a FHIR Resource.

        [臺灣核心-病人（TW Core DocumentReference）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-DocumentReference-twcore.html)
      )
      # This test will use the response from the :documentReference request in the
      # previous test
      uses_request :documentReference

      run do
        assert_response_status(200)
        assert_resource_type('Bundle')
        assert_valid_resource
      end
    end

    # 驗證輸入的Resource是否合規
    test do 
      title '[POST] Input DocumentReference resource is valid'
      description %(
        Verify that the DocumentReference resource input is a valid FHIR resource.

        * Verifying the HTTP status code of a response.
        
        * Verifying that a string is valid JSON.
        
        * Validating a FHIR Resource.

        [臺灣核心-病人（TW Core DocumentReference）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-DocumentReference-twcore.html)
      )
      input :documentReference_resource,
            title: 'DocumentReference Resource'
      
      output :documentReference_value
      
      run do 
        assert_valid_json(documentReference_resource) # For safety
        resource_hash = JSON.parse(documentReference_resource)
        documentReference_resource = FHIR::DocumentReference.new(resource_hash)
        # output documentReference_value: documentReference_resource
        assert_valid_resource(resource: documentReference_resource)
        # if resource_is_valid?(resource: documentReference_resource)
        # end
      end 
    end 

    # 發送POST請求包含Resource Body給FHIR Server
    test do 
      title '[POST] Send DocumentReference Resource to FHIR Server'
      description %(
        Send a input DocumentReference resource to a FHIR server database.

        [臺灣核心-病人（TW Core DocumentReference）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-DocumentReference-twcore.html)
      )

      input :documentReference_resource,
            title: 'DocumentReference Resource'

      run do 
        resource_hash = JSON.parse(documentReference_resource)
        response = fhir_create FHIR::DocumentReference.new(resource_hash)
        assert response.status == 201
      end
    end
  end
end
