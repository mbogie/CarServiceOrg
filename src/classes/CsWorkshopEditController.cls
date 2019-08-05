public with sharing class CsWorkshopEditController {

    public Workshop__c workshopFormPageController { get; set; }
    private PageReference pageReference;

    public CsWorkshopEditController(ApexPages.StandardController controller) {
        this.workshopFormPageController = (Workshop__c) controller.getRecord();
    }

    public PageReference save() {
        workshopFormPageController.Is_Synchronized__c = false;
        try {
            update workshopFormPageController;
            System.debug('edited-->' +workshopFormPageController);
        } catch (DmlException err) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage()));
            return null;
        }
        pageReference = new ApexPages.StandardController(workshopFormPageController).view();
        pageReference.setRedirect(true);
        return pageReference;
    }
}