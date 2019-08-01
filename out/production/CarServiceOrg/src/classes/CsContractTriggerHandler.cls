public with sharing class CsContractTriggerHandler implements CsITrigger {

    Set<Id> mechanicsIdFromTrigger = new Set<Id>();
    Set<Id> workshopsIdFromTrigger = new Set<Id>();
    String mechanicWorkshopCrossId = '';
    List<Contract__c> existingContracts = new List<Contract__c>();
    Map<String, List<Contract__c>> contractsMap = new Map<String, List<Contract__c>>();

    public CsContractTriggerHandler() {
    }

    public void bulkBefore() {
        if (Trigger.isUpdate || Trigger.isInsert) {
            for (Contract__c newContract : (List<Contract__c>) Trigger.new) {
                mechanicsIdFromTrigger.add(newContract.Mechanic__c);
                workshopsIdFromTrigger.add(newContract.Workshop__c);
                mechanicWorkshopCrossId = newContract.Mechanic__c + '' + newContract.Workshop__c;
                contractsMap.put(mechanicWorkshopCrossId, new List<Contract__c>());
            }

            existingContracts = [
                    SELECT Name, Mechanic__c, Workshop__c, Start_Date__c, End_Date__c
                    FROM Contract__c
                    WHERE Mechanic__c IN :mechanicsIdFromTrigger AND Workshop__c IN :workshopsIdFromTrigger AND Id NOT IN :Trigger.new];

            for (Contract__c oldContract : existingContracts) {
                mechanicWorkshopCrossId = oldContract.Mechanic__c + '' + oldContract.Workshop__c;
                if (contractsMap.containsKey(mechanicWorkshopCrossId)) {
                    contractsMap.get(mechanicWorkshopCrossId).add(oldContract);
                }
            }
        }
    }

    public void bulkAfter() {
    }

    public void beforeInsert(List<SObject> newlstObj) {
        CsContractTriggerHandlerHelper.overlappingError((List<Contract__c>) newlstObj, contractsMap);

    }

    public void beforeUpdate(List<SObject> newlstObj, List<SObject> oldlstObj, Map<Id, SObject> newMapObj, Map<Id, SObject> oldMapObj) {
        CsContractTriggerHandlerHelper.overlappingError((List<Contract__c>) newlstObj, contractsMap);
    }

    public void beforeDelete(List<SObject> oldlstObj, Map<Id, SObject> oldMapObj) {
    }

    public void afterInsert(List<SObject> newlstObj, Map<Id, SObject> newMapObj) {
    }

    public void afterUpdate(List<SObject> newlstObj, List<SObject> oldlstObj, Map<Id, SObject> newMapObj, Map<Id, SObject> oldMapObj) {
    }

    public void afterDelete(List<SObject> oldlstObj, Map<Id, SObject> oldMapObj) {
    }

    public void andFinally() {
    }
}