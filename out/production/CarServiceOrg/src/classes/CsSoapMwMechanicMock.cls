@isTest
global class CsSoapMwMechanicMock implements WebServiceMock {

    public String type;
    public CsSoapSforceComSchemasClassMwMechanic.MechanicIdStatusWrapper mechanicIdStatusWrapper;

    public CsSoapMwMechanicMock(final string type) {
        this.type = type;
        mechanicIdStatusWrapper = new CsSoapSforceComSchemasClassMwMechanic.MechanicIdStatusWrapper();
    }

    global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        if (type == 'DELETE_METHOD') {
            mechanicIdStatusWrapper.id = 'Mechanic was deleted';
            CsSoapSforceComSchemasClassMwMechanic.deleteMechanicResponse_element deleteResponse = new CsSoapSforceComSchemasClassMwMechanic.deleteMechanicResponse_element();
            deleteResponse.result = mechanicIdStatusWrapper;
            response.put('response_x', deleteResponse);
        }
        if (type == 'FAIL_DELETE_METHOD') {
            mechanicIdStatusWrapper.id = null;
            mechanicIdStatusWrapper.status = 'delete method fail';
            CsSoapSforceComSchemasClassMwMechanic.deleteMechanicResponse_element deleteResponse = new CsSoapSforceComSchemasClassMwMechanic.deleteMechanicResponse_element();
            deleteResponse.result = mechanicIdStatusWrapper;
            response.put('response_x', deleteResponse);
        }
        if (type == 'SEARCH_METHOD') {
            CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic mechanic = new CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic();
            mechanic.id = 'id';
            mechanic.firstName = 'Test';
            mechanic.lastName = 'Test';
            mechanic.mail = 'test@test.pl';
            mechanic.city = 'Lublin';
            mechanic.country = 'PL';
            CsSoapSforceComSchemasClassMwMechanic.fetchRecordsResponse_element fetchRecordsResponse = new CsSoapSforceComSchemasClassMwMechanic.fetchRecordsResponse_element();
            fetchRecordsResponse.result = new CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic[]{mechanic};
            response.put('response_x', fetchRecordsResponse);
        }
        if (type == 'UPSERT_METHOD') {
            mechanicIdStatusWrapper.id = 'Mechanic was upserted';
            CsSoapSforceComSchemasClassMwMechanic.addOrEditMechanicResponse_element addOrEditMechanicResponse = new CsSoapSforceComSchemasClassMwMechanic.addOrEditMechanicResponse_element();
            addOrEditMechanicResponse.result = mechanicIdStatusWrapper;
            response.put('response_x', addOrEditMechanicResponse);
        }
        if (type == 'FAIL_METHOD_ADD') {
            mechanicIdStatusWrapper.id = null;
            mechanicIdStatusWrapper.status = 'Method failed';
            CsSoapSforceComSchemasClassMwMechanic.addOrEditMechanicResponse_element addOrEditMechanicResponse = new CsSoapSforceComSchemasClassMwMechanic.addOrEditMechanicResponse_element();
            addOrEditMechanicResponse.result = mechanicIdStatusWrapper;
            response.put('response_x', addOrEditMechanicResponse);
        }
        if (type == 'WEBSERVICE_FAILED') {
            response.put('response_x', null);
        }
        if(type == 'COUNTRY_LIST'){
            String countryList = 'PL,AU';
            CsSoapSforceComSchemasClassMwMechanic.getCountryListResponse_element getCountryListResponse = new CsSoapSforceComSchemasClassMwMechanic.getCountryListResponse_element();
            getCountryListResponse.result = countryList;
            response.put('response_x', getCountryListResponse);
        }
    }
}