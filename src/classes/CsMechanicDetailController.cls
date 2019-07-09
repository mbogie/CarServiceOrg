public with sharing class CsMechanicDetailController {

    public Workshop__c workshopPageFormController { get; set; }
    public Contract__c contractPageFormController { get; set; }
    public Mechanic__c mechanicPageFormController { get; set; }
    public Workshop__c workshopChoosen { get; set; }
    private Contract__c contractToInsert;
    public List<Workshop__c> workshopsSearchResultList { get; private set; }
    private String workshopsQuery;
    private BH_SoqlQueryBuilder queryBuilder;
    public String sortField { get; set; }
    public String sortDirection { get; set; }
    public Boolean isWorkshopSectionReady { get; set; }
    public Boolean isContractSectionReady { get; set; }
    private PageReference pageReference;
    public String hirePopupLabel;

    public CsMechanicDetailController(ApexPages.StandardController controller) {
        this.mechanicPageFormController = (Mechanic__c) controller.getRecord();
        this.workshopPageFormController = new Workshop__c();
        this.contractPageFormController = new Contract__c();
        this.workshopChoosen = new Workshop__c();
        this.workshopsSearchResultList = new List<Workshop__c>();
        this.queryBuilder = new BH_SoqlQueryBuilder();
        this.isWorkshopSectionReady = false;
        this.isContractSectionReady = false;
        this.sortDirection = 'DESC';
    }

    public String getHirePopupLabel() {
        return hirePopupLabel = String.format(System.Label.Mechanic_Hire_Label, new List<String>{
                mechanicPageFormController.Full_Name__c
        });
    }

    public PageReference deleteMechanic() {
        delete mechanicPageFormController;
        pageReference = new PageReference('/' + SObjectType.Mechanic__c.getKeyPrefix() + '/o');
        pageReference.setRedirect(true);
        return pageReference;
    }

    public void sortByName() {
        sortField = 'Name';
        search();
    }

    public void sortByCity() {
        sortField = 'City__c';
        search();
    }

    public void sortByCountry() {
        sortField = 'Country__c';
        search();
    }

    public void clear() {
        clearData();
        workshopPageFormController = new Workshop__c();
        sortField = null;
        workshopChoosen.clear();
        isContractSectionReady = false;
    }

    public void cancel() {
        clearData();
        workshopPageFormController.clear();
        isContractSectionReady = false;
        workshopChoosen.clear();
    }

    private void clearData() {
        workshopsSearchResultList.clear();
        isWorkshopSectionReady = false;
        contractPageFormController = new Contract__c();
        queryBuilder.clear();
    }

    public void search() {
        if (String.isBlank(sortField)) sortField = 'Name';
        queryBuilder.addResultField('Name').
                addResultField('City__c').
                addResultField('Country__c').
                addTableName('Workshop__c').
                addSearchFieldWithValue('Name', workshopPageFormController.Name).
                addSearchFieldWithValue('City__c', workshopPageFormController.City__c).
                addSearchFieldWithValue('Country__c', workshopPageFormController.Country__c).
                addSortField(sortField).
                addSortOrder(sortDirection).
                build();
        workshopsQuery = queryBuilder.getQueryString();
        workshopsSearchResultList = Database.query(workshopsQuery);
        if (workshopsSearchResultList.size() > 0) isWorkshopSectionReady = true;
        sortDirection = (sortDirection.equals('ASC')) ? 'DESC' : 'ASC';
    }

    public PageReference hire() {
        contractToInsert = new Contract__c();
        pageReference = new ApexPages.StandardController(mechanicPageFormController).view();
        pageReference.setRedirect(true);
        contractToInsert.Mechanic__c = mechanicPageFormController.Id;
        contractToInsert.Workshop__c = workshopChoosen.Id;
        contractToInsert.Start_Date__c = contractPageFormController.Start_Date__c;
        contractToInsert.End_Date__c = contractPageFormController.End_Date__c;
        try {
            insert contractToInsert;
        } catch (DmlException error) {
            System.debug(error.getMessage());
            return null;
        }
        return pageReference;
    }

    public PageReference choose() {
        isContractSectionReady = true;
        for (Workshop__c workshop : workshopsSearchResultList) {
            if (workshop.Id == workshopChoosen.Id) {
                workshopChoosen = workshop.clone(true);
                break;
            }
        }
        return null;
    }
}