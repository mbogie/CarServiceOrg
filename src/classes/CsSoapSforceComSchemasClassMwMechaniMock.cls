@isTest
global class CsSoapSforceComSchemasClassMwMechaniMock implements WebServiceMock {

    public String type;
    public CsSoapSforceComSchemasClassMwMechani.MechanicIdStatusWrapper mechanicIdStatusWrapper;

    public CsSoapSforceComSchemasClassMwMechaniMock(final string type) {
        this.type = type;
        mechanicIdStatusWrapper = new CsSoapSforceComSchemasClassMwMechani.MechanicIdStatusWrapper();
    }

    global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        if (type == 'DELETE_METHOD') {
            mechanicIdStatusWrapper.id = 'Mechanic was deleted';
            CsSoapSforceComSchemasClassMwMechani.deleteMechanicResponse_element deleteResponse = new CsSoapSforceComSchemasClassMwMechani.deleteMechanicResponse_element();
            deleteResponse.result = mechanicIdStatusWrapper;
            response.put('response_x', deleteResponse);
        }
        if (type == 'SEARCH_METHOD') {
            CsSoapSforceComSchemasClassMwMechani.WrappedMechanic mechanic = new CsSoapSforceComSchemasClassMwMechani.WrappedMechanic();
            mechanic.id = 'id';
            mechanic.firstName = 'Test';
            mechanic.lastName = 'Test';
            mechanic.mail = 'test@test.pl';
            mechanic.city = 'Lublin';
            mechanic.country = 'PL';
            CsSoapSforceComSchemasClassMwMechani.fetchRecordsResponse_element fetchRecordsResponse = new CsSoapSforceComSchemasClassMwMechani.fetchRecordsResponse_element();
            fetchRecordsResponse.result = new CsSoapSforceComSchemasClassMwMechani.WrappedMechanic[]{mechanic};
            response.put('response_x', fetchRecordsResponse);
        }
        if (type == 'UPSERT_METHOD') {
            mechanicIdStatusWrapper.id = 'Mechanic was upserted';
            CsSoapSforceComSchemasClassMwMechani.addOrEditMechanicResponse_element addOrEditMechanicResponse = new CsSoapSforceComSchemasClassMwMechani.addOrEditMechanicResponse_element();
            addOrEditMechanicResponse.result = mechanicIdStatusWrapper;
            response.put('response_x', addOrEditMechanicResponse);
        }
        if (type == 'FAIL_METHOD') {
            mechanicIdStatusWrapper.id = null;
            mechanicIdStatusWrapper.status = 'Method failed';
            CsSoapSforceComSchemasClassMwMechani.addOrEditMechanicResponse_element addOrEditMechanicResponse = new CsSoapSforceComSchemasClassMwMechani.addOrEditMechanicResponse_element();
            addOrEditMechanicResponse.result = mechanicIdStatusWrapper;
            response.put('response_x', addOrEditMechanicResponse);
        }
        if (type == 'WEBSERVICE_FAILED') {
            response.put('response_x', null);
        }
    }
}