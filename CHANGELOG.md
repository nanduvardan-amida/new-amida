## v0.9.0-rc.0

- Removal of further mentions of company names [CNSI-216] and [CNSI-217].
- Addition of `_elements` gathering to pass onto FUZE Adapter [CNSI-214]. Support for `_summary` is also there but is disabled for now because the FUZE Adapter isn't ready to accept [CNSI-215], though it can still be used against the FHIR server.
- Addition of `insurer` parameter for EOB [CNSI-224].
- Added AuditEvent logging [CNSI-127] and [CNSI-199].
- Removal of `enableMock` from environmental variables [CNSI-235].
- Support for `CapabilityStatement` available at the `/metadata` endpoint [CNSI-163].
- Support for `.well-known` at either `http://localhost:8080/fhir/.well-known/smart-configuration` or `http://localhost:8080/.well-known/smart-configuration` [CNSI-144].
- Add tests for Error Interceptor [CNSI-211].
- Added Error Interceptor for returning OperationOutcomes and AuditEvents [CNSI-211], [CNSI-223] and [CNSI-233].


## v0.8.0-rc.3

- Fix for communication mapper [PREVBX-7962].

## v0.8.0-rc.2

- Fix for communication languages code [PREVBX-7852].
- Fix for IdType instead of just Id against FUZE Adapter [PREVBX-7914].
- Fix for Patient?_id not returning [PREVBX-7927].
- Fix for Patient communication [PREVBX-7943].
- Change to the date header for outgoing requests.

## v0.8.0-rc.1

- Added `application.properties.example` file [CNSI-204].

## v0.8.0-rc.0

- Compatible with `cnsi-fhir-cognito`
  * v0.8.0
  * v0.7.0
  * v0.6.0
- Added a new subType parameter option for the ExplanationOfBenefit endpoint, and correct choose the profile type as a result [CNSI-205].
- Added client-side logging with OperationOutcome responses [CNSI-126]
- Added multiple Medicare and Medicaid Ids (comma or space seperated) for a single patient [CNSI-197].
- Added the name and patient parameter options for the RelatedPerson endpoint [CNSI-203],[CNSI-208].
- Added the payor and patient parameter options for the Coverage endpoint [CNSI-209],[CNSI-210].
- Renamed Java package names to `fhirworx` [CNSI-206].
- Renamed `application.properties` to `application.properties.example` file [CNSI-204].

## v0.7.0-rc.3

- Fix for Patient extensions from valueCodeableConcept to valueCoding [PREVBX-7795].

## v0.7.0-rc.2

- Fix for Patient extensions not appearing [PREVBX-7765].

## v0.7.0-rc.1

- Expanded accepted FUZE resource types to include CARINBB and C4BB prefixes [PREVBX-7585], e.g.
  * CARINBBExplanationOfBenefit
  * C4BBExplanationOfBenefit
  * ExplanationOfBenefit
- Accept additional date formats for `meta.trndate` [CNSI-212].
  * `<day-name>, <day> <month> <year> <hour>:<minute>:<second> <3-letter time zone>`
  * `YYYY-MM-DD'T'HH:MM:SS.SSSXXX`

## v0.7.0-rc.0

- Compatable with `cnsi-fhir-cognito`
  * v0.7.0
  * v0.6.0
- Updated all C4BB profiles from v0.1.2 to v0.1.3 [CNSI-179]
  * Updated profiles with prefix of C4BB instead of CARIN-BB [CNSI-159]
- Added new search endpoints for Explanation of Benefits [CNSI-168]
  * `patient`
  * `identifier`
  * `type`
  * `service-date`
  * `_lastUpdated`

## v0.6.0-rc.4

- Added temporary fix to the trim application property environmental variables (CNSI-198). The full fix will require more effort (CNSI-202, to be done).
- Fix for the Organization contact's address use cases (PREVBX-7116).
- Fix for Practiitoner qualification code minimum (PREVBX-7261).

## v0.6.0-rc.3
- Compatable with `cnsi-fhir-cognito v0.6.0-rc.0`
- Based on C4BB v0.3.1 (v0.1.2)
- For testing in CI (Jenkins), please remember to **update the configuration** in `src/main/resources/application.properties`.

## Added
- RelatedPerson endpoints and related jUnit tests.
- Fix for communication language version and system [PREVBX-6753].

## Changed
- Reconfiguration of scopes (`cnsi-fhir-rest v0.6.0-rc.0` is required for compatibility)
  * Valid patient resource scopes
    - `patient/*.read`
    - `patient/Contract.read`
    - `patient/Coverage.read`
    - `patient/ExplanationOfBenefit.read`
    - `patient/Patient.read`
    - `patient/RelatedPerson.read`
  * Valid user resource scopes
    - `user/*.read`
    - `user/Location.read`
    - `user/Organization.read`
    - `user/PractitionerRole.read`
    - `user/Practitioner.read`
- Updated configuration in `src/main/resources/application.properties`
  * Removed 
    - `cnsi.hostedUI`
    - `cnsi.userPool`
    - `cnsi.region`.
  * Replaced with
    - `cnsi.userInfoEndpoint`
    - `cnsi.jwksEndpoint`

## v0.6.0-rc.2
- Fix for erroring TimingDate inside of Explanation of Benefit's supporting info [PREVBX-6987].

## v0.6.0-rc.1
- Fix for erroring Location and PractitionerRole tests.

## v0.6.0-rc.0
- Support for Explanation of Benefits for Inpatient, Outpatient and Professional.
- Added fixes for PREVBX-6542 and 6753, modifying enums for Address Use and Type, Coverage Status and Contact Point System and Use.
- Added support for NDJSON logging.
- Expanded unit tests for the Ingest Mappers for Practitioner Role, Organization, Coverage, Location. Also improved Patient and Practitioner tests.
- Added code coverage tool for testing.
- Modified PatientAuthorizationInterceptor to build authorization rules against various scope inputs (CNSI-175).
- Expanded unit testing for PatientAuthorizationInterceptor.

## v0.5.0-rc.1
- Added fixes for PREVBX-5977 and PREVBX-5981.
- Added fixes for PREVBX-6068, 6067, 6066, 6146, 6145 and 6168, making 500s into 404s.
- Expanded unit tests for Practitioner and Patient.

## v0.5.0-rc.0
- Added endpoints for PractitionerRole, Organization, Coverage and Location.
- Added headers `X-Request-ID` and X-Request-Date` for end-to-end transaction logging. These are sent as request headers to the FUZE adapter for end-to-end transaction tracking.
- Added jUnit tests for null pointing exception handling and mapper essentials.
- Updated FHIR conformance to CARINBB 0.3.1.
- Updated the ingestion and mapping for CARIN-BB profiles for Patient, Practitioner, Practitioner Role, Organization, Coverage and Location, to return bundles.

The first release for SOW3 (7 July - 7 November 2020) includes support for 6 profiles:
- Patient
- Location
- Organization
- Coverage
- Practitioner
- PractitionerRole

The profiles conform to [CARINBB 0.3.1](https://build.fhir.org/ig/HL7/carin-bb/index.html#log-of-continuous-integration-build-changes) released 26 July 2020.

The following URLs are supported:
- `{root}/fhir/Coverage/<X>`
- `{root}/fhir/Coverage?_id=<X>`
- `{root}/fhir/Location/<X>`
- `{root}/fhir/Location?_id=<X>`
- `{root}/fhir/Organization/<X>`
- `{root}/fhir/Organization?_id=<X>`
- `{root}/fhir/Patient/<X>`
- `{root}/fhir/Patient?_id=<X>`
- `{root}/fhir/Practitioner/<X>`
- `{root}/fhir/Practitioner?_id=<X>`
- `{root}/fhir/PractitionerRole/<X>`
- `{root}/fhir/PractitionerRole?_id=<X>`

Following FHIR convention, `{root}/fhir/Coverage/<X>` will return an individual resource, while `{root}/fhir/Coverage?_id=<X>` will return a bundle contaning a single entry (`_id` should be unique).

`_id` is the only search parameter supported on the base resource.
For example, `{root}/fhir/Coverage?_lastUpdated=gt2015-01-01`, is currently unsupported.

## v0.4.6-demo-20200427
- Added documentation, including `CHANGELOG.md` and architecture diagram.

## v0.4.5-demo-20200427
- Added logging environmental variable and instructions for how to modify inside of README.md.
- Changed `medicaidId` and `medicareId` variable names to the environmental variables in case the custom attributes are changed.
- Fixed Practitioner endpoint using `patientId=1` instead of the embedded `medicaidId`.

## v0.4.4-demo-20200424
- Changed swagger documentation and implementation for end-point for `/ExplanationOfBenefit/{eobId}`.

## v0.4.3-demo-20200424
- Added check to allow single objects or arrays for the Performer list in `ProcedureIngest.java class`.
- Added endpoint for `ExplanationOfBenefit/{eobId}`.
- Updated README.md with new endpoints and FUZE adapter calls.
- Updated swagger specifications.

## v0.4.1-demo-20200423
- Fixed incorrect access to `medicaidId` at Patient endpoint.

## v0.4.0-demo-20200423
- Added logging statements per each call to the FUZE Adapter.
- Added tying of the root compartments to the embedded `medicaidId`.
- Changed query parameter defaults.
  * `identifier` default is `Medicaid`
  * `patientId` default is `medicaidId`

## v0.3.0-demo-20200421
- Added ingestion and mapping for resourceType
  * ExplanationOfBenefit
  * Practitioner
  * Procedures
- Added authorization improvement to fetch `medicareId` and `medicaidId` from Cognito `/userInfo`.
- Added environmental variables.
- Fixed date parameters.

## v0.2.0-demo-20200421
- Initial release for resourceTypes.
  * Condition
  * Patient
  * Practitioner
