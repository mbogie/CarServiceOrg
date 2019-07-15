public with sharing class CsImportMechanicWrapper {

    public Mechanic__c wrappedMechanic { get; set; }
    public Integer indexOnList { get; set; }
    public Integer indexOfInsert { get; set; }
    public Boolean isSelectedFromList { get; set; }
    public Boolean isInsertedSuccessfully { get; set; }
    public Boolean displayInsertStatus { get; set; }
    public String errorMessage { get; set; }

    public CsImportMechanicWrapper(Mechanic__c mechanic) {
        wrappedMechanic = mechanic;
        isSelectedFromList = false;
        isInsertedSuccessfully = null;
        displayInsertStatus = false;
        errorMessage = '';
    }

    public CsImportMechanicWrapper(Mechanic__c mechanic, Boolean isSelected){
        wrappedMechanic = mechanic;
        isSelectedFromList = isSelected;
    }

}