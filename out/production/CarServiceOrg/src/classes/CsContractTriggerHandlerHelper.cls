public with sharing class CsContractTriggerHandlerHelper {

    public static void overlappingError(List<Contract__c> contractsFromTrigger, Map<String, List<Contract__c>> contractsMap) {

        List<Contract__c> similarContracts = new List<Contract__c>();
        String mechanicWorkshopCrossId = '';
        Boolean error = false;
        String errorMessage = '';
        String lineBreaker = '<br/>';

        for (Contract__c triggerContract : contractsFromTrigger) {
            error = false;
            errorMessage = System.Label.Error_Overlapping;
            mechanicWorkshopCrossId = triggerContract.Mechanic__c + '' + triggerContract.Workshop__c;
            if (contractsMap.containsKey(mechanicWorkshopCrossId)) {
                similarContracts = contractsMap.get(mechanicWorkshopCrossId);
                for (Contract__c agreementsContract : similarContracts) {
                    if ((triggerContract.Start_Date__c != null) && (triggerContract.End_Date__c != null) && (agreementsContract.End_Date__c != null)) {
                        if (triggerContract.Start_Date__c <= agreementsContract.End_Date__c && triggerContract.End_Date__c >= agreementsContract.Start_Date__c) {
                            errorMessage += lineBreaker + String.format(System.Label.Error_Overlapping_From_To, new List<String>{
                                    agreementsContract.Name, agreementsContract.Start_Date__c.format(), agreementsContract.End_Date__c.format()
                            });
                            error = true;
                        }
                    }
                    if ((triggerContract.End_Date__c == null) && (agreementsContract.End_Date__c != null)) {
                        if ((triggerContract.Start_Date__c <= agreementsContract.Start_Date__c || triggerContract.Start_Date__c <= agreementsContract.End_Date__c)) {
                            errorMessage += lineBreaker + String.format(System.Label.Error_Overlapping_From_To, new List<String>{
                                    agreementsContract.Name, agreementsContract.Start_Date__c.format(), agreementsContract.End_Date__c.format()
                            });
                            error = true;
                        }
                    }
                    if ((triggerContract.End_Date__c == null) && (agreementsContract.End_Date__c == null)) {
                        errorMessage += lineBreaker + String.format(System.Label.Error_Overlapping_From, new List<String>{
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