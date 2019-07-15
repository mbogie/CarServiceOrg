public with sharing class CsPublicSite {

    public List<Mechanic__c> randomMechanicList { get; set; }
    private Integer sqlListSize;
    private List<String> orderList;
    private String orderBy;
    private CsSoqlQueryBuilder queryBuilder;
    private Integer offset;
    private String sortOrder = 'ASC';

    public CsPublicSite() {
        sqlListSize = [SELECT COUNT() From Mechanic__c];
        orderList = new List<String>{
                'Name', 'First_Name__c', 'Email__c'
        };
        orderBy = orderList.get(Math.floor(Math.random() * orderList.size()).intValue());
        offset = Math.floor(Math.random() * (sqlListSize - 5)).intValue();
        randomMechanicList = setRandomList();
    }

    public List<Mechanic__c> setRandomList() {
        queryBuilder = new CsSoqlQueryBuilder();
        sortOrder = (sortOrder == 'ASC') ? 'DESC' : 'ASC';
        queryBuilder.addResultField('First_Name__c').
                addResultField('Name').
                addResultField('Email__c').
                addTableName('Mechanic__c').
                addSortField(orderBy).
                addSortOrder(sortOrder).
                addSortLimit(5).
                addOffset(offset).
                build();
        return Database.query(queryBuilder.getQueryString());
    }
}