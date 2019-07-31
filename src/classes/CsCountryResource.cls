@RestResource(urlMapping='/workshops/countries')
global class CsCountryResource {

    @HttpGet
    global static List<String> getCountryList(){
        List<String> countries = new List<String>();
        Schema.DescribeFieldResult describeFieldResult = Workshop__c.Country__c.getDescribe();
        Schema.sObjectField sObjectField = describeFieldResult.getSObjectField();
        List<PicklistEntry> entries = sObjectField.getDescribe().getPicklistValues();
        for (PicklistEntry picklistEntry : entries) {
            countries.add(picklistEntry.getValue());
        }
        return countries;
    }
}