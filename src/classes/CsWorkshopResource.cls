@RestResource(urlMapping='/workshops')
global class CsWorkshopResource {

    global class WrappedWorkshop {
        webService String externalId;
        webService String id;
        webService String name;
        webService String phone;
        webService String country;
        webService String website;
        webService String city;
        webService String zipCode;
        webService Boolean isSynchronized;

        global WrappedWorkshop(Workshop__c workshop) {
            this.externalId = workshop.External_Id__c;
            this.id = workshop.Id;
            this.name = workshop.Name;
            this.phone = workshop.Phone__c;
            this.country = workshop.Country__c;
            this.website = workshop.Website__c;
            this.city = workshop.City__c;
            this.zipCode = workshop.Zip_Code__c;
            this.isSynchronized = workshop.Is_Synchronized__c;
        }
    }

    global class ResponseStatus {
        webService Boolean isActionSuccess;
        webService String id;
        webService String message;

        global ResponseStatus(Boolean status, String id, String message) {
            this.isActionSuccess = status;
            this.id = id;
            this.message = message;
        }
    }

    @HttpDelete
    global static List<ResponseStatus> deleteWorkshopList() {
        return CsWorkshopResourceHandler.deleteWorkshopList(RestContext.request);
    }

    @HttpGet
    global static List<WrappedWorkshop> getWorkshopList() {
        return CsWorkshopResourceHandler.getWorkshopList(RestContext.request);
    }

    @HttpPost
    global static List<ResponseStatus> upsertWorkshopList(List<WrappedWorkshop> wrappedWorkshopsList) {
        return CsWorkshopResourceHandler.updateWorkshopList(wrappedWorkshopsList);
    }
}