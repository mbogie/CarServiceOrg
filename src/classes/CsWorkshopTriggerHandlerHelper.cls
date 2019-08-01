public with sharing class CsWorkshopTriggerHandlerHelper {

    @future(callout=true)
    public static void copyNewWorkshopToTomek(Set<String> ids, Boolean shouldUpdate) {
        System.debug('copy --> jestem w trigerze');
        List<Workshop__c> newWorkshops = [SELECT Id, External_Id__c, Name,Country__c,City__c,Zip_Code__c,Website__c,Phone__c FROM Workshop__c WHERE Id IN :ids];
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
            workshops.add(wrappedTomeksWorkshop);
        }
        Map<String, List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>> jsonMap = new Map<String, List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>>();
        jsonMap.put('workshops', workshops);
        System.debug('jason -- > ' + jsonMap);
        HttpResponse response = new Http().send(restHandler.createRequest('', 'POST', jsonMap));
        List<String> responseStatusList = (List<String>) JSON.deserialize(response.getBody(), List<String>.class);
        System.debug('zwrotka--> ' + responseStatusList);
        CsWorkshopTriggerHandler.firstRun = false;
        if(shouldUpdate) {
            System.debug('robie update');
            List<Workshop__c> workshopsToUpdate = new List<Workshop__c>();
            for (Integer i = 0; i < responseStatusList.size(); i++) {
                List<String> upsertStatus = responseStatusList.get(i).split(',');
                System.debug('out ' + upsertStatus.get(0));
                if (upsertStatus.get(0) == System.Label.Status_Success) {
                    System.debug('in ' + upsertStatus.get(1));
                    newWorkshops.get(i).External_Id__c = upsertStatus.get(1);
                    workshopsToUpdate.add(newWorkshops.get(i));
                }
            }
            try {
                update workshopsToUpdate;
            } catch (Exception err) {
                System.debug('error  ' + err.getMessage());
            }
        }
    }

    @future(callout=true)
    public static void deleteWorkshopsInTomeksOrg(String ids) {
        CsTomeksWorkshopsRestHandler restHandler = new CsTomeksWorkshopsRestHandler();
        HttpResponse response = new Http().send(restHandler.createRequest('?id=' + ids, 'DELETE', null));
        System.debug('ids -- >' + ids);
        List<String> responseStatusList = (List<String>) JSON.deserialize(response.getBody(), List<String>.class);
        System.debug('zwrotka--> ' + responseStatusList);
    }
}