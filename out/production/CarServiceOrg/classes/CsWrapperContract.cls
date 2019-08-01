public with sharing class CsWrapperContract {

    public Contract__c innerContract { get; set; }
    public Boolean isEdited { get; set; }
    public Boolean isInsertSuccess { get; set; }
    public String errorMessage { get; set; }

    public CsWrapperContract(Contract__c contract) {
        this.innerContract = contract;
        this.isEdited = false;
        this.errorMessage = '';
        this.isInsertSuccess = false;
    }
}