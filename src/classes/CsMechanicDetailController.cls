public with sharing class CsMechanicDetailController {

    public Workshop__c formWorkshopController { get; set; }
    public Contract__c formContractController { get; set; }
    private Mechanic__c formMechanicController { get; set; }
    public Workshop__c workshopChoosen { get; set; }
    private Contract__c contractToInsert;
    public List<Workshop__c> workshopsSearchResultList;
    private String workshopsQuery;
    private BH_SoqlQueryBuilder queryBuilder;
    public String sortField { get; set; }
    public String sortDirection { get; set; }
    public Boolean ifWorkshopSectionReady { get; set; }
    public Boolean ifContractSectionReady { get; set; }
    public PageReference pageReference;
    public String hirePopupName { get; set; }

    public CsMechanicDetailController(ApexPages.StandardController controller) {
        this.formMechanicController = (Mechanic__c) controller.getRecord();
        this.formWorkshopController = new Workshop__c();
        this.formContractController = new Contract__c();
        this.workshopChoosen = new Workshop__c();
        this.workshopsSearchResultList = new List<Workshop__c>();
        this.queryBuilder = new BH_SoqlQueryBuilder();
        this.contractToInsert = new Contract__c();
        this.ifWorkshopSectionReady = false;
        this.ifContractSectionReady = false;
        this.sortDirection = 'DESC';
        hirePopupName = String.format(System.Label.Mechanic_Hire_Label, new List<String>{
                formMechanicController.Full_Name__c
        });
    }

    public PageReference deleteMechanic() {
        delete formMechanicController;
        pageReference = new PageReference('/' + SObjectType.Mechanic__c.getKeyPrefix() + '/o');
        pageReference.setRedirect(true);
        return pageReference;
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

    public PageReference clear() {
        clearData();
        formWorkshopController.clear();
        sortField = null;
        workshopChoosen.clear();
        ifContractSectionReady = false;
        return null;
    }

    public PageReference cancel() {
        clearData();
        formWorkshopController.clear();
        ifContractSectionReady = false;
        return null;
    }

    private void clearData() {
        workshopsSearchResultList.clear();
        ifWorkshopSectionReady = false;
        formContractController.clear();
        queryBuilder.clear();
    }

    public void search() {
        if (!String.isBlank(formWorkshopController.Name)) {
            clearData();
            if (String.isBlank(sortField)) sortField = 'Name';
            queryBuilder.addResultField('Name').
                    addResultField('City__c').
                    addResultField('Country__c').
                    addTableName('Workshop__c').
                    addSearchFieldWithValue('Name', formWorkshopController.Name).
                    addSearchFieldWithValue('City__c', formWorkshopController.City__c).
                    addSearchFieldWithValue('Country__c', formWorkshopController.Country__c).
                    addSortField(sortField).
                    addSortOrder(sortDirection).
                    build();
            workshopsQuery = queryBuilder.getQueryString();
            workshopsSearchResultList = Database.query(workshopsQuery);
            if (workshopsSearchResultList.size() > 0) ifWorkshopSectionReady = true;
            sortDirection = (sortDirection.equals('ASC')) ? 'DESC' : 'ASC';
        } else {
            formWorkshopController.addError(String.format(System.Label.Required_Input_Field_Error, new List<String>{
                    Schema.getGlobalDescribe().get('Workshop__c').getDescribe().fields.getMap().get('Name').getDescribe().getLabel()
            }));
        }
    }

    public PageReference hire() {
        pageReference = new ApexPages.StandardController(formMechanicController).view();
        pageReference.setRedirect(true);
        contractToInsert.Mechanic__c = formMechanicController.Id;
        contractToInsert.Workshop__c = workshopChoosen.Id;
        contractToInsert.Start_Date__c = formContractController.Start_Date__c;
        if (formContractController != null) {
            contractToInsert.End_Date__c = formContractController.End_Date__c;
        }
        try {
            insert contractToInsert;
        } catch (DmlException error) {
            return null;
        }
        return pageReference;
    }

    public PageReference choose() {
        ifContractSectionReady = true;
        for (Workshop__c workshop : workshopsSearchResultList) {
            if (workshop.Id == workshopChoosen.Id) {
                workshopChoosen = workshop.clone(true);
                break;
            }
        }
        return null;
    }
}