public with sharing class CsMechanicSearchController {

    public Mechanic__c mechanicPageFormController { get; set; }
    private List<Mechanic__c> mechanicsSearchResultList;
    private String sortField;
    private String sortDirection = 'DESC';
    private BH_SoqlQueryBuilder queryBuilder;
    public Boolean isResultListNotEmpty { get; set; }
    private PageReference pageReference;

    public CsMechanicSearchController(ApexPages.StandardController controller) {
        this.mechanicPageFormController = (Mechanic__c) controller.getRecord();
        this.queryBuilder = new BH_SoqlQueryBuilder();
        this.mechanicsSearchResultList = new List<Mechanic__c>();
        this.isResultListNotEmpty = false;
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

    public void clearPage() {
        mechanicPageFormController = new Mechanic__c();
        mechanicsSearchResultList.clear();
        queryBuilder.clear();
        sortField = null;
        isResultListNotEmpty = false;
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

    public void searchMechanic() {
        if (!(String.isBlank(mechanicPageFormController.Name))) {
            if (String.isBlank(sortField)) sortField = 'Full_Name__c';
            queryBuilder.clear();
            mechanicsSearchResultList.clear();
            queryBuilder.addResultField('Full_Name__c').
                    addResultField('Email__c').
                    addResultField('Country__c').
                    addTableName('Mechanic__c').
                    addSearchFieldStartsWithValue('Name', mechanicPageFormController.Name).
                    addSearchFieldStartsWithValue('First_Name__c', mechanicPageFormController.First_Name__c).
                    addSearchFieldStartsWithValue('Country__c', mechanicPageFormController.Country__c).
                    addSearchFieldStartsWithValue('Email__c', mechanicPageFormController.Email__c).
                    addSortField(sortField).
                    addSortOrder(sortDirection).
                    build();
            mechanicsSearchResultList = Database.query(queryBuilder.getQueryString());
            if (mechanicsSearchResultList.size() == 0) sortField = null; else isResultListNotEmpty = true;
            sortDirection = (sortDirection.equals('ASC')) ? 'DESC' : 'ASC';
        } else {
            mechanicPageFormController.addError(String.format(System.Label.Required_Input_Field_Error, new List<String>{
                    Schema.getGlobalDescribe().get('Mechanic__c').getDescribe().fields.getMap().get('Name').getDescribe().getLabel()
            }));
        }
    }

    public PageReference exportToXml(){
        pageReference = Page.CsCopyResultMechanicListToXml;
        pageReference.setRedirect(false);
        return  pageReference;
    }

    public PageReference exportToCsv(){
        pageReference = Page.CsCopyResultMechanicListToCsv;
        pageReference.setRedirect(false);
        return pageReference;
    }
}
