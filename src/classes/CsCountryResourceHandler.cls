public with sharing class CsCountryResourceHandler {

    public static Map<String,String> getCountryList(){
        Map<String,String> mapOfCountries = new Map<String,String>();
        Schema.DescribeFieldResult describeFieldResult = Workshop__c.Country__c.getDescribe();
        Schema.sObjectField sObjectField = describeFieldResult.getSObjectField();
        List<PicklistEntry> entries = sObjectField.getDescribe().getPicklistValues();
        for (PicklistEntry picklistEntry : entries) {
            mapOfCountries.put(picklistEntry.getValue(),picklistEntry.getValue());
        }
        mapOfCountries.put('', System.Label.Select_Option_None);
        return mapOfCountries;
    }
}