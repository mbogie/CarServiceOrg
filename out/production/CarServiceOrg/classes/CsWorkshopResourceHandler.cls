public with sharing class CsWorkshopResourceHandler {

    public static List<CsWorkshopResource.ResponseStatus> deleteWorkshopList(RestRequest request){
        List<String> idToDelete =request.params.get('ids').split(',');
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
}