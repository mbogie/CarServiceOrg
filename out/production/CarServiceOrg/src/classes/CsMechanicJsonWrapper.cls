public with sharing class CsMechanicJsonWrapper {

    private String Id;
    private String Full_Name;
    private String Email;
    private String Country;

    public CsMechanicJsonWrapper(Mechanic__c mechanic){
        this.Id = mechanic.Id;
        this.Full_Name = mechanic.Full_Name__c;
        this.Email = mechanic.Email__c;
        this.Country = mechanic.Country__c;
    }

}