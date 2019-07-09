trigger OverlappingError on Contract__c (before insert, before update) {

    List<Contract__c> contList = new List<Contract__c>();
    String query = 'SELECT Name, Start_Date__c, End_Date__c FROM Contract__c WHERE ';
    String errorMessage = 'Overlapping Dates:';
    Boolean error = false;

    for (Contract__c contract : Trigger.new) {
        if (Trigger.isUpdate) {
            query += 'Mechanic__r.id = \'' + contract.Mechanic__c + '\' AND Workshop__r.Id = \'' + contract.Workshop__c + '\' AND id != \'' + contract.Id + '\' ORDER BY Start_Date__c';
        }
        if (Trigger.isInsert) {
            query += 'Mechanic__r.id = \'' + contract.Mechanic__c + '\' AND Workshop__r.Id = \'' + contract.Workshop__c + '\' ORDER BY Start_Date__c';
        }
        contList = Database.query(query);
        for (Contract__c con : contList) {
            if ((contract.Start_Date__c != null) && (contract.End_Date__c != null) && (con.End_Date__c != null)) {
                if (contract.Start_Date__c <= con.End_Date__c && contract.End_Date__c >= con.Start_Date__c) {
                    errorMessage += con.Name + ': ' + con.Start_Date__c.format() + ' - ' + con.End_Date__c.format() + ', ';
                    error = true;
                }
            }
            if ((contract.End_Date__c == null) && (con.End_Date__c != null)) {
                if ((contract.Start_Date__c <= con.Start_Date__c || contract.Start_Date__c <= con.End_Date__c))
                    errorMessage += con.Name + ': ' + con.Start_Date__c.format() + ' - ' + con.End_Date__c.format() + ', ';
                error = true;
            }
            if ((contract.End_Date__c == null) && (con.End_Date__c == null)) {
                errorMessage += con.Name + ': ' + con.Start_Date__c.format() + '- without notice' + ', ';
                error = true;
            }
        }
        if (error) {
            contract.addError(errorMessage.removeEnd(', '), false);
        }
    }
}