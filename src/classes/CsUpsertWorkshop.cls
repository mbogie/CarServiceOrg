public with sharing class CsUpsertWorkshop implements Queueable, Database.AllowsCallouts{
    private CsTomeksWorkshopsRestController.WrappedTomeksWorkshop tomeksWorkshop;
    private Workshop__c workshopToUpsert;


    public CsUpsertWorkshop(CsTomeksWorkshopsRestController.WrappedTomeksWorkshop tomeksWorkshop){
        this.tomeksWorkshop = tomeksWorkshop;
        this.workshopToUpsert = new Workshop__c();
    }

    public void execute(QueueableContext context){
        workshopToUpsert.External_Id__c = tomeksWorkshop.id;
        workshopToUpsert.Name = tomeksWorkshop.name;
        workshopToUpsert.Website__c = tomeksWorkshop.website;
        workshopToUpsert.Phone__c = tomeksWorkshop.phone;
        workshopToUpsert.City__c = tomeksWorkshop.city;
        workshopToUpsert.Country__c = tomeksWorkshop.country;
        workshopToUpsert.Zip_Code__c = tomeksWorkshop.zipCode;
        workshopToUpsert.Id = tomeksWorkshop.externalId;
        workshopToUpsert.Is_Synchronized__c = false;
        try {
            upsert workshopToUpsert;
        } catch (Exception err) {
            System.debug(err.getMessage());
        }
    }
}