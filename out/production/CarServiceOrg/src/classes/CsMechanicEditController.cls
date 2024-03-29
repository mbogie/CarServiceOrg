public with sharing class CsMechanicEditController {
    private Mechanic__c mechanicPageFormController;
    private PageReference pageReference;
    private List<sObject> duplicateRecords;

    public CsMechanicEditController(ApexPages.StandardController controller) {
        this.mechanicPageFormController = (Mechanic__c) controller.getRecord();
        this.duplicateRecords = new List<sObject>();
    }

    public PageReference cancel() {
        pageReference = new ApexPages.StandardController(mechanicPageFormController).view();
        pageReference.setRedirect(true);
        return pageReference;
    }

    public PageReference save() {
        Database.SaveResult saveResult = Database.update(mechanicPageFormController, false);
        if (!saveResult.isSuccess()) {
            for (Database.Error error : saveResult.getErrors()) {
                if (error instanceof Database.DuplicateError) {
                    Database.DuplicateError duplicateError = (Database.DuplicateError) error;
                    Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate Error: ' + duplicateResult.getErrorMessage()));
                    this.duplicateRecords = new List<sObject>();
                    Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
                    Datacloud.MatchResult matchResult = matchResults[0];
                    Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
                    for (Datacloud.MatchRecord matchRecord : matchRecords) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Match Record: ' + matchRecord.getRecord()));
                        this.duplicateRecords.add(matchRecord.getRecord());
                    }
                }
            }
            return null;
        }
        pageReference = new ApexPages.StandardController(mechanicPageFormController).view();
        pageReference.setRedirect(true);
        return pageReference;
    }
}