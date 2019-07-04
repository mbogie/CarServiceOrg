public with sharing class CsMechanicEditController {
    private Mechanic__c mechanicController;

    public CsMechanicEditController(ApexPages.StandardController controller) {
        this.mechanicController = (Mechanic__c) controller.getRecord();
    }

    public PageReference cancel() {
        PageReference pageReference = new ApexPages.StandardController(mechanicController).view();
        pageReference.setRedirect(true);
        return pageReference;
    }
    public PageReference save() {
        update mechanicController;
        PageReference pageReference = new ApexPages.StandardController(mechanicController).view();
        pageReference.setRedirect(true);
        return pageReference;
    }
}