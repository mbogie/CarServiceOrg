public with sharing class CsQueueableCallouts implements Queueable, Database.AllowsCallouts{

    private List<Callout_Log__c> logs;
    private List<Workshop__c> workshops;
    private String method;
    private List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop> tomeksWorkshops;
    private CsTomeksWorkshopsRestHandler restHandler;
    private CsTomeksWorkshopsRestController.WrappedTomeksWorkshop wrappedTomeksWorkshop;
    private List<Workshop__c> listToUpdate;
    private Workshop__c workshopToUpsert;
    private List<Callout_Log__c> calloutLogsList;
    private final static String TOMEK_POST_ENDPOINT = CsUtils.getCredentialsValues('TomekPostWorkshopsEndpoint');
    private final static String TOMEK_DELETE_ENDPOINT = CsUtils.getCredentialsValues('TomekDeleteWorkshopsEndpoint');

    public CsQueueableCallouts(List<Workshop__c> workshops,String method){
        this.logs = new List<Callout_Log__c>();
        this.workshops = workshops;
        this.method = method;
        this.tomeksWorkshops = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>();
        this.restHandler = new CsTomeksWorkshopsRestHandler();
        this.listToUpdate = new List<Workshop__c>();
        this.calloutLogsList = new List<Callout_Log__c>();
    }

    public CsQueueableCallouts(List<Callout_Log__c> calloutLogs, List<Workshop__c> workshops,String method){
        this.logs = calloutLogs;
        this.workshops = workshops;
        this.method = method;
        this.tomeksWorkshops = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>();
        this.restHandler = new CsTomeksWorkshopsRestHandler();
        this.listToUpdate = new List<Workshop__c>();
        this.calloutLogsList = new List<Callout_Log__c>();
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
                wrappedTomeksWorkshop.isSynchronized = true;
                tomeksWorkshops.add(wrappedTomeksWorkshop);
            }
            try {
                String responseBody = restHandler.createRequest(TOMEK_POST_ENDPOINT, method, tomeksWorkshops);
                List<String> responseStatusList = (List<String>) JSON.deserialize(responseBody, List<String>.class);
                for(Integer i=0; i<responseStatusList.size(); i++) {
                    List<String> responseFromTomek = responseStatusList.get(i).split(',');
                    if (responseFromTomek.get(0) == System.Label.Status_Success) {
                        workshopToUpsert = workshops.get(i).clone(true, true);
                        workshopToUpsert.Is_Synchronized__c = true;
                        workshopToUpsert.External_Id__c = responseFromTomek.get(1);
                        listToUpdate.add(workshopToUpsert);
                        calloutLogsList.add(createLog(tomeksWorkshops.get(i).externalId,
                                (logs.isEmpty())? 0 : logs.get(i).Number_Of_Repeats__c +1,
                                responseFromTomek.get(1),
                                method,
                                TOMEK_POST_ENDPOINT,
                                JSON.serialize(tomeksWorkshops.get(i)),
                                responseStatusList.get(i),
                                System.Label.Status_Success));
                    }
                    else {
                        calloutLogsList.add(createLog(tomeksWorkshops.get(i).externalId,
                                (logs.isEmpty())? 0 : logs.get(i).Number_Of_Repeats__c +1,
                                responseFromTomek.get(1),
                                method,
                                TOMEK_POST_ENDPOINT,
                                JSON.serialize(tomeksWorkshops.get(i)),
                                responseStatusList.get(i),
                                System.Label.Status_Error));
                    }
                }
                insert calloutLogsList;
                update listToUpdate;
            }catch (Exception error){
                for (Integer i = 0; i <tomeksWorkshops.size() ; i++) {
                    calloutLogsList.add(createLog(tomeksWorkshops.get(i).externalId,
                            (logs.isEmpty())? 0 : logs.get(i).Number_Of_Repeats__c +1,
                            tomeksWorkshops.get(i).id,
                            method,
                            TOMEK_POST_ENDPOINT,
                            JSON.serialize(tomeksWorkshops.get(i)),
                            error.getMessage(),
                            System.Label.Status_Error));
                }
                insert calloutLogsList;
                System.debug(error.getMessage());
            }
        }
        if(method == 'DELETE') {
            String ids = '';
            for (Workshop__c workshop : workshops) {
                ids += workshop.External_Id__c + ',';
            }
            try {
                String responseBody = restHandler.createRequest(TOMEK_DELETE_ENDPOINT + ids.removeEnd(','), method, null);
                List<String> responseStatusList = (List<String>) JSON.deserialize(responseBody, List<String>.class);
                for(Integer i=0; i<responseStatusList.size(); i++) {
                    List<String> responseFromTomek = responseStatusList.get(i).split(',');
                    if (responseFromTomek.get(0) == System.Label.Status_Success) {
                        calloutLogsList.add(createLog(workshops.get(i).Id,
                                (logs.isEmpty())? 0 : logs.get(i).Number_Of_Repeats__c +1,
                                workshops.get(i).External_Id__c,
                                method,
                                TOMEK_DELETE_ENDPOINT,
                                responseFromTomek.get(1),
                                responseStatusList.get(i),
                                System.Label.Status_Success));
                    }
                    else {
                        calloutLogsList.add(createLog(workshops.get(i).Id,
                                (logs.isEmpty())? 0 : logs.get(i).Number_Of_Repeats__c +1,
                                workshops.get(i).External_Id__c,
                                method,
                                TOMEK_DELETE_ENDPOINT,
                                responseFromTomek.get(1),
                                responseStatusList.get(i),
                                System.Label.Status_Error));
                    }
                }
                insert calloutLogsList;
            } catch (CsException csError) {
                for (Integer i = 0; i < workshops.size(); i++) {
                    calloutLogsList.add(createLog(workshops.get(i).Id,
                            (logs.isEmpty()) ? 0 : logs.get(i).Number_Of_Repeats__c + 1,
                            workshops.get(i).External_Id__c,
                            method,
                            TOMEK_DELETE_ENDPOINT,
                            workshops.get(i).External_Id__c,
                            csError.getMessage(),
                            System.Label.Status_Error));
                    insert calloutLogsList;
                    System.debug(csError.getMessage());
                }
            }
        }
    }

    public Callout_Log__c createLog(String parentId,Decimal numberOfRepeat, String parentExternalId, String method, String endpoint, String requestBody, String responseBody, String status){
        return new Callout_Log__c(Name = parentId,
                Number_Of_Repeats__c = numberOfRepeat,
                Parent_External_Id__c = parentExternalId,
                Operation_Type__c = method,
                Endpoint__c = endpoint,
                Request_Body__c = requestBody,
                Callout_Response__c = responseBody,
                Callout_Status__c = status);
    }
}