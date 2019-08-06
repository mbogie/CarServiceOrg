public with sharing class CsWorkshopTriggerHandler implements CsITrigger {

    public List<Workshop__c> newWorkshops = new List<Workshop__c>();
    public List<Workshop__c> listToUpsert = new List<Workshop__c>();

    public CsWorkshopTriggerHandler() {
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
        System.enqueueJob(new CsQueueableCallouts((List<Workshop__c>) newlstObj, 'POST'));
    }

    public void afterUpdate(List<SObject> newlstObj, List<SObject> oldlstObj, Map<Id, SObject> newMapObj, Map<Id, SObject> oldMapObj) {
        newWorkshops = (List<Workshop__c>) newlstObj;
        for (Workshop__c workshop : newWorkshops) {
            if (workshop.Is_Synchronized__c == false)
                listToUpsert.add(workshop);
        }
        if (!listToUpsert.isEmpty()) System.enqueueJob(new CsQueueableCallouts(newWorkshops, 'POST'));
    }

    public void afterDelete(List<SObject> oldlstObj, Map<Id, SObject> oldMapObj) {
        System.enqueueJob(new CsQueueableCallouts((List<Workshop__c>) oldlstObj, 'DELETE'));
    }

    public void andFinally() {
    }
}