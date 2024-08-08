require_relative 'inferno_twcoreig/allergyIntolerance_group'
require_relative 'inferno_twcoreig/bundle_group'
require_relative 'inferno_twcoreig/composition_group'
require_relative 'inferno_twcoreig/condition_group'
require_relative 'inferno_twcoreig/diagnosticReport_group'
require_relative 'inferno_twcoreig/documentReference_group'
require_relative 'inferno_twcoreig/encounter_group'
require_relative 'inferno_twcoreig/imagingStudy_group'
require_relative 'inferno_twcoreig/location_group'
require_relative 'inferno_twcoreig/media_group'
require_relative 'inferno_twcoreig/medication_group'
require_relative 'inferno_twcoreig/medicationDispense_group'
require_relative 'inferno_twcoreig/medicationRequest_group'
require_relative 'inferno_twcoreig/medicationStatement_group'
require_relative 'inferno_twcoreig/messageHeader_group'
require_relative 'inferno_twcoreig/observation_group'
require_relative 'inferno_twcoreig/organization_group'
require_relative 'inferno_twcoreig/patient_group'
require_relative 'inferno_twcoreig/practitioner_group'
require_relative 'inferno_twcoreig/practitionerRole_group'
require_relative 'inferno_twcoreig/procedure_group'
require_relative 'inferno_twcoreig/specimen_group'

module InfernoTWCoreIG
  class Suite < Inferno::TestSuite
    id :inferno_twcoreig_test_suite
    title 'TW Core v0.2.2'
    description 'TW Core FHIR API'

    # These inputs will be available to all tests in this suite
    input :url,
          title: 'FHIR Server Base Url'

    input :credentials,
          title: 'OAuth Credentials',
          type: :oauth_credentials,
          optional: true

    # All FHIR requests in this suite will use this FHIR client
    fhir_client do
      url :url
      oauth_credentials :credentials
    end

    # All FHIR validation requsets will use this FHIR validator
    fhir_resource_validator do
      # igs 'identifier#version' # Use this method for published IGs/versions
      igs 'igs/package.tgz'   # Use this otherwise

      exclude_message do |message|
        message.message.match?(/\A\S+: \S+: URL value '.*' does not resolve/)
      end
    end

    group do
      id :tw_core_fhir_api
      title 'TW Core FHIR API'
      description 'Group containing all TW Core FHIR API tests'

      # These inputs will be available to all tests in this suite
      # input :url,
      # title: 'FHIR Server Base Url'

      # input :credentials,
      # title: 'OAuth Credentials',
      # type: :oauth_credentials,
      # optional: true

      # # All FHIR requests in this suite will use this FHIR client
      # fhir_client do
      # url :url
      # oauth_credentials :credentials
      # end

      # Tests and TestGroups can be defined inline
      group do
        id :capability_statement
        title 'Capability Statement'
        description 'Verify that the server has a CapabilityStatement'

        test do
          id :capability_statement_read
          title 'Read CapabilityStatement'
          description 'Read CapabilityStatement from /metadata endpoint'

          run do
            fhir_get_capability_statement

            assert_response_status(200)
            assert_resource_type(:capability_statement)
          end
        end
      end

      # Tests and TestGroups can be written in separate files and then included
      # using their id
      group from: :allergyIntolerance_group
      group from: :bundle_group
      group from: :composition_group
      group from: :condition_group
      group from: :diagnosticReport_group
      group from: :documentReference_group
      group from: :encounter_group
      group from: :imagingStudy_group
      group from: :location_group
      group from: :media_group
      group from: :medication_group
      group from: :medicationDispense_group
      group from: :medicationRequest_group
      group from: :medicationStatement_group
      group from: :messageHeader_group
      group from: :observation_group
      group from: :organization_group
      group from: :patient_group
      group from: :practitioner_group
      group from: :practitionerRole_group
      group from: :procedure_group
      group from: :specimen_group
    end
  end
end
