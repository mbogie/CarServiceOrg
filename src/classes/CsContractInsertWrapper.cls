public with sharing class CsContractInsertWrapper {

    public Contract__c contractToInsert {get; set;}
    public String errorMessage {get; set;}
    public Boolean isInsertedSuccessfully { get; set; }

    public CsContractInsertWrapper(Contract__c contract){
        this.contractToInsert = contract;
        this.errorMessage = '';
        this.isInsertedSuccessfully = false;

    }
}