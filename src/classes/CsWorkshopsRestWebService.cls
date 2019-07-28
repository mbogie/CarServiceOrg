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

        global WrappedWorkshop(Workshop__c workshop){
            this.id = workshop.Id;
            this.name = workshop.Name;
            this.phone = workshop.Phone__c;
            this.country = workshop.Country__c;
            this.website = workshop.Website__c;
            this.city = workshop.City__c;
            this.zipCode = workshop.Zip_Code__c;
        }
    }

    global class ResponseStatusWrapper{
        webService String id;
        webService String message;

        global ResponseStatusWrapper(String id, String message){
            this.id = id;
            this.message = message;
        }
    }

    @HttpDelete
    global static List<ResponseStatusWrapper> deleteWorkshops() {
        List<String> idToDelete = RestContext.request.params.get('Ids').split(',');
        List<Workshop__c> workshopsToDelete = new List<Workshop__c>();
        List<ResponseStatusWrapper> responseStatusList = new List<ResponseStatusWrapper>();
        for(String id : idToDelete){
            workshopsToDelete.add(new Workshop__c(Id = id));
        }
        try {
            Database.DeleteResult[] deleteResults = Database.delete(workshopsToDelete,false);
            for(Database.DeleteResult deleteResult : deleteResults){
                if(deleteResult.isSuccess()){
                    responseStatusList.add(new ResponseStatusWrapper(deleteResult.getId(), ''));
                } else {
                    responseStatusList.add(new ResponseStatusWrapper('', deleteResult.errors[0].getMessage()));
                }
            }
            return responseStatusList;
        } catch (DmlException err){
            System.debug('DML Error: ' +err.getMessage());
            return responseStatusList;
        }
    }

    @HttpGet
    global static List<WrappedWorkshop> searchWorkshops() {
        List<WrappedWorkshop> resultList = new List<WrappedWorkshop>();
        List<Workshop__c> workshopsList = new List<Workshop__c>();
        CsSoqlQueryBuilder queryBuilder = new CsSoqlQueryBuilder();
        String id = RestContext.request.params.get('id');
        String name = RestContext.request.params.get('name');
        String phone = RestContext.request.params.get('phone');
        String country = RestContext.request.params.get('country');
        String website = RestContext.request.params.get('website');
        String city = RestContext.request.params.get('city');
        String zipCode = RestContext.request.params.get('zipCode');
        queryBuilder.addResultField('Id')
                .addResultField('Name')
                .addResultField('Phone__c')
                .addResultField('Country__c')
                .addResultField('Website__c')
                .addResultField('City__c')
                .addResultField('Zip_Code__c')
                .addTableName('Workshop__c');
        if(String.isNotBlank(name)) queryBuilder.addSearchFieldStartsWithValue('Name',name);
        if(String.isNotBlank(phone)) queryBuilder.addSearchFieldStartsWithValue('Phone__c',phone);
        if(String.isNotBlank(country)) queryBuilder.addSearchFieldStartsWithValue('Country__c',country);
        if(String.isNotBlank(website)) queryBuilder.addSearchFieldStartsWithValue('Website__c',website);
        if(String.isNotBlank(city)) queryBuilder.addSearchFieldStartsWithValue('City__c',city);
        if(String.isNotBlank(zipCode)) queryBuilder.addSearchFieldStartsWithValue('Zip_Code__c',zipCode);
        queryBuilder.build();
        workshopsList = Database.query(queryBuilder.getQueryString());
        for(Workshop__c workshop : workshopsList){
            resultList.add(new WrappedWorkshop(workshop));
        }
        return resultList;
    }


    @HttpPost
    global static List<ResponseStatusWrapper> upsertWorkshops(List<WrappedWorkshop> wrappedWorkshopsList) {
        String id;
        List<Workshop__c> workshopsToUpsert = new List<Workshop__c>();
        List<ResponseStatusWrapper> responseStatusList = new List<ResponseStatusWrapper>();
        for (WrappedWorkshop wrappedWorkshop : wrappedWorkshopsList){
            id = (wrappedWorkshop.id == '')? null : wrappedWorkshop.id;
            workshopsToUpsert.add(new Workshop__c(Id = id, Name = wrappedWorkshop.name, Phone__c = wrappedWorkshop.phone,
                    Website__c = wrappedWorkshop.website, City__c = wrappedWorkshop.city, Country__c = wrappedWorkshop.country, Zip_Code__c = wrappedWorkshop.zipCode));
        }
        try{
            Database.UpsertResult[] upsertResults = Database.upsert(workshopsToUpsert,false);
            for(Database.UpsertResult upsertResult : upsertResults){
                if(upsertResult.isSuccess()){
                    responseStatusList.add(new ResponseStatusWrapper(upsertResult.getId(), ''));
                } else {
                    responseStatusList.add(new ResponseStatusWrapper('', upsertResult.errors[0].getMessage()));
                }
            }
            return responseStatusList;
        } catch (DmlException err){
            System.debug('DML Error: ' +err.getMessage());
            return responseStatusList;
        }
    }
}