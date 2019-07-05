public with sharing class CsMechanicSearchController {

    private Mechanic__c mechanicController;
    private List<Mechanic__c> mechanicsSearchResultList;
    private String sortField;
    private String sortDirection = 'DESC';
    private BH_SoqlQueryBuilder queryBuilder;

    public CsMechanicSearchController(ApexPages.StandardController controller) {
        this.mechanicController = (Mechanic__c) controller.getRecord();
        this.queryBuilder = new BH_SoqlQueryBuilder();
        this.mechanicsSearchResultList = new List<Mechanic__c>();
    }

    public List<Mechanic__c> getMechanicsSearchResultList() {
        return mechanicsSearchResultList;
    }

    public String getSortField() {
        return sortField;
    }

    public String getSortDirection() {
        return sortDirection;
    }

    public PageReference clearPage() {
        mechanicController.First_Name__c = null;
        mechanicController.Name = null;
        mechanicController.Email__c = null;
        mechanicController.Country__c = null;
        mechanicsSearchResultList.clear();
        queryBuilder.clear();
        sortField = null;
        return null;
    }

    public void sortByFullName() {
        sortField = 'Full_Name__c';
        searchMechanic();
    }

    public void sortByEmail() {
        sortField = 'Email__c';
        searchMechanic();
    }

    public void sortByCountry() {
        sortField = 'Country__c';
        searchMechanic();
    }

    public PageReference searchMechanic() {
        if (!(String.isBlank(mechanicController.Name))) {
            if (String.isBlank(sortField)) sortField = 'Full_Name__c';
            queryBuilder.clear();
            mechanicsSearchResultList.clear();
            queryBuilder.addResultField('Full_Name__c').
                    addResultField('Email__c').
                    addResultField('Country__c').
                    addTableName('Mechanic__c').
                    addSearchFieldStartsWithValue('Name', mechanicController.Name).
                    addSearchFieldStartsWithValue('First_Name__c', mechanicController.First_Name__c).
                    addSearchFieldStartsWithValue('Country__c', mechanicController.Country__c).
                    addSearchFieldStartsWithValue('Email__c', mechanicController.Email__c).
                    addSortField(sortField).
                    addSortOrder(sortDirection).
                    build();
            mechanicsSearchResultList = Database.query(queryBuilder.getQueryString());
            sortDirection = (sortDirection.equals('ASC')) ? 'DESC' : 'ASC';
        } else {
            mechanicController.Name.addError('Last Name is required');
        }
        return null;
    }
}