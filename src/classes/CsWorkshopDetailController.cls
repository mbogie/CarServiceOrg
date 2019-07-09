public with sharing class CsWorkshopDetailController {
    public Workshop__c workshopPageController { get; set; }
    public LocationCallouts locationController;
    public double lat { get; set; }
    public double lon { get; set; }

    public CsWorkshopDetailController(ApexPages.StandardController controller) {
        this.workshopPageController = (Workshop__c) controller.getRecord();
        lat = null;
        lon = null;
        locationController = new LocationCallouts();
        locationController.setAddress(workshopPageController.Address__c, workshopPageController.City__c, workshopPageController.Country__c);
        locationController.newAccmethod();
        lat = locationController.getLat();
        lon = locationController.getLon();
    }
}