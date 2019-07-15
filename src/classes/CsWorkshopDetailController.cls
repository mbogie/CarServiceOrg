public with sharing class CsWorkshopDetailController {

    public Workshop__c workshopFormPageController { get; set; }
    public CsLocationCallouts locationController;
    public double lat { get; set; }
    public double lon { get; set; }
    public List<Contract__c> agreementsForWorkshopPageFormController { get; set; }
    private CsSoqlQueryBuilder queryBuilder;
    public Contract__c editedContractInUse { get; set; }

    public CsWorkshopDetailController(ApexPages.StandardController controller) {
        this.workshopFormPageController = (Workshop__c) controller.getRecord();
        this.locationController = new CsLocationCallouts();
        this.locationController.setAddress(workshopFormPageController.Address__c, workshopFormPageController.City__c, workshopFormPageController.Country__c);
        this.locationController.newAccmethod();
        this.lat = locationController.getLat();
        this.lon = locationController.getLon();
        this.agreementsForWorkshopPageFormController = new List<Contract__c>();
        this.editedContractInUse = new Contract__c();
        refreshAgreementsList();
    }

    public void refreshAgreementsList() {
        queryBuilder = new CsSoqlQueryBuilder();
        queryBuilder.addResultField('Id').addResultField('Name').
                addResultField('Mechanic__r.Full_Name__c').
                addResultField('Start_Date__c').
                addResultField('End_Date__c').
                addTableName('Contract__c').
                addSearchFieldEqualsWithValue('Workshop__c', workshopFormPageController.Id).
                addSortField('Name').
                addSortOrder('DESC').
                build();
        agreementsForWorkshopPageFormController = Database.query(queryBuilder.getQueryString());
    }

    public void dismiss() {
        for (Contract__c contract : agreementsForWorkshopPageFormController) {
            if (editedContractInUse.Id == contract.Id) {
                editedContractInUse = contract.clone(true);
                break;
            }
        }
        if (editedContractInUse.Start_Date__c > System.today()) {
            try {
                delete editedContractInUse;
                refreshAgreementsList();
            } catch (DmlException error) {
                System.debug(error.getMessage());
            }
        } else {
            editedContractInUse.End_Date__c = System.today();
            try {
                update editedContractInUse;
                refreshAgreementsList();
            } catch (DmlException error) {
                System.debug(error.getMessage());
            }
        }
    }
}