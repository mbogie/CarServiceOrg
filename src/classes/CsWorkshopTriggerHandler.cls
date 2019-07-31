public with sharing class CsWorkshopTriggerHandler implements CsITrigger{

    public List<Workshop__c> newWorkshops = new List<Workshop__c>();

    public CsWorkshopTriggerHandler(){
    }

    public void bulkBefore() {
    }

    public void bulkAfter() {
    }

    public void beforeInsert(List<SObject> newlstObj) {
    }

    public void beforeUpdate(List<SObject> newlstObj, List<SObject> oldlstObj, Map<Id, SObject> newMapObj, Map<Id, SObject> oldMapObj) {
    }

    public void beforeDelete(List<SObject> oldlstObj, Map<Id, SObject> oldMapObj) {
    }

    public void afterInsert(List<SObject> newlstObj, Map<Id, SObject> newMapObj) {
        newWorkshops = (List<Workshop__c>) newlstObj;
        Set<String> newWorkshopsIds = new Set<String>();
        for(Workshop__c workshop : newWorkshops){
            newWorkshopsIds.add(workshop.Id);
        }
        CsWorkshopTriggerHandlerHelper.copyNewWorkshopToTomek(newWorkshopsIds);
    }

    public void afterUpdate(List<SObject> newlstObj, List<SObject> oldlstObj, Map<Id, SObject> newMapObj, Map<Id, SObject> oldMapObj) {
        newWorkshops = (List<Workshop__c>) newlstObj;
        Set<String> newWorkshopsIds = new Set<String>();
        for(Workshop__c workshop : newWorkshops){
            newWorkshopsIds.add(workshop.Id);
        }
        CsWorkshopTriggerHandlerHelper.copyNewWorkshopToTomek(newWorkshopsIds);
    }

    public void afterDelete(List<SObject> oldlstObj, Map<Id, SObject> oldMapObj) {
    }

    public void andFinally() {
    }
}