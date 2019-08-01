trigger CsContractOverlapping on Contract__c (after delete, after insert, after update, before delete, before insert, before update) {
        CsTriggerFactory.createHandler(Contract__c.SObjectType);
}