trigger OverlappingError on Contract__c (before insert, before update) {

    List<Contract__c> contList = new List<Contract__c>();
    String query = 'SELECT Name, Start_Date__c, End_Date__c FROM Contract__c WHERE ';
    String errorMessage = 'Overlapping Dates:';
    Boolean error = false;

    for (Contract__c triggerContract : Trigger.new) {
        error = false;
        if (Trigger.isUpdate) {
            query = 'SELECT Name, Start_Date__c, End_Date__c FROM Contract__c WHERE ';
            query += 'Mechanic__r.id = \'' + triggerContract.Mechanic__c + '\' AND Workshop__r.Id = \'' + triggerContract.Workshop__c + '\' AND id != \'' + triggerContract.Id + '\' ORDER BY Start_Date__c';
        }
        if (Trigger.isInsert) {
            query = 'SELECT Name, Start_Date__c, End_Date__c FROM Contract__c WHERE ';
            query += 'Mechanic__r.id = \'' + triggerContract.Mechanic__c + '\' AND Workshop__r.Id = \'' + triggerContract.Workshop__c + '\' ORDER BY Start_Date__c';
        }
        System.debug(query);
        contList = Database.query(query);
        for (Contract__c AgreementsContract : contList) {
            if ((triggerContract.Start_Date__c != null) && (triggerContract.End_Date__c != null) && (AgreementsContract.End_Date__c != null)) {
                if (triggerContract.Start_Date__c <= AgreementsContract.End_Date__c && triggerContract.End_Date__c >= AgreementsContract.Start_Date__c) {
                    errorMessage += AgreementsContract.Name + ': ' + AgreementsContract.Start_Date__c.format() + ' - ' + AgreementsContract.End_Date__c.format() + ', ';
                    error = true;
                }
            }
            if ((triggerContract.End_Date__c == null) && (AgreementsContract.End_Date__c != null)) {
                if ((triggerContract.Start_Date__c <= AgreementsContract.Start_Date__c || triggerContract.Start_Date__c <= AgreementsContract.End_Date__c)) {
                    errorMessage += AgreementsContract.Name + ': ' + AgreementsContract.Start_Date__c.format() + ' - ' + AgreementsContract.End_Date__c.format() + ', ';
                    error = true;
                }
            }
            if ((triggerContract.End_Date__c == null) && (AgreementsContract.End_Date__c == null)) {
                errorMessage += AgreementsContract.Name + ': ' + AgreementsContract.Start_Date__c.format() + ' - without notice' + ', ';
                error = true;
            }
        }
        if (error) {
            triggerContract.addError(errorMessage.removeEnd(', '), false);
        }
    }
}