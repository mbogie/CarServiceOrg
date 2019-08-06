public with sharing class CsWorkshopTriggerHandlerHelper {

    @future(callout=true)
    public static void copyNewWorkshopToTomek(Set<String> ids) {
        String responseString;
        List<Workshop__c> newWorkshops = [SELECT Id, External_Id__c, Is_Synchronized__c, Name,Country__c,City__c,Zip_Code__c,Website__c,Phone__c FROM Workshop__c WHERE Id IN :ids];
        List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop> workshops = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>();
        CsTomeksWorkshopsRestHandler restHandler = new CsTomeksWorkshopsRestHandler();
        for (Workshop__c workshop : newWorkshops) {
            CsTomeksWorkshopsRestController.WrappedTomeksWorkshop wrappedTomeksWorkshop = new CsTomeksWorkshopsRestController.WrappedTomeksWorkshop();
            wrappedTomeksWorkshop.name = workshop.Name;
            wrappedTomeksWorkshop.website = workshop.Website__c;
            wrappedTomeksWorkshop.phone = workshop.Phone__c;
            wrappedTomeksWorkshop.city = workshop.City__c;
            wrappedTomeksWorkshop.country = workshop.Country__c;
            wrappedTomeksWorkshop.zipCode = workshop.Zip_Code__c;
            wrappedTomeksWorkshop.externalId = workshop.id;
            wrappedTomeksWorkshop.id = workshop.External_Id__c;
            wrappedTomeksWorkshop.isSynchronized = (workshop.Is_Synchronized__c == null)?false : workshop.Is_Synchronized__c;
            workshops.add(wrappedTomeksWorkshop);
        }
        responseString = restHandler.createRequest('', 'POST', workshops);
        CsWorkshopTriggerHandler.firstRun = false;
        List<Workshop__c> workshopsToUpdate = new List<Workshop__c>();
        if (responseString.startsWith(System.Label.Status_Error)) {
            System.debug(responseString);
        }else {
            List<String> responseStatusList = (List<String>) JSON.deserialize(responseString, List<String>.class);
            for (Integer i = 0; i < responseStatusList.size(); i++) {
                List<String> upsertStatus = responseStatusList.get(i).split(',');
                if (upsertStatus.get(0) == System.Label.Status_Success) {
                    newWorkshops.get(i).External_Id__c = upsertStatus.get(1);
                    newWorkshops.get(i).Is_Synchronized__c = true;
                    workshopsToUpdate.add(newWorkshops.get(i));
                }
            }
        }
        try{
            update workshopsToUpdate;
        } catch (Exception err){
            System.debug(err.getMessage());
        }
    }

    @future(callout=true)
    public static void deleteWorkshopsInTomeksOrg(String ids) {
        String responseString;
        CsTomeksWorkshopsRestHandler restHandler = new CsTomeksWorkshopsRestHandler();
        responseString = restHandler.createRequest('?id=' + ids, 'DELETE', null);
        if (responseString.startsWith(System.Label.Status_Error)) {
            System.debug(responseString);
        }else {
            List<String> responseStatusList = (List<String>) JSON.deserialize(responseString, List<String>.class);
        }
    }
}