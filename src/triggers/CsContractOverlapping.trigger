trigger CsContractOverlapping on Contract__c (before insert, before update) {

    if(CsUtils.isContractOverlappingEnabled()) {

        List<Contract__c> contractsFromTrigger = Trigger.new;
        List<Contract__c> existingContracts = new List<Contract__c>();
        List<Contract__c> similarContracts = new List<Contract__c>();
        Map<String, List<Contract__c>> contractsMap = new Map<String, List<Contract__c>>();
        String mechanicWorkshopCrossId = '';
        Boolean error = false;
        String errorMessage = '';

        Set<Id> mechanicsIdFromTrigger = new Set<Id>();
        Set<Id> workshopsIdFromTrigger = new Set<Id>();

        for (Contract__c newContract : contractsFromTrigger) {
            mechanicsIdFromTrigger.add(newContract.Mechanic__c);
            workshopsIdFromTrigger.add(newContract.Workshop__c);
            mechanicWorkshopCrossId = newContract.Mechanic__c + '' + newContract.Workshop__c;
            contractsMap.put(mechanicWorkshopCrossId, new List<Contract__c>());
        }

        existingContracts = [
                SELECT Name, Mechanic__c, Workshop__c, Start_Date__c, End_Date__c
                FROM Contract__c
                WHERE Mechanic__c IN :mechanicsIdFromTrigger AND Workshop__c IN :workshopsIdFromTrigger AND Id NOT IN :Trigger.new
        ];

        for (Contract__c oldContract : existingContracts) {
            mechanicWorkshopCrossId = oldContract.Mechanic__c + '' + oldContract.Workshop__c;
            if (contractsMap.containsKey(mechanicWorkshopCrossId)) {
                contractsMap.get(mechanicWorkshopCrossId).add(oldContract);
            }
        }

        for (Contract__c triggerContract : contractsFromTrigger) {
            error = false;
            errorMessage = System.Label.Error_Overlapping;
            mechanicWorkshopCrossId = triggerContract.Mechanic__c + '' + triggerContract.Workshop__c;
            if (contractsMap.containsKey(mechanicWorkshopCrossId)) {
                similarContracts = contractsMap.get(mechanicWorkshopCrossId);
                for (Contract__c agreementsContract : similarContracts) {
                    if ((triggerContract.Start_Date__c != null) && (triggerContract.End_Date__c != null) && (agreementsContract.End_Date__c != null)) {
                        if (triggerContract.Start_Date__c <= agreementsContract.End_Date__c && triggerContract.End_Date__c >= agreementsContract.Start_Date__c) {
                            errorMessage += String.format(System.Label.Error_Overlapping_From_To, new List<String>{
                                    agreementsContract.Name, agreementsContract.Start_Date__c.format(), agreementsContract.End_Date__c.format()
                            });
                            error = true;
                        }
                    }
                    if ((triggerContract.End_Date__c == null) && (agreementsContract.End_Date__c != null)) {
                        if ((triggerContract.Start_Date__c <= agreementsContract.Start_Date__c || triggerContract.Start_Date__c <= agreementsContract.End_Date__c)) {
                            errorMessage += String.format(System.Label.Error_Overlapping_From_To, new List<String>{
                                    agreementsContract.Name, agreementsContract.Start_Date__c.format(), agreementsContract.End_Date__c.format()
                            });
                            error = true;
                        }
                    }
                    if ((triggerContract.End_Date__c == null) && (agreementsContract.End_Date__c == null)) {
                        errorMessage += String.format(System.Label.Error_Overlapping_From, new List<String>{
                                agreementsContract.Name, agreementsContract.Start_Date__c.format()
                        });
                        error = true;
                    }
                }
                if (error) {
                    triggerContract.addError(errorMessage.removeEnd(', '), false);
                }
            } else {
                contractsMap.put(mechanicWorkshopCrossId, new List<Contract__c>());
                contractsMap.get(mechanicWorkshopCrossId).add(triggerContract);
            }
        }
    }
}