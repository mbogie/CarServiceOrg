public with sharing class CsWorkshopResourceHandler {

    public static List<CsWorkshopResource.ResponseStatus> deleteWorkshopList(RestRequest request) {
        List<String> idToDelete = request.params.get('ids').split(',');
        List<Workshop__c> workshopsToDelete = new List<Workshop__c>();
        List<CsWorkshopResource.ResponseStatus> responseStatusList = new List<CsWorkshopResource.ResponseStatus>();
        for (String id : idToDelete) {
            workshopsToDelete.add(new Workshop__c(Id = id));
        }
        Database.DeleteResult[] deleteResults = Database.delete(workshopsToDelete, false);
        for (Database.DeleteResult deleteResult : deleteResults) {
            if (deleteResult.isSuccess()) {
                responseStatusList.add(new CsWorkshopResource.ResponseStatus(true, deleteResult.getId(), null));
            } else {
                responseStatusList.add(new CsWorkshopResource.ResponseStatus(false, deleteResult.getId(), deleteResult.errors[0].getMessage()));
            }
        }
        return responseStatusList;
    }

    public static List<CsWorkshopResource.WrappedWorkshop> getWorkshopList(RestRequest request) {
        List<CsWorkshopResource.WrappedWorkshop> resultList = new List<CsWorkshopResource.WrappedWorkshop>();
        List<Workshop__c> workshopsList = new List<Workshop__c>();
        CsSoqlQueryBuilder queryBuilder = new CsSoqlQueryBuilder();
        Map<String, String> paramsMap = request.params;
        queryBuilder.addResultField('Id')
                .addResultField('Is_Synchronized__c')
                .addResultField('External_Id__c')
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
            resultList.add(new CsWorkshopResource.WrappedWorkshop(workshop));
        }
        return resultList;
    }

    public static List<CsWorkshopResource.ResponseStatus> updateWorkshopList(List<CsWorkshopResource.WrappedWorkshop> wrappedWorkshopsList) {
        List<Workshop__c> workshopsToUpsert = new List<Workshop__c>();
        List<CsWorkshopResource.ResponseStatus> responseStatusList = new List<CsWorkshopResource.ResponseStatus>();
        for (CsWorkshopResource.WrappedWorkshop wrappedWorkshop : wrappedWorkshopsList) {
            workshopsToUpsert.add(new Workshop__c(
                    Id = (wrappedWorkshop.id == '') ? null : wrappedWorkshop.id,
                    Is_Synchronized__c = (wrappedWorkshop.isSynchronized == null) ? false : wrappedWorkshop.isSynchronized,
                    External_Id__c = wrappedWorkshop.externalId,
                    Name = wrappedWorkshop.name,
                    Phone__c = wrappedWorkshop.phone,
                    Website__c = wrappedWorkshop.website,
                    City__c = wrappedWorkshop.city,
                    Country__c = wrappedWorkshop.country,
                    Zip_Code__c = wrappedWorkshop.zipCode));
        }
        Database.UpsertResult[] upsertResults = Database.upsert(workshopsToUpsert, false);
        for (Database.UpsertResult upsertResult : upsertResults) {
            if (upsertResult.isSuccess()) {
                responseStatusList.add(new CsWorkshopResource.ResponseStatus(true, upsertResult.getId(), null));
            } else {
                responseStatusList.add(new CsWorkshopResource.ResponseStatus(false, upsertResult.getId(), upsertResult.errors[0].getMessage()));
            }
        }
        return responseStatusList;
    }
}