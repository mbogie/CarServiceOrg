public with sharing class CsWorkshopTriggerHandler implements CsITrigger {

    public List<Workshop__c> newWorkshops = new List<Workshop__c>();
    public List<Workshop__c> deletedWorkshops = new List<Workshop__c>();
    public static boolean firstRun = true;

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
        if (firstRun) {
            newWorkshops = (List<Workshop__c>) newlstObj;
            Set<String> newWorkshopsIds = new Set<String>();
            for (Workshop__c workshop : newWorkshops) {
                if(workshop.Is_Synchronized__c == false)
                    newWorkshopsIds.add(workshop.Id);
            }
            if(!newWorkshops.isEmpty()) CsWorkshopTriggerHandlerHelper.copyNewWorkshopToTomek(newWorkshopsIds);
        }
    }

    public void afterUpdate(List<SObject> newlstObj, List<SObject> oldlstObj, Map<Id, SObject> newMapObj, Map<Id, SObject> oldMapObj) {
        if (firstRun) {
            newWorkshops = (List<Workshop__c>) newlstObj;
            Set<String> newWorkshopsIds = new Set<String>();
            for (Workshop__c workshop : newWorkshops) {
                if(workshop.Is_Synchronized__c == false)
                    newWorkshopsIds.add(workshop.Id);
            }
            if(!newWorkshops.isEmpty()) CsWorkshopTriggerHandlerHelper.copyNewWorkshopToTomek(newWorkshopsIds);
        }
    }

    public void afterDelete(List<SObject> oldlstObj, Map<Id, SObject> oldMapObj) {
        String idsToDelete = '';
        deletedWorkshops = (List<Workshop__c>) oldlstObj;
        for (Workshop__c workshop : deletedWorkshops) {
            idsToDelete += workshop.External_Id__c + ',';
        }
        CsWorkshopTriggerHandlerHelper.deleteWorkshopsInTomeksOrg(idsToDelete.removeEnd(','));
    }

    public void andFinally() {
    }
}