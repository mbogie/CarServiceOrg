public with sharing class CsUpsertWorkshop implements Queueable{
    private List<Workshop__c> workshops;

    public CsUpsertWorkshop(List<Workshop__c> workshops){
        this.workshops = workshops;
    }

    public void execute(QueueableContext context){
        upsert workshops;
    }
}