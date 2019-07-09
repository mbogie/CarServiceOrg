public with sharing class CsMechanicEditController {
    private Mechanic__c mechanicPageFormController;
    private PageReference pageReference;

    public CsMechanicEditController(ApexPages.StandardController controller) {
        this.mechanicPageFormController = (Mechanic__c) controller.getRecord();
    }

    public PageReference cancel() {
        pageReference = new ApexPages.StandardController(mechanicPageFormController).view();
        pageReference.setRedirect(true);
        return pageReference;
    }
    public PageReference save() {
        update mechanicPageFormController;
        pageReference = new ApexPages.StandardController(mechanicPageFormController).view();
        pageReference.setRedirect(true);
        return pageReference;
    }
}