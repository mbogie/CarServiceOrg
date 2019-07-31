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

        global WrappedWorkshop(Workshop__c workshop) {
            this.id = workshop.Id;
            this.name = workshop.Name;
            this.phone = workshop.Phone__c;
            this.country = workshop.Country__c;
            this.website = workshop.Website__c;
            this.city = workshop.City__c;
            this.zipCode = workshop.Zip_Code__c;
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
        List<String> idToDelete = RestContext.request.params.get('ids').split(',');
        List<Workshop__c> workshopsToDelete = new List<Workshop__c>();
        List<ResponseStatus> responseStatusList = new List<ResponseStatus>();
        for (String id : idToDelete) {
            workshopsToDelete.add(new Workshop__c(Id = id));
        }
        Database.DeleteResult[] deleteResults = Database.delete(workshopsToDelete, false);
        for (Database.DeleteResult deleteResult : deleteResults) {
            if (deleteResult.isSuccess()) {
                responseStatusList.add(new ResponseStatus(true, deleteResult.getId(), null));
            } else {
                responseStatusList.add(new ResponseStatus(false, deleteResult.getId(), deleteResult.errors[0].getMessage()));
            }
        }
        return responseStatusList;
    }

    @HttpGet
    global static List<WrappedWorkshop> getWorkshopList() {
        List<WrappedWorkshop> resultList = new List<WrappedWorkshop>();
        List<Workshop__c> workshopsList = new List<Workshop__c>();
        CsSoqlQueryBuilder queryBuilder = new CsSoqlQueryBuilder();
        Map<String, String> paramsMap = RestContext.request.params;
        queryBuilder.addResultField('Id')
                .addResultField('Name')
                .addResultField('Phone__c')
                .addResultField('Country__c')
                .addResultField('Website__c')
                .addResultField('City__c')
                .addResultField('Zip_Code__c')
                .addTableName('Workshop__c');
        for (String key : paramsMap.keySet()) {
            queryBuilder.addSearchFieldWithValue(key, paramsMap.get(key));
        }
        queryBuilder.build();
        workshopsList = Database.query(queryBuilder.getQueryString());
        for (Workshop__c workshop : workshopsList) {
            resultList.add(new WrappedWorkshop(workshop));
        }
        return resultList;
    }

    @HttpPost
    global static List<ResponseStatus> upsertWorkshopList(List<WrappedWorkshop> wrappedWorkshopsList) {
        List<Workshop__c> workshopsToUpsert = new List<Workshop__c>();
        List<ResponseStatus> responseStatusList = new List<ResponseStatus>();
        for (WrappedWorkshop wrappedWorkshop : wrappedWorkshopsList) {
            workshopsToUpsert.add(new Workshop__c(Id = (wrappedWorkshop.id == '') ? null : wrappedWorkshop.id, Name = wrappedWorkshop.name, Phone__c = wrappedWorkshop.phone,
                    Website__c = wrappedWorkshop.website, City__c = wrappedWorkshop.city, Country__c = wrappedWorkshop.country, Zip_Code__c = wrappedWorkshop.zipCode));
        }
        Database.UpsertResult[] upsertResults = Database.upsert(workshopsToUpsert, false);
        for (Database.UpsertResult upsertResult : upsertResults) {
            if (upsertResult.isSuccess()) {
                responseStatusList.add(new ResponseStatus(true, upsertResult.getId(), null));
            } else {
                responseStatusList.add(new ResponseStatus(false, upsertResult.getId(), upsertResult.errors[0].getMessage()));
            }
        }
        return responseStatusList;
    }
}