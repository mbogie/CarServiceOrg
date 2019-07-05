public with sharing class CsMechanicDetailController {

    public Workshop__c workshopController { get; set; }
    public Contract__c contractController { get; set; }
    private Mechanic__c mechanicController { get; set; }
    public Workshop__c workshopChoosen { get; set; }
    private Contract__c contractToInsert;
    public List<Workshop__c> workshopsSearchResultList;
    public String selectedWorkshopId { get; set; }
    private String workshopsQuery;
    private BH_SoqlQueryBuilder queryBuilder;
    public String sortField { get; set; }
    public String sortDirection { get; set; }
    public Boolean workshopSectionReady { get; set; }
    public Boolean contractSectionReady { get; set; }
    public PageReference pageReference;

    public CsMechanicDetailController(ApexPages.StandardController controller) {
        this.mechanicController = (Mechanic__c) controller.getRecord();
        this.workshopController = new Workshop__c();
        this.contractController = new Contract__c();
        this.workshopChoosen = new Workshop__c();
        this.workshopsSearchResultList = new List<Workshop__c>();
        this.queryBuilder = new BH_SoqlQueryBuilder();
        this.contractToInsert = new Contract__c();
        this.workshopSectionReady = false;
        this.contractSectionReady = false;
        sortDirection = 'DESC';
    }

    public PageReference deleteM() {
        delete mechanicController;
        pageReference = new PageReference('/' + SObjectType.Mechanic__c.getKeyPrefix() + '/o');
        pageReference.setRedirect(true);
        return pageReference;
    }

    public PageReference clear() {
        this.workshopController.clear();
        this.workshopsSearchResultList.clear();
        sortField = null;
        this.workshopSectionReady = false;
        this.contractSectionReady = false;
        return null;
    }

    public List<Workshop__c> getWorkshopsSearchResultList() {
        return workshopsSearchResultList;
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

    public void search() {
        if (!String.isBlank(workshopController.Name)) {
            if (String.isBlank(sortField)) sortField = 'Name';
            selectedWorkshopId = null;
            workshopSectionReady = false;
            contractSectionReady = false;
            queryBuilder.clear();
            workshopsSearchResultList.clear();
            contractController.clear();
            queryBuilder.addResultField('Name').
                    addResultField('City__c').
                    addResultField('Country__c').
                    addTableName('Workshop__c').
                    addSearchFieldWithValue('Name', workshopController.Name);
            if (!String.isBlank(workshopController.City__c)) {
                queryBuilder.addSearchFieldWithValue('City__c', workshopController.City__c);
            }
            if (!String.isBlank(workshopController.Country__c)) {
                queryBuilder.addSearchFieldWithValue('Country__c', workshopController.Country__c);
            }
            queryBuilder.addSortField(sortField).
                    addSortOrder(sortDirection).
                    build();
            workshopsQuery = queryBuilder.getQueryString();
            this.workshopsSearchResultList = Database.query(workshopsQuery);
            if (workshopsSearchResultList.size() > 0) workshopSectionReady = true; else {
                workshopSectionReady = false;
                contractSectionReady = false;
            }
            sortDirection = (sortDirection.equals('ASC')) ? 'DESC' : 'ASC';
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'Name is required'));
            workshopController.Name.addError('Name is required');
        }
    }

    public PageReference hire() {
        pageReference = new ApexPages.StandardController(mechanicController).view();
        pageReference.setRedirect(true);
        contractToInsert.Mechanic__c = mechanicController.Id;
        contractToInsert.Workshop__c = workshopChoosen.Id;
        contractToInsert.Start_Date__c = contractController.Start_Date__c;
        if (contractController != null) {
            contractToInsert.End_Date__c = contractController.End_Date__c;
        }
        try {
            insert contractToInsert;
        } catch (DmlException error) {
            return null;
        }
        return pageReference;
    }

    public PageReference cancel() {
        workshopsSearchResultList.clear();
        workshopController.clear();
        contractController.clear();
        workshopChoosen.clear();
        this.workshopSectionReady = false;
        this.contractSectionReady = false;
        return null;
    }

    public PageReference choose() {
        contractSectionReady = true;
        workshopChoosen = [SELECT Id, Name FROM Workshop__c WHERE Id = :selectedWorkshopId].get(0);
        return null;
    }
}