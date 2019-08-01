public with sharing class CsWrapperMechanic {

    public Mechanic__c innerMechanic { get; set; }
    public Boolean isSelectedFromList { get; set; }
    public Boolean isInsertSuccess { get; set; }
    public String errorMessage { get; set; }

    public CsWrapperMechanic(Mechanic__c mechanic) {
        this.innerMechanic = mechanic;
        this.isSelectedFromList = false;
        this.errorMessage = '';
        this.isInsertSuccess = false;
    }

    public CsWrapperMechanic(Mechanic__c mechanic, Boolean isSelected){
        this.innerMechanic = mechanic;
        this.isSelectedFromList = isSelected;
        this.errorMessage = '';
        this.isInsertSuccess = false;
    }
}