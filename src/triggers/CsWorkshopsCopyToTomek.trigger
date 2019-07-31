trigger CsWorkshopsCopyToTomek on Workshop__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CsTriggerFactory.createHandler(Workshop__c.SObjectType);
}