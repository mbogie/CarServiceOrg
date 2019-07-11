public with sharing class CsMechanicSearchController {

    public Mechanic__c mechanicPageFormController { get; set; }
    public List<Mechanic__c> mechanicsSearchResultList { get; private set; }
    public String mechanicSearchStringToExport { get; set; }
    public List<Mechanic__c> mechanicsSearchResultListToShow { get; set; }
    private String sortField;
    private String sortDirection = 'DESC';
    private BH_SoqlQueryBuilder queryBuilder;
    public Boolean isResultListNotEmpty { get; set; }
    private PageReference pageReference;
    public Integer recordsOnPage { get; set; }
    public Integer pageNumber { get; set; }
    public Boolean isMechanicResultListReady { get; set; }
    public Boolean isMechanicResultListHasNext { get; set; }
    public Boolean isMechanicResultListHasPrevious { get; set; }
    public ApexPages.StandardSetController resultListController { get; set; }
    private static final String separator = '||';
    public String mechanicResultListJson { get; set; }
    List<CsMechanicJsonWrapper> wrappedMechanicList { get; set; }

    public CsMechanicSearchController(ApexPages.StandardController controller) {
        this.mechanicPageFormController = (Mechanic__c) controller.getRecord();
        this.queryBuilder = new BH_SoqlQueryBuilder();
        this.mechanicsSearchResultList = new List<Mechanic__c>();
        this.isResultListNotEmpty = false;
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
        mechanicsSearchResultListToShow = new List<Mechanic__c>();
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
        if (mechanicsSearchResultList.size() == 0) sortField = null; else {
            resultListController = new ApexPages.StandardSetController(mechanicsSearchResultList);
            isResultListNotEmpty = true;
            recordsOnPage = mechanicsSearchResultList.size();
            resultListController.setPageSize(recordsOnPage);
            setDataToShow();
        }
        sortDirection = (sortDirection.equals('ASC')) ? 'DESC' : 'ASC';
    }

    public void next() {
        resultListController.next();
        setDataToShow();
    }

    public void previous() {
        resultListController.previous();
        setDataToShow();
    }

    public void setRecordOnPage() {
        resultListController.setPageSize(recordsOnPage);
        setDataToShow();
    }

    public void setDataToShow() {
        mechanicsSearchResultListToShow = (List<Mechanic__c>) resultListController.getRecords();
        isMechanicResultListHasNext = resultListController.getHasNext();
        isMechanicResultListHasPrevious = resultListController.getHasPrevious();
        pageNumber = resultListController.getPageNumber();
    }

    public PageReference exportToXml() {
        pageReference = Page.CsCopyResultMechanicListToXml;
        pageReference.setRedirect(false);
        return pageReference;
    }

    public PageReference exportToCsv() {
        mechanicSearchStringToExport = prepareStringToCsv(getFieldName('Mechanic__c','Full_Name__c'))+ separator + prepareStringToCsv(getFieldName('Mechanic__c','Email__c')) +separator + prepareStringToCsv(getFieldName('Mechanic__c','Country__c'))+'\n';
        for (Mechanic__c mechanic : mechanicsSearchResultList) {
            mechanicSearchStringToExport += prepareStringToCsv(mechanic.Full_Name__c) + separator + prepareStringToCsv(mechanic.Email__c) + separator + prepareStringToCsv(mechanic.Country__c) + '\n';
        }
        mechanicSearchStringToExport.removeEnd('\n');
        pageReference = Page.CsCopyResultMechanicListToCsv;
        pageReference.setRedirect(false);
        return pageReference;
    }

    private String getFieldName(String obj, String field){
        return Schema.getGlobalDescribe().get(obj).getDescribe().fields.getMap().get(field).getDescribe().getLabel();
    }

    private String prepareStringToCsv(Object obj) {
        if (obj != null) return '\'' + String.valueOf(obj).escapeCsv() + '\''; else return '';
    }

    public PageReference saveToJson(){
        wrappedMechanicList = new List<CsMechanicJsonWrapper>();
        for(Mechanic__c mechanic : mechanicsSearchResultList){
            wrappedMechanicList.add(CsMechanicJsonWrapper.mechanicToWrapper(mechanic));
        }
        pageReference = Page.CsCopyMechanicListToJson; 
        mechanicResultListJson = JSON.serializePretty(wrappedMechanicList);
        pageReference.setRedirect(false);
        return pageReference;
    }
}