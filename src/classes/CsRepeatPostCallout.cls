global with sharing class CsRepeatPostCallout implements Database.Batchable<sObject>, Database.Stateful{

    global Integer postListSize = 0;
    global String workshopsIds = '';

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Map<Id, Workshop__c> workshopsMap = new Map<Id, Workshop__c>([SELECT Id,Name From Workshop__c WHERE Is_Synchronized__c = false]);
        Set<Id> workshopsIdSet = workshopsMap.keySet();
        return Database.getQueryLocator('SELECT Id, Name, Parent_External_Id__c, Callout_Response__c, Callout_Status__c, Endpoint__c, Number_Of_Repeats__c, Operation_Type__c ,Request_Body__c FROM Callout_Log__c WHERE Name IN :workshopsIdSet ORDER BY CreatedDate DESC');
    }

    global void execute(Database.BatchableContext bc, List<Callout_Log__c> calloutLogs) {
        List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop> tomeksWorkshops = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>();
        List<Workshop__c> workshopsToSend = new List<Workshop__c>();
        List<Callout_Log__c> upsertList = new List<Callout_Log__c>();
        Map<String, Callout_Log__c> calloutLogMap = new Map<String, Callout_Log__c>();
        for (Callout_Log__c call : calloutLogs) {
            if (!calloutLogMap.containsKey(call.Parent_External_Id__c)) {
                calloutLogMap.put(call.Parent_External_Id__c, call);
            }
        }

        for (String key : calloutLogMap.keySet()) {
            if (calloutLogMap.get(key).Number_Of_Repeats__c < 3) {
                upsertList.add(calloutLogMap.get(key));
            }
        }
        postListSize += upsertList.size();
        for (Callout_Log__c log : upsertList) {
            workshopsIds += log.Name+',';
            workshopsToSend.add(createWorkshop(log.Request_Body__c));
        }

        System.enqueueJob(new CsQueueableCallouts(upsertList, workshopsToSend, 'POST'));

    }

    global void finish (Database.BatchableContext bc) {
        String abandonedWorkshopsList = ',';
        List<User> userList = new List<User>();
        userList = [SELECT Id,Email,IsActive FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = True] ;
        List<String> toAddress = new List<String>();
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset/1000);
        for(User u : userList) {
            toAddress.add(u.Email);
        }
        List<Callout_Log__c> abandonedCalloutLogs = [SELECT Id, Name, Callout_Status__c, Number_Of_Repeats__c FROM Callout_Log__c WHERE Number_Of_Repeats__c = 3 AND Callout_Status__c = :System.Label.Status_Error];
        if(!abandonedCalloutLogs.isEmpty()) {
            for (Callout_Log__c log : abandonedCalloutLogs) {
                log.Callout_Status__c = System.Label.Status_Abandoned;
                abandonedWorkshopsList += log.Name + ',';
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddress);
            mail.setSubject('Repeats Delete Callouts');
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody
                    ('The batch Apex job completed on  ' + local + ',\n\n' +
                            'Number Of Abandoned Logs : ' + abandonedCalloutLogs.size() + '\n' +
                            'List Of Abandoned Workshops Ids : ' + abandonedWorkshopsList.removeEnd(','));
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        mail
                });
            } catch (Exception error) {
                System.debug(error.getMessage());
            }
            upsert abandonedCalloutLogs;
        }
    }

    private Workshop__c createWorkshop(String body){
        CsTomeksWorkshopsRestController.WrappedTomeksWorkshop tomeksWorkshop = (CsTomeksWorkshopsRestController.WrappedTomeksWorkshop) JSON.deserialize(body, CsTomeksWorkshopsRestController.WrappedTomeksWorkshop.class);
        return new Workshop__c(
                Id = tomeksWorkshop.externalId,
                Is_Synchronized__c = tomeksWorkshop.isSynchronized,
                External_Id__c = tomeksWorkshop.id,
                Name = tomeksWorkshop.name,
                Phone__c = tomeksWorkshop.phone,
                Website__c = tomeksWorkshop.website,
                City__c = tomeksWorkshop.city,
                Country__c = tomeksWorkshop.country,
                Zip_Code__c = tomeksWorkshop.zipCode);
    }
}