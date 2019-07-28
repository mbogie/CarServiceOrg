@RestResource(urlMapping='/workshops/*')
global with sharing class CsWorkshopsRestWebService {

    global class WrappedWorkshop {
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

    @HttpDelete
    global static List<String> deleteWorkshops() {
        List<String> idToDelete = RestContext.request.params.get('Ids').split(',');
        List<Workshop__c> workshopsToDelete = new List<Workshop__c>();
        List<String> responseStatusList = new List<String>();
        for (String id : idToDelete) {
            workshopsToDelete.add(new Workshop__c(Id = id));
        }
        Database.DeleteResult[] deleteResults = Database.delete(workshopsToDelete, false);
        for (Database.DeleteResult deleteResult : deleteResults) {
            if (deleteResult.isSuccess()) {
                responseStatusList.add('Success,'+ deleteResult.getId());
            } else {
                responseStatusList.add('Fail,'+ deleteResult.errors[0].getMessage());
            }
        }
        return responseStatusList;
    }

    @HttpGet
    global static List<WrappedWorkshop> searchWorkshops() {
        List<WrappedWorkshop> resultList = new List<WrappedWorkshop>();
        List<Workshop__c> workshopsList = new List<Workshop__c>();
        CsSoqlQueryBuilder queryBuilder = new CsSoqlQueryBuilder();
        Map<String,String> paramsMap = RestContext.request.params;
        queryBuilder.addResultField('Id')
                .addResultField('Name')
                .addResultField('Phone__c')
                .addResultField('Country__c')
                .addResultField('Website__c')
                .addResultField('City__c')
                .addResultField('Zip_Code__c')
                .addTableName('Workshop__c');
        for (String key : paramsMap.keySet()){
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
    global static List<String> upsertWorkshops(List<WrappedWorkshop> wrappedWorkshopsList) {
        String id;
        List<Workshop__c> workshopsToUpsert = new List<Workshop__c>();
        List<String> responseStatusList = new List<String>();
        for (WrappedWorkshop wrappedWorkshop : wrappedWorkshopsList) {
            id = (wrappedWorkshop.id == '') ? null : wrappedWorkshop.id;
            workshopsToUpsert.add(new Workshop__c(Id = id, Name = wrappedWorkshop.name, Phone__c = wrappedWorkshop.phone,
                    Website__c = wrappedWorkshop.website, City__c = wrappedWorkshop.city, Country__c = wrappedWorkshop.country, Zip_Code__c = wrappedWorkshop.zipCode));
        }
        Database.UpsertResult[] upsertResults = Database.upsert(workshopsToUpsert, false);
        for (Database.UpsertResult upsertResult : upsertResults) {
            if (upsertResult.isSuccess()) {
                responseStatusList.add('Success,'+ upsertResult.getId());
            } else {
                responseStatusList.add('Fail,'+ upsertResult.errors[0].getMessage());
            }
        }
        return responseStatusList;
    }
}