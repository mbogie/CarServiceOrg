public with sharing class CsQueueableCallouts implements Queueable, Database.AllowsCallouts{

    private List<Workshop__c> workshops;
    private String method;
    private List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop> tomeksWorkshops;
    private CsTomeksWorkshopsRestHandler restHandler;
    private CsTomeksWorkshopsRestController.WrappedTomeksWorkshop wrappedTomeksWorkshop;
    private List<Workshop__c> listToUpdate;
    private Workshop__c workshopToUpsert;

    public CsQueueableCallouts(List<Workshop__c> workshops,String method){
        this.workshops = workshops;
        this.method = method;
        this.tomeksWorkshops = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>();
        this.restHandler = new CsTomeksWorkshopsRestHandler();
        this.listToUpdate = new List<Workshop__c>();
    }

    public void execute(QueueableContext context){
        if(method == 'POST'){
            for (Workshop__c workshop : workshops) {
                wrappedTomeksWorkshop = new CsTomeksWorkshopsRestController.WrappedTomeksWorkshop();
                wrappedTomeksWorkshop.name = workshop.Name;
                wrappedTomeksWorkshop.website = workshop.Website__c;
                wrappedTomeksWorkshop.phone = workshop.Phone__c;
                wrappedTomeksWorkshop.city = workshop.City__c;
                wrappedTomeksWorkshop.country = workshop.Country__c;
                wrappedTomeksWorkshop.zipCode = workshop.Zip_Code__c;
                wrappedTomeksWorkshop.externalId = workshop.id;
                wrappedTomeksWorkshop.id = workshop.External_Id__c;
                wrappedTomeksWorkshop.isSynchronized = false;
                tomeksWorkshops.add(wrappedTomeksWorkshop);
            }
            try {
                String responseBody = restHandler.createRequest(CsUtils.getCredentialsValues('TomekPostWorkshopsEndpoint'), 'POST', tomeksWorkshops);
                List<String> responseStatusList = (List<String>) JSON.deserialize(responseBody, List<String>.class);
                for(Integer i=0; i<responseStatusList.size(); i++){
                    List<String> responseForIterObject = responseStatusList.get(i).split(',');
                    if(responseForIterObject.get(0)== System.Label.Status_Success){
                        workshopToUpsert = workshops.get(i).clone(true,true);
                        workshopToUpsert.Is_Synchronized__c = true;
                        workshopToUpsert.External_Id__c = responseForIterObject.get(1);
                        listToUpdate.add(workshopToUpsert);
                    }
                }
                update listToUpdate;
            }catch (CsException csError){
                System.debug(csError.getMessage());
            }
        }
        if(method == 'DELETE') {
            String ids = '';
            for (Workshop__c workshop : workshops) {
                ids += workshop.External_Id__c + ',';
            }
            try {
                String responseBody = restHandler.createRequest(CsUtils.getCredentialsValues('TomekDeleteWorkshopsEndpoint') + ids.removeEnd(','), 'DELETE', null);
            } catch (CsException csError) {
                System.debug(csError.getMessage());
            }
        }
    }
}