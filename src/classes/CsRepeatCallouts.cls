global class CsRepeatCallouts implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    global Integer numberOfSuccess = 0;
    global Integer numberOfFails = 0;
    global List<Callout_Log__c> newCalloutLogs = new List<Callout_Log__c>();
    global Decimal maxNumberOfRecall = CsUtils.getNumberValues('NumberOfRecalls');

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Map<Id, Workshop__c> workshopsMap = new Map<Id, Workshop__c>([SELECT Id,Name From Workshop__c WHERE Is_Synchronized__c = false]);
        Set<Id> workshopsIdSet = workshopsMap.keySet();
        return Database.getQueryLocator('SELECT Id, Name, Parent_External_Id__c, Callout_Response__c, Callout_Status__c, Endpoint__c, Number_Of_Repeats__c, Operation_Type__c ,Request_Body__c FROM Callout_Log__c WHERE  Name IN :workshopsIdSet OR Operation_Type__c = \'DELETE\' ORDER BY CreatedDate DESC');
    }

    global void execute(Database.BatchableContext bc, List<Callout_Log__c> calloutLogs) {
        List<Callout_Log__c> deleteList = new List<Callout_Log__c>();
        List<Callout_Log__c> postList = new List<Callout_Log__c>();
        Map<String, Callout_Log__c> calloutLogMap = new Map<String, Callout_Log__c>();
        for (Callout_Log__c call : calloutLogs) {
            if (!calloutLogMap.containsKey(call.Parent_External_Id__c)) {
                calloutLogMap.put(call.Parent_External_Id__c, call);
            }
        }
        for (String key : calloutLogMap.keySet()) {
            if (calloutLogMap.get(key).Operation_Type__c == 'DELETE' && calloutLogMap.get(key).Number_Of_Repeats__c < maxNumberOfRecall && calloutLogMap.get(key).Callout_Status__c == System.Label.Status_Error) {
                deleteList.add(calloutLogMap.get(key));
            }
            if (calloutLogMap.get(key).Operation_Type__c == 'POST' && calloutLogMap.get(key).Number_Of_Repeats__c < maxNumberOfRecall) {
                postList.add(calloutLogMap.get(key));
            }
        }
        calloutMethod(deleteList, 'DELETE', CsUtils.getCredentialsValues('TomekDeleteWorkshopsEndpoint'));
        calloutMethod(postList, 'POST', CsUtils.getCredentialsValues('TomekPostWorkshopsEndpoint'));
        try {
            insert newCalloutLogs;
        } catch (DmlException error) {
            System.debug(error.getMessage());
        }
    }

    global void finish(Database.BatchableContext bc) {
        if (!newCalloutLogs.isEmpty()) {
            List<User> userList = new List<User>();
            userList = [SELECT Id,Email,IsActive FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = True] ;
            List<String> toAddress = new List<String>();
            for (User u : userList) {
                toAddress.add(u.Email);
            }
            Datetime now = Datetime.now();
            Integer offset = UserInfo.getTimezone().getOffset(now);
            Datetime local = now.addSeconds(offset / 1000);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddress);
            mail.setSubject('Repeats Callouts');
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody
                    ('The batch Apex job completed on  ' + local + ',\n' +
                            'Number Of Processed Logs : ' + newCalloutLogs.size() + '\n' +
                            'Number Of Success : ' + numberOfSuccess + '\n' +
                            'Number Of Fails : ' + numberOfFails);
            System.debug('body-->' + mail.plainTextBody);
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            } catch (Exception error) {
                System.debug(error.getMessage());
            }
        }
    }

    public void calloutMethod(List<Callout_Log__c> logs, String method, String endpoint) {
        List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop> tomeksWorkshops = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>();
        String idsToDelete = '';
        String responseBody = '';
        List<Workshop__c> workshopsToUpsert = new List<Workshop__c>();
        try {
            if (method == 'POST') {
                for (Callout_Log__c log : logs) {
                    tomeksWorkshops.add((CsTomeksWorkshopsRestController.WrappedTomeksWorkshop) JSON.deserialize(log.Request_Body__c, CsTomeksWorkshopsRestController.WrappedTomeksWorkshop.class));
                }
                responseBody = new CsTomeksWorkshopsRestHandler().createRequest(endpoint, method, tomeksWorkshops);
            } else {
                for (Callout_Log__c log : logs) {
                    idsToDelete += log.Parent_External_Id__c + ',';
                }
                responseBody = new CsTomeksWorkshopsRestHandler().createRequest(endpoint + idsToDelete.removeEnd(','), method, null);
            }
            List<String> responseStatusList = (List<String>) JSON.deserialize(responseBody, List<String>.class);
            for (Integer i = 0; i < responseStatusList.size(); i++) {
                List<String> responseFromTomek = responseStatusList.get(i).split(',');
                if (responseFromTomek.get(0) == System.Label.Status_Success) {
                    if (method == 'POST') workshopsToUpsert.add(new Workshop__c(Id = logs.get(i).Name, Is_Synchronized__c = true, External_Id__c = responseFromTomek.get(1)));
                    Callout_Log__c newLog = new Callout_Log__c(Name = logs.get(i).Name,
                            Parent_External_Id__c = responseFromTomek.get(1),
                            Endpoint__c = endpoint,
                            Number_Of_Repeats__c = logs.get(i).Number_Of_Repeats__c + 1,
                            Operation_Type__c = logs.get(i).Operation_Type__c,
                            Request_Body__c = logs.get(i).Request_Body__c,
                            Callout_Response__c = responseFromTomek.get(1),
                            Callout_Status__c = System.Label.Status_Success);
                    newCalloutLogs.add(newLog);
                    numberOfSuccess++;
                } else {
                    Callout_Log__c newLog = new Callout_Log__c(Name = logs.get(i).Name,
                            Parent_External_Id__c = responseFromTomek.get(1),
                            Endpoint__c = endpoint,
                            Number_Of_Repeats__c = logs.get(i).Number_Of_Repeats__c + 1,
                            Operation_Type__c = logs.get(i).Operation_Type__c,
                            Request_Body__c = logs.get(i).Request_Body__c,
                            Callout_Response__c = responseFromTomek.get(2),
                            Callout_Status__c = System.Label.Status_Error);
                    newCalloutLogs.add(newLog);
                    numberOfFails++;
                }
            }
            if (!workshopsToUpsert.isEmpty()) update workshopsToUpsert;
        } catch (Exception error) {
            for (Callout_Log__c log : logs) {
                Callout_Log__c newLog = new Callout_Log__c(Name = log.Name,
                        Parent_External_Id__c = log.Parent_External_Id__c,
                        Endpoint__c = endpoint,
                        Number_Of_Repeats__c = log.Number_Of_Repeats__c + 1,
                        Operation_Type__c = log.Operation_Type__c,
                        Request_Body__c = log.Request_Body__c,
                        Callout_Response__c = error.getMessage(),
                        Callout_Status__c = System.Label.Status_Error);
                newCalloutLogs.add(newLog);
                numberOfFails++;
            }
        }
    }
}