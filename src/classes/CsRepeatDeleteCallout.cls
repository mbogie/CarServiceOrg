global with sharing class CsRepeatDeleteCallout implements Database.Batchable<sObject>, Database.Stateful{

    global Integer deleteListSize = 0;
    global String workshopsIds = '';

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Map<Id, Workshop__c> workshopsMap = new Map<Id, Workshop__c>([SELECT Id,Name From Workshop__c WHERE Is_Synchronized__c = false]);
        Set<Id> workshopsIdSet = workshopsMap.keySet(); //sessionId zmienna
        return Database.getQueryLocator('SELECT Id, Name, Parent_External_Id__c, Callout_Response__c, Callout_Status__c, Endpoint__c, Number_Of_Repeats__c, Operation_Type__c ,Request_Body__c FROM Callout_Log__c WHERE Operation_Type__c = \'DELETE\' ORDER BY CreatedDate DESC');
    }

    global void execute(Database.BatchableContext bc, List<Callout_Log__c> calloutLogs) {
        List<Workshop__c> workshopsToDelete = new List<Workshop__c>();
        List<Callout_Log__c> deleteList = new List<Callout_Log__c>();
        Map<String, Callout_Log__c> calloutLogMap = new Map<String, Callout_Log__c>();
        List<Callout_Log__c> newCalloutLogs = new List<Callout_Log__c>();
        for (Callout_Log__c call : calloutLogs) {
            if (!calloutLogMap.containsKey(call.Parent_External_Id__c)) {
                calloutLogMap.put(call.Parent_External_Id__c, call);
            }
        }

        for (String key : calloutLogMap.keySet()) {
            if (calloutLogMap.get(key).Number_Of_Repeats__c < 3 && calloutLogMap.get(key).Callout_Status__c == System.Label.Status_Error) {
                deleteList.add(calloutLogMap.get(key));
            }
        }
        deleteListSize += deleteList.size();

        for (Callout_Log__c log : deleteList) {
            workshopsIds += log.Name+',';
            workshopsToDelete.add(new Workshop__c(Id = log.Name, External_Id__c = log.Parent_External_Id__c, Is_Synchronized__c = true));
        }

        System.enqueueJob(new CsQueueableCallouts(deleteList, workshopsToDelete, 'DELETE'));
    }

    global void finish(Database.BatchableContext bc) {
        String abandonedWorkshopsList = ',';
        List<User> userList = new List<User>();
        userList = [SELECT Id,Email,IsActive FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = True] ;
        List<String> toAddress = new List<String>();
        for(User u : userList) {
            toAddress.add(u.Email);
        }
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset/1000);
        List<Callout_Log__c> abandonedCalloutLogs = [SELECT Id, Name, Callout_Status__c, Number_Of_Repeats__c FROM Callout_Log__c WHERE Number_Of_Repeats__c = 3 AND Callout_Status__c = :System.Label.Status_Error];
        if(!abandonedCalloutLogs.isEmpty()) {
            for(Callout_Log__c log : abandonedCalloutLogs){
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
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            }catch (Exception error){
                System.debug(error.getMessage());
            }
            upsert abandonedCalloutLogs;
        }

    }
}