trigger OverlappingError on Contract__c (before insert, before update) {	
	 List<Contract__c> conList = new List<Contract__c>();
    
        conList = [SELECT Mechanic__r.Id, Start_Date__C, End_Date__C FROM Contract__c];
}