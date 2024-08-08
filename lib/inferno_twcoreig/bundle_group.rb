module InfernoTWCoreIG
  class BundleGroup < Inferno::TestGroup
    title 'Bundle(臺灣核心-資料交換基本單位-文件&信息) Tests'
    description 'Verify that the server makes Bundle resources available'
    id :bundle_group

    group do
      id :bundle_get
      title 'Bundle GET Request'
      description 'Bundle GET Request'

      # Define inputs here to ensure the correct order
      input :url,
      title: 'FHIR Server Base Url'
        
      input :credentials,
      title: 'OAuth Credentials',
      type: :oauth_credentials,
      optional: true

      # 建議應該（SHOULD） 支援透過查詢參數 _id 查詢所有Bundle：
      test do
        title 'Server returns valid results for Bundle search by _id'
        description %(
          A server SHALL support searching by _id on the Bundle resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

          Because this is the first search of the sequence, resources in the response will be used for subsequent tests.

          Additionally, this test will check that GET and POST search methods return the same number of results. Search by POST is required by the FHIR R4 specification, and these tests interpret search by GET as a requirement of TW Core v0.2.2.

          [臺灣核心-病人（TW Core Bundle）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Bundle-twcore.html)
          )

        input :bundle_id,
          title: 'Bundle _id'

        # Named requests can be used by other tests
        makes_request :bundle

        run do
          fhir_search('Bundle', params: { _id: bundle_id }, name: :bundle)

          assert_response_status(200)
          assert_resource_type('Bundle')
        end
      end

      # 建議應該（SHOULD） 支援透過查詢參數 identifier 查詢所有Bundle：
      test do
        title 'Server returns valid results for Bundle search by identifier'
        description %(
          A server SHALL support searching by identifier on the Bundle resource. This test will pass if resources are returned and match the search criteria. If none are returned, the test is skipped.

          [臺灣核心-病人（TW Core Bundle）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Bundle-twcore.html)
          )

        input :bundle_identifier,
              title: 'Bundle identifier'

        run do
          fhir_search('Bundle', params: { 'identifier': bundle_identifier })

          assert_response_status(200)
          assert_resource_type('Bundle')
        end
      end

      # 驗證查詢 _id 的 Bundle resource 是否合規
      test do
        title 'Bundle resource is valid'
        description %(
          Verify that the Bundle resource search by _id returned from the server is a valid FHIR resource.

          * Verifying the HTTP status code of a response.
          
          * Verifying that a string is valid JSON.
          
          * Validating a FHIR Resource.

          [臺灣核心-病人（TW Core Bundle）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Bundle-twcore.html)
        )
        # This test will use the response from the :bundle request in the
        # previous test
        uses_request :bundle

        run do
          assert_response_status(200)
          assert_resource_type('Bundle')
          assert_valid_resource
        end
      end
    end

    group do 
      id :bundle_post
      title 'Bundle POST Request'
      description 'Bundle POST Request'

      # Define inputs here to ensure the correct order
      input :url,
      title: 'FHIR Server Base Url'
        
      input :credentials,
      title: 'OAuth Credentials',
      type: :oauth_credentials,
      optional: true

      # 驗證輸入的Resource是否合規
      test do 
        title 'Input Bundle resource is valid'
        description %(
          Verify that the Bundle resource input is a valid FHIR resource.

          * Verifying the HTTP status code of a response.
          
          * Verifying that a string is valid JSON.
          
          * Validating a FHIR Resource.

          [臺灣核心-病人（TW Core Bundle）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Bundle-twcore.html)
        )
        input :bundle_resource,
              title: 'Bundle Resource'
        
        output :bundle_value
        
        run do 
          assert_valid_json(bundle_resource) # For safety
          resource_hash = JSON.parse(bundle_resource)
          bundle_resource = FHIR::Bundle.new(resource_hash)
          # output bundle_value: bundle_resource
          assert_valid_resource(resource: bundle_resource)
          # if resource_is_valid?(resource: bundle_resource)
          # end
        end 
      end 

      # 發送POST請求包含Transaction Bundles(支援多個Resource驗證)的Body給FHIR Server
      test do 
        title 'Send Bundle Resource to FHIR Server'
        description %(
          Send a input Transaction Bundle(Support multiple Resource verification) to a FHIR server database.

          [臺灣核心-病人（TW Core Bundle）](https://twcore.mohw.gov.tw/ig/twcore/StructureDefinition-Bundle-twcore.html)
        )

        input :bundle_resource,
              title: 'Bundle Resource'

        run do 
          resource_hash = JSON.parse(bundle_resource)
          response = fhir_create FHIR::Bundle.new(resource_hash)
          assert response.status == 201
        end
      end
    end
  end
end
