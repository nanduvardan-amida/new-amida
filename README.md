# cnsi-fhir-rest

![](images/CNSI_diagram_FHIR_Server.png)

## Compatibility
| Software repository | Compatable versions |
|------------|---------------------|
| cnsi-fhir-cognito | v0.8.0, v0.7.0, v0.6.0 |
| FUZE Adapter      | ? Unknown ? |

| Implementation Guide | Compatable versions |
|------------|---------------------|
| C4BB | v0.1.3 |
| US Core | v3.1.1 |
| FHIR | R4 |

## Quickstart

### Docker
To build, run `docker build -t cnsi-fhir-rest .`

Run without auth, using built-in mock
```
> docker run -p 8080:8080 -e fhirworx.enableRest=false -e fhirworx.enableAuth=false cnsi-fhir-rest
> curl http://localhost:8080/fhir/Patient/1?_format=json
```

Run without auth, using `cnsi-mock-fuze-adapter`
1. Run `cnsi-mock-fuze-adapter`
2. `docker run -p 8080:8080 -e fhirworx.enableAuth=false -e fhirworx.dataEndpoint=<http://endpoint plus port> cnsi-fhir-rest`
  - If running `cnsi-mock-fuze-adapter` with docker, we recommend following the docker-compose instructions.
  - Using a `localhost` address for `fhirworx.dataEndpoint` running in docker will not work without additional configuration.
3. `curl http://localhost:8080/fhir/Patient/1?_format=json`

Run with auth (AWS Cognito), with `cnsi-mock-fuze-adapter`
1. Update the configuration file (`src/main/resources/application.properties`) and/or environmental variables
2. `docker run -p 8080:8080 -e fhirworx.dataEndpoint=<http://endpoint plus port> cnsi-fhir-rest`
  - If running `cnsi-mock-fuze-adapter` with docker, we recommend following the docker-compose instructions.
  - Using a `localhost` address for `fhirworx.dataEndpoint` running in docker will not work without additional configuration.
3. Request an `access_token`
4. `curl -H 'Authorization Bearer <access_token>' http://localhost:8080/fhir/Patient/1?_format=json`

### Docker Compose
For convenience, we define a docker-compose file including both `cnsi-fhir-rest` and `cnsi-mock-fuze-adapter`.

```
> docker login docker.io
> docker network create fhirworx
> docker-compose -f docker-compose.dev.yml up
>
```

Test the mock
```
> curl http://localhost:8081/fuzeResourceAdapter/patient/1?payerType=Medicare
```

Test the FHIR resource server, without auth
```
> curl http://localhost:8080/fhir/Patient/40?_format=json
```

Test the FHIR resource server, with auth (AWS Cognito)
1. Ensure the docker-compose configuration has been updated for use with your AWS Cognito server:
  - `fhirworx.userInfoEndpoint`
  - `fhirworx.enableAuth=True`
2. Get an `access_token` and `id_token` from AWS Cognito, e.g. via Postman.
3. Verify that the claim exists
  - Option: `id_token`
  - Option: `oauth2/userInfo` end-point
4. Request against `cnsi-fhir-rest` using the `access_token`.
  - `<patient_id>` must match the `custom:medicaid_state_id`; otherwise, the request will be rejected because the user only has access to their resources.
  - `<access_token>`, which has a one hour expiry, must be valid.
  ```
  > curl --location --request GET 'http://localhost:8080/fhir/Patient/<patient_id>?_format=json' --header 'Authorization: Bearer <access_token>'
  ```

## Environmental Variables
A complete list of variables is available in the configuration file, `src/main/resources/application.properties.examples`.

### Server side
| Parameter | Default | Description |
|-----------|---------|------|
| `application.name` | `FHIRWorx Server` | Changes the application name. Required. Maybe going away later to pull from the Gradle Build file. |
| `application.version` | `v0.9.0` | For displaying the application version. Required. Maybe going away later to pull from the Gradle Build file. |
| `server.port` | 8080 | Changes the port that the spring server deploys to. Can also be mapped by using the `-p` variable in Docker (ie `-p 8081:8080` and then going to `http://localhost:8081/fhir/Patient/1?_format=json`). |
| `logging.level.root` | info | Determines logging level. |
| `logging.level.com.fhirworx.fhir` | INFO | Change to reflect various levels of logging across the FHIRWorx package. Valid options are: TRACE, DEBUG, INFO, WARNING, ERROR, FATAL. Note that `logging.level.<package>` is a universal environmental variable, and specifying other packages or even `logging.level.org.springframework` as a whole is possible to reduce verbosity. |
| `logging.auditEventPrettyPrint` | false | Boolean variable. A variable for turning on/off the audit event pretty printing. |
| `spring.profiles.active` | prod | "prod" returns NDJSON log statements and "dev" just strings. |

### Integration with AWS Cognito
| Parameter | Default | Description |
|-----------|---------|------|
| `fhirworx.jwksEndpoint` | No default. Must be set. | The AWS Cognito endpoint of the well known JSON for the Cognito user pool. Format: `https://<domainPrefix>.us-west-2.amazonaws.com/<UserPoolId>/.well-known/jwks.json` |
| `fhirworx.userInfoEndpoint` | No default. Must be set. | The AWS Cognito endpoint for userInfo. Format: `https://<domainPrefix>.auth.us-west-2.amazoncognito.com/oauth2/userInfo` Custom Domains are also supported. |
| `fhirworx.medicaidId` | `custom:medicaid_state_id` | The name of the custom attribute for the Medicaid ID to be pulled from OpenID. |
| `fhirworx.medicareId` | `custom:medicare_bene_id` | The name of the custom attribute for the Medicare ID to be pulled from OpenID. |

### Integration with FUZE Adapter
| Parameter | Default | Description |
|-----------|---------|------|
| `fhirworx.dataEndpoint` | `http://localhost:8081/fuzeResourceAdapter` (our mock instance) | The endpoint for the FUZE Resource Adapter. |
| `fhirworx.enableRest` | true | Boolean variable. If enabled, will _actually_ attempt calls the `fhirworx.dataEndpoint` when resources are requested. |
| `fhirworx.coverageEndpoint` | /Coverage | Changes the endpoint called for coverage, assembled with `fhirworx.dataEndpoint`. |
| `fhirworx.eobEndpoint` | /ExplanationOfBenefit | Changes the endpoint called for explanations of benefit, assembled with `fhirworx.dataEndpoint`. |
| `fhirworx.locationEndpoint` | /Location | Changes the endpoint called for location, assembled with `fhirworx.dataEndpoint`. |
| `fhirworx.organizationEndpoint` | /Organization | Changes the endpoint called for organization, assembled with `fhirworx.dataEndpoint`. |
| `fhirworx.patientEndpoint` | /Patient | Changes the endpoint called for patients, assembled with `fhirworx.dataEndpoint`. |
| `fhirworx.practitionerEndpoint` | /Practitioner | Changes the endpoint called for practitioner, assembled with `fhirworx.dataEndpoint`. |
| `fhirworx.practitionerRoleEndpoint` | /PractitionerRole | Changes the endpoint called for practitioner role, assembled with `fhirworx.dataEndpoint`. |
| `fhirworx.relatedPersonEndpoint` | /RelatedPerson | Changes the endpoint called for related person, assembled with `fhirworx.dataEndpoint`. |
| `fhirworx.memberIdSystem` | `fhirworx:example:xx.xx.xx` | Sets the Member Id System if none is provided. Will likely be removed in future version since this data is provided by CNSI. |
| `fhirworx.authorizationCode` | No default. Must be set. | Sets the authorization code for calls to the FUZE Adapter. |

### Development and demo purposes
| Parameter | Default | Description |
|-----------|---------|------|
| `fhirworx.enableRest` | true | Boolean variable. A variable for turning on/off outgoing calls. Currently enabled but likely to either be used or removed next version. |
| `fhirworx.enableAuth` | true | Boolean variable. A variable for turning on/off authentication. Enabled by default for production use. |
| `fhirworx.enableSearchNarrowing` | true | Boolean variable. A variable for turning on/off injection of compartment specific variables into any request. Enabled by default for production use. |
| `fhirworx.enableDebugMode` | false | Boolean variable. A variable for turning on/off debug mode for testing or development. Disabled by default for production use. |

### Well known purposes
| Parameter | Default | Description |
|-----------|---------|------|
| `fhirworx.wellknown.authorizationEndpoint` | No default. Must be set. | The AWS Cognito endpoint for the .well-known and Capabilities Statement endpoints for authorization. Format: `https://<domainPrefix>.auth.<region>.amazoncognito.com/oauth2/authorize` Custom Domains are also supported. |
| `fhirworx.wellknown.tokenEndpoint` | No default. Must be set. | The AWS Cognito endpoint for the .well-known and Capabilities Statement endpoints for tokens. Format: `https://<domainPrefix>.auth.<region>.amazoncognito.com/oauth2/token` Custom Domains are also supported. |
| `fhirworx.wellknown.tokenEndpointAuthMethods` | `client_secret_post client_secret_basic` | A variable for indicating valid auth methods. |
| `fhirworx.wellknown.registrationEndpoint` | No default. Optional. | A variable for indicating the registration endpoint. |
| `fhirworx.wellknown.scopesSupported` | `patient/*.read patient/Patient.read patient/ExplanationOfBenefit.read patient/Coverage.read patient/Contract.read patient/RelatedPerson.read user/*.read user/Location.read user/Organization.read user/Practitioner.read user/PractitionerRole.read openid profile` | A variable for indicating the accepted scopes. |
| `fhirworx.wellknown.responseTypesSupported` | `code token` | A variable for indicating accepted response types. |
| `fhirworx.wellknown.managementEndpoint` | No default. Optional. | A variable for indicating the management endpoint. |
| `fhirworx.wellknown.introspectionEndpoint` | No default. Optional. | A variable for indicating the introspection endpoint. |
| `fhirworx.wellknown.revocationEndpoint` | No default. Optional. | A variable for indicating the revocation endpoint. |
| `fhirworx.wellknown.capabilities` | `client-public client-confidential-symmetric sso-openid-connect` | A variable for indicating the capabilities. |

## Supported Resources
We support the C4BB implementation guide, [v0.1.3](https://build.fhir.org/ig/HL7/carin-bb/branches/v0.1.3/) generated 15 September 2020.

### Supported SMART on FHIR Scopes
Resource Scopes follow the format:
```
clinical-scope ::= ( 'patient' | 'user' ) '/' ( fhir-resource | '*' ) '.' ( 'read' | 'write' | '*' )`
```

We support the following [Patient-specific scopes](http://hl7.org/fhir/smart-app-launch/scopes-and-launch-context/index.html#patient-specific-scopes):
| ScopeName                           | ScopeDescription                                              |
|-------------------------------------|---------------------------------------------------------------|
| `patient/*.read`                    | Wildcard read scope for all `patient/` scopes |
| `patient/Coverage.read`             | Read coverage details |
| `patient/ExplanationOfBenefit.read` | Read explanation of benefits |
| `patient/Patient.read`              | Read patient demographics |
| `patient/RelatedPerson.read`        | Read related person details |
| `user/*.read`                       | Wildcard read scope for all `user/` scopes |
| `user/Location.read`                | Read location details |
| `user/Organization.read`            | Read organization details |
| `user/Practitioner.read`            | Read practitioner details |
| `user/PractitionerRole.read`        | Read practitioner role details |

## Supported Search Parameters
| Resource | IG version | Supported search parameters |
|----------|---------|-----------------------------|
| Coverage | C4BB v0.1.3 | `<id>`, `_id`, `payor`, `patient` |
| ExplanationOfBenefit (Inpatient, Outpatient, Pharmacy, Professional) | C4BB v0.1.3 | `<id>`, `_id`, `identifier`, `patient`, `type`, `service-date`, `_lastUpdated` |
| Location | US Core (v3.1.1) | `<id>`, `_id` |
| Organization | C4BB v0.1.3 | `<id>`, `_id` |
| Patient | C4BB v0.1.3 | `<id>`, `_id`, `identifier`, `patient` |
| Practitioner | C4BB v0.1.3 | `<id>`, `_id` |
| PractitionerRole | US Core (v3.1.1) | `<id>`, `_id` |
| RelatedPerson | R4 | `<id>`, `_id`, `name`, `patient` |

## Request headers
### Integration with 3rd-party applications
The FHIR server expects the following requests headers in calls from 3rd-party applications (FHIR clients)

`Header: Authorization`
The header format is `Authorization: Bearer <jwt access token>`, where `<jwt access token>` is issued by the Cognito Authorization Server following the SMART on FHIR specification.

For example, a decoded jwt payload:
```
{
  "auth_time": 1594920428,
  "client_id": "79fsdevkbllev29lu8e65mnq5c",
  "exp": 1594924028,
  "iat": 1594920428,
  "iss": "https://cognito-idp.us-west-2.amazonaws.com/us-west-2_XcKD8PkhP",
  "jti": "22f10642-3b18-4bd8-ad38-dc8ae4442880",
  "scope": "patient/*.read",
  "sub": "ed1ce57a-4573-40f9-b901-464525bdf5cb",
  "token_use": "access",
  "username": "demo-user-001"
  "version": 2,
}
```

### Integration with the FUZE Adapter
The FHIR resource server sets several request headers when calling the FUZE Adapter.

`Header: Authorization`
If the environmental variable `fhirworx.authorizationCode` is set, we set the header `Authorization: Bearer <fhirworx.authorizationCode>` in requests to the FUZE Adapter.

`Header: X-Request-ID`
Used for end-to-end transaction logging, this request header is set by the FHIR resource server on requests to the FUZE Adapter. 

The ID format follows the pattern of `carin-bb-<resource type>-`<UUID>`.

If the header is set, the FUZE adapter would respond with the given values, e.g.:
```
  "bundleMeta": {
    "trnID": "carin-bb-coverage-d8741f78-1671-4136-a6b5-11b042d83992",
    "trnDate": "2020-07-27T22:10:12.148-05:00"
  }
```

`Header: Date`

Used for end-to-end transaction logging, this request header is set by the FHIR resource server on requests to the FUZE Adapter. 

Format: <day-name>, <day> <month> <year> <hour>:<minute>:<second> GMT

Example: Thu, 01 Oct 2020 03:27:58 GMT

See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Date

If the `X-Request-ID` and `Date` headers are not set, the FUZE Adapter will respond with blank values:
```
  "bundleMeta": {
    "trnID": "",
    "trnDate": ""
  }
```

## Logging Error Handling
### OperationOutcome (Added in v0.8.0)
The FHIR resource `OperationOutcome` are used for client-facing error logging.

The server contains an `ErrorHandlingInterceptor` that extends HAPI FHIR's built in `ExceptionHandlingInterceptor`.
The `ErrorHandlingInterceptor` is used to customize what is returned to the client and what is logged when the server throws an exception for any reason. 
By default, HAPI will automatically generate an OperationOutcome which contains details about the exception that was thrown. We use the `ErrorHandlingInterceptor` to catch the failures and override the content of the OperationOutcome within the exception to match the correct `IssueType` code corresponding to the failure.

#### Supported Errors
| HTTP status code | Description | 
|------------------|-------------|
| `HTTP 401 Unauthorized` | This error is triggered by using an expired JWT token or having a wrong authorization header. |
| `HTTP 403 Forbidden` | This error is triggered by attempting to access a Resource outside a given scope. |
| `HTTP 404 Resource Not Found` | This error is returned when the FUZE response is a `HTTP 404` error. |
| `HTTP 500 Internal Error` | This error is triggered by any handled internal error. For example, a parsing error such as entering a malformed string for `fhirworx.userInfoEndpoint` in `application.properties`. In addition, you can get this exception when the FUZE response is `HTTP 400 Bad Request`, `HTTP 408 Request Timeout`, or `HTTP 500 Internal Error `. |

#### Example
The following is an example of an OperationOutcome that is returned to the client when an authorization failure occurs.
```
{
    "resourceType": "OperationOutcome",
    "issue": [
        {
            "severity": "error",
            "code": "security",
            "diagnostics": "Unauthorized: Missing Authorization or invalid header value."
        }
    ]
}
``` 

#### Enable Debug Mode
When the `fhirworx.enableDebugMode` is set to `true`, the exception stack trace will be returned to the user as part of the diagnostics of an `OperationOutCome` upon any of the supported errors. For production, the `fhirworx.enableDebugMode` is set to `false`.

### AuditEvent (Added in v0.9.0)
The FHIR resource `AuditEvent` are used for server-facing logging.

An AuditEvent is produced for all logs, even logs that are not strictly auditable events. This means that an AuditEvent is also created for operational logs (i.e. server starting logs). The application logger's layout was customized to achieve this.

The server contains `AuditEventConsentService` that implements HAPI FHIR's built in `IConsentService`. The `AuditEventConsentService` is used to examine client requests to create audit trail events. 

#### Supported AuditEvent Types
Code System: `http://dicom.nema.org/resources/ontology/DCM`
| Code | Display | Description |
|------------------|------------------|------------------|
| `110100` | Application Activity | Audit event: Application Activity has taken place. |
| `110101` | Audit Log Used |	Audit event: Audit Log has been used. |
| `110110` | Patient Record | 	Audit event: Patient Record has been created, read, updated, or deleted. |
| `110111` | Procedure Record | Audit event: Procedure Record has been created, read, updated, or deleted. |
| `110112` | Query | Audit event: Query has been made. |
| `110114` | User Authentication | 	Audit event: User Authentication has been attempted. |
| `110113` | Security Alert | Audit event: Security Alert has been raised. |

#### Supported AuditEvent Actions
Code System: `http://hl7.org/fhir/audit-event-action`
| Code | Display | Definition |
|------------------|------------------|------------------|
| `C`	| Create | Create a new database object, such as placing an order. |
| `R` |	Read/View/Print | Display or print data, such as a doctor census. |
| `U` | Update | Update data, such as revise patient information. |
| `D`	| Delete | Delete items, such as a doctor master file record. |
| `E`	| Execute | Perform a system or application function such as log-on, program execution or use of an object's method, or perform a query/search operation. |
 
 #### Supported AuditEvent Outcomes
 Code System: `http://hl7.org/fhir/audit-event-outcome`
Code | Display | Definition |
|------------------|------------------|------------------|
| `0`	| Success | The operation completed successfully (whether with warnings or not). |
| `4` | Minor failure | The action was not successful due to some kind of minor failure (often equivalent to an HTTP 400 response). |
| `8` | Serious failure | The action was not successful due to some kind of unexpected error (often equivalent to an HTTP 500 response). |
| `12` | Major failure | An error of such magnitude occurred that the system is no longer available for use (i.e. the system died). |

#### Example
The following is an example of an AuditEvent that is logged in the server when a request for `Patient` is made and succeeds.
```
{
  "resourceType": "AuditEvent",
  "contained": [ {
    "resourceType": "Device",
    "id": "1",
    "deviceName": [ {
      "name": "FHIRWorx Server",
      "type": "user-friendly-name"
    } ],
    "version": [ {
      "value": "v0.9.0"
    } ]
  } ],
  "type": {
    "system": "http://dicom.nema.org/resources/ontology/DCM",
    "code": "110110",
    "display": "Patient Record"
  },
  "action": "R",
  "recorded": "2020-10-22T11:21:08.128-04:00",
  "outcome": "0",
  "outcomeDesc": "Operation Was Successful",
  "agent": [ {
    "requestor": true,
    "network": {
      "address": "0:0:0:0:0:0:0:1",
      "type": "2"
    }
  } ],
  "source": {
    "observer": {
      "reference": "#1"
    },
    "type": [ {
      "system": "http://terminology.hl7.org/CodeSystem/security-source-type",
      "code": "3",
      "display": "Web Server"
    } ]
  },
  "entity": [ {
    "what": {
      "type": "Patient"
    },
    "query": "X2Zvcm1hdD1qc29u",
    "detail": [ {
      "type": "RequestedURL",
      "valueString": "http://localhost:8080/fhir/Patient?_format=json"
    } ]
  } ]
}
```

### Fuze Error Handling (Added in v0.9.0)
When the fuze adapter sends back an error, the error is mapped to specific OperationOutcome. This OperationOutcome is sent to the client. In order to determine an appropriate OperationOutcome to send, the Fuze's `resource.errorCode` field is used.

#### Supported Fuze Errors
| Code | Description |
|--|--|
| 1000 | Authorization code is missing/empty in `Header: Authorization <code>` |
| 1001 | No Data found |
| 1002 | System Exception |
| 1003 | Transaction ID is mandatory |
| 1004 | Transaction Date is mandatory |
| 1005 | Transaction Date is Invalid |
| 1006 | Claim Type Code is not matching with FHIR Value Set |
| 1007 | Claim Type Code is Missing |
| 1008 | Claim Type Code is Invalid |
| 1009 | Reference Object is Missing |
| 1010 | Reference Object is Invalid |
| 1011 | Reference Object is not matching FHIR Standards |
| 1012 | Authorization code mismatch |
| 1013 | Request Timeout |
| 1014 | Search Param is Invalid |

#### Server Name and Version
- Set the server name through `application.name`.
- Set the server version through `application.version`. This is typically set to the current release.

#### Enable AuditEvent Pretty Printing 
When the `logging.auditEventPrettyPrint` is set to `true`, the AuditEvent logs are pretty printed.


## Development
The repo is structured as 2 applications:
- root folder is the main application.
- `testServer` is a basic rest server with 2 endpoints to create a quick way to test rest endpoints

To start the test server (You don't need the Java home directory variable if your current version is 8):
```
cd testServer
./gradlew bootrun -Dorg.gradle.java.home="C:/Program Files/Java/OpenJDK-8"
```

To start the main server (from the root folder)
```
./gradle bootrun -Dorg.gradle.java.home="../Java/OpenJDK-8"
```

To debug:
```
./gradle bootrun --debug-jvm -Dorg.gradle.java.home="../Java/OpenJDK-8"
```

To clean and rebuild:
```
./gradlew clean build -Dorg.gradle.java.home="../Java/OpenJDK-8"
```

Both need to be running to test the Patient endpoint unless you set `Server.giveItARest` to false

### Unit Testing / Testing Coverage Report
To run the JUnit tests:
```
./gradlew clean test
```

**Note:** This command also generates a unit test coverage report:
```
${buildDir}/reports/jacoco/test/html/index.html
```
This is an interactive coverage report. Make sure to open it in a browser.

## Sections
### Main
#### Server.java
For the main application, you generally do not need to do anything here.

The following flag is used to toggle test code:
- `enableRest` will toggle whether to use restful calls in `PatientServiceImpl`

#### HapiRestServlet
The servlet that acutally handles the FHIR endpoints. the path for FHIR is set here. Generally this should not need to be altered.

### Providers
The com.fhirworx.fhir.providers package defines what FHIR rest endpoints are available. This will need to be set up to provide the various endpoints and queries needed.
- https://hapifhir.io/hapi-fhir/docs/server_plain/resource_providers.html describes their configuration.
- For Search Operations: https://hapifhir.io/hapi-fhir/docs/server_plain/rest_operations_search.html

### Services
The com.fhirworx.fhir.providers package defines what FHIR services are available. Services is where you will retrieve the records to present. I would recommend having the service generate the FHIR objects and the providers just serve them and in the case of includes, merge the base records and the includes together.

the impl is package is where actual implementations of services are. PatientServiceImpl gives an example of using a rest service to retrieve resources. This is where the majority of the work will be done.

### Models
The com.fhirworx.fhir.models package defines the models being retrieved using restful calls. I set up PatientModel with 2 static final functions to convert the PatientModel to a FHIR Patient object. You do not have to do it this way but it has the benefit of grouping the conversion to FHIR with the particular model in question.

## Examples
Root compartment searches (the first one of each list) will return everything for that compartment (Patient, Procedure, EOB, etc) for both Medicaid and Medicare. If the patient's id is specified, it returns results based on the identifier if provided (and CNSI-FHIR-REST defaults to Medicaid if none is provided). Since we have access to the MedicareId when CNSI-FHIR-REST is in authentication mode, we can pass it along in a future build. But for simplicity's sake for the demo, I've left it as is for now.

Using EOB with `_id` requires specifying the patient as well due to the fact that _id seems to create ambiguity regarding what id is being referenced.

If you are using this with authentication mode turn off, the embedded `MedicaidId` will be 30, which is used in calls to the FUZE Adapter.

### Patients
http://localhost:8080/fhir/Patient?_format=json
- Uses the embedded MedicaidId to get a bundle of Medicaid and Medicare records for the given user. The real FUZE Adapter may not support this.
- Calls: http://localhost:8081/fuzeResourceAdapter/patient/30

http://localhost:8080/fhir/Patient/30?_format=json
- Returns a single Patient record of combined Medicare and Medicaid info for that patient. In a production environment, the FUZE Adapter will have to return an array of both the Medicare and Medicaid record.
- Calls: http://localhost:8081/fuzeResourceAdapter/patient/30

http://localhost:8080/fhir/Patient?_id=30&_format=json
- Returns a bundle of just the Medicaid data, Medicaid being default.
- Calls: http://localhost:8081/fuzeResourceAdapter/patient/30?payerType=Medicaid

http://localhost:8080/fhir/Patient?identifier=Medicare&_format=json
- Uses the embedded MedicaidId to return a bundle of just Medicare records for that patient.
- Calls: http://localhost:8081/fuzeResourceAdapter/patient/30?payerType=Medicare

http://localhost:8080/fhir/Patient?identifier=Medicaid&_format=json
- Uses the embedded MedicaidId to return a bundle of just Medicaid records for that patient.
- Calls: http://localhost:8081/fuzeResourceAdapter/patient/30?payerType=Medicaid

http://localhost:8080/fhir/Patient?_id=30&identifier=Medicare&_format=json
- Returns a bundle of just the Medicare data.
- Calls: http://localhost:8081/fuzeResourceAdapter/patient/30?payerType=Medicare

http://localhost:8080/fhir/Patient?_id=30&_elements=identifier&_format=json
- Returns a patient bundle whose entries are limited to just the meta and identifier fields. 
- Calls: "http://localhost:8081/fuzeResourceAdapter/patient/30?_elements=identifier"

### Practitioner
Because FHIR Practitioner cannot use date, the code will automatically set a wide range for the start date (first date of 1900) and end date (today) until the Provider endpoint for the fuzeResourceAdapter is changed to no longer use this.

http://localhost:8080/fhir/Practitioner?_format=json
- Returns all the Practitioners associated with this patient by passing the embedded MedicaidId to the FUZE Adapter.
- Calls: http://localhost:8081/fuzeResourceAdapter/provider?patientId=30&startDate=1900-01-01&endDate=2020-04-27

http://localhost:8080/fhir/Practitioner/1?_format=json
- Returns a single FHIR object particular Practitioner by passing the embedded MedicaidId to the FUZE Adapter. Not exactly working correctly until Practitioner's have high level Ids.
- Calls: http://localhost:8081/fuzeResourceAdapter/provider?patientId=30&startDate=1900-01-01&endDate=2020-04-23

http://localhost:8080/fhir/Practitioner?identifier=Medicare&_format=json
- Returns the Medicare-associated Practitioners for this patient by passing the embedded MedicaidId to the FUZE Adapter.
- Calls: http://localhost:8081/fuzeResourceAdapter/provider?patientId=30&payerType=Medicare&startDate=1900-01-01&endDate=2020-04-27

http://localhost:8080/fhir/Practitioner?identifier=Medicaid&_format=json
- Returns the Medicaid-associated Practitioners for this patient by passing the embedded MedicaidId to the FUZE Adapter.
- Calls: http://localhost:8081/fuzeResourceAdapter/provider?patientId=30&payerType=Medicaid&startDate=1900-01-01&endDate=2020-04-27

http://localhost:8080/fhir/Practitioner?_id=1&_elements=identifier,language&_format=json
- Returns a Practitioner bundle but only the identifier, meta and language for the entry. 
- Calls: "http://localhost:8081/fuzeResourceAdapter/provider/1?_elements=identifier,language"

### Explanation Of Benefits (added in v0.6.0)
Due to changes involving scope separations and an updated HAPI FHIR version, certain endpoints have changed. The next version should include an updated method for handling permissions that adds better options. For the timing being, these points are usable.

http://localhost:8080/fhir/ExplanationOfBenefit/15?_format=json
- Uses the embedded MedicaidId to fetch an EOB object with Id of 15 with an identifier of Medicaid.
- Calls: http://localhost:8081/fuzeResourceAdapter/ExplanationOfBenefit/15

http://localhost:8080/fhir/ExplanationOfBenefit?patient=30&_elements=identifier,language&_format=json
- Uses to receive an entry limited to meta, identifier and language. 
- Calls: "http://localhost:8081/fuzeResourceAdapter/ExplanationOfBenefit?_elements=identifier,language&patient=30"

#### Additional search parameters (added in v0.7.0)
http://localhost:8080/fhir/ExplanationOfBenefit?patient=30&identifier=Medicare&type=inpatient&service-date=gt2019-01-01&service-date=lt2020-12-25&_lastUpdated=gt2018-05-05&_lastUpdated=lt2020-10-01&_format=json
- Returns the Explanation of Benefit bundle for Patient with an ID of 30. The patient parameter is required, all others are optional.
- Calls: http://localhost:8081/fuzeResourceAdapter/ExplanationOfBenefit?identifier=Medicare&serviceenddate=2020-12-25&lastupdatedstartdate=2018-05-05&patient=30&lastupdatedenddate=2020-10-01&type=inpatient&servicestartdate=2019-01-01

http://localhost:8080/fhir/ExplanationOfBenefit?_id=92&patient=30&identifier=Medicare&_format=json
- Returns the Explanation of Benefit bundle with the id of 92, for patient 30. Using _id against a non-Patient endpoint creates security ambiguity, so the user must provide the patient as well.
- Calls: http://localhost:8081/fuzeResourceAdapter/explanationOfBenefit/92?payerType=Medicare

http://localhost:8080/fhir/ExplanationOfBenefit?identifier=Medicare&_format=json
- Returns the EOB bundle for this patient from Medicare by attempting to use the MedicaidId embedded in the request. Caution, may not work.
- Calls: http://localhost:8081/fuzeResourceAdapter/explanationOfBenefit?patientId=30&payerType=Medicare&startDate=1900-01-01&endDate=2020-04-23&isSummary=false

#### Unsupported search parameters as of v0.8.0
http://localhost:8080/fhir/ExplanationOfBenefit?patient=30&_summary=true&_format=json
- Returns a textual summary EOB bundle for Medicaid, which is the default. We don't recommend this endpoint because it does not provide desired fields automatically.
- Calls: http://localhost:8081/fuzeResourceAdapter/explanationOfBenefit?patientId=30&payerType=Medicaid&startDate=1900-01-01&endDate=2020-04-23&isSummary=true

http://localhost:8080/fhir/ExplanationOfBenefit?patient=30&_elements=patient&_format=json

http://localhost:8080/fhir/ExplanationOfBenefit?patient=30&_includes=patient&_format=json
