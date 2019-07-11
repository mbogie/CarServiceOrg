public with sharing class CsMechanicJsonWrapper {

    private String Id;
    private String Full_Name;
    private String Email;
    private String Country;

    public CsMechanicJsonWrapper(String id, String name, String email, String country){
        this.Id = id;
        this.Full_Name = name;
        this.Email = email;
        this.Country = country;
    }

    public static CsMechanicJsonWrapper mechanicToWrapper(Mechanic__c mechanic){
        return new CsMechanicJsonWrapper(mechanic.Id, mechanic.Full_Name__c,mechanic.Email__c,mechanic.Country__c);
    }
}