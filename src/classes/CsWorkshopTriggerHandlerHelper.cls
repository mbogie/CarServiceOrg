public with sharing class CsWorkshopTriggerHandlerHelper {

    @future (callout=true)
    public static void copyNewWorkshopToTomek(Set<String> ids){
        System.debug('copy --> jestem w trigerze');
        List<Workshop__c> newWorkshops = [SELECT Id, Tomeks_External_Id__c, Name,Country__c,City__c,Zip_Code__c,Website__c,Phone__c FROM Workshop__c WHERE Id IN :ids];
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
            wrappedTomeksWorkshop.externalId = workshop.Id;
            wrappedTomeksWorkshop.id = workshop.Tomeks_External_Id__c;
            workshops.add(wrappedTomeksWorkshop);
        }
        Map<String,List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>> jsonMap = new Map<String, List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>>();
        jsonMap.put('workshops',workshops);
        System.debug('jason -- > ' + jsonMap);
        HttpResponse response = new Http().send(restHandler.createRequest('','POST',jsonMap));
    }
}