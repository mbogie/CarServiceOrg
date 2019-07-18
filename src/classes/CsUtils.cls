public with sharing class CsUtils {

    public static User getCurrentUser(){
        return getUser(UserInfo.getUserId());
    }

    public static User getUser(String userId){
        List<User> userList = [SELECT Id, Username, Country__c FROM User WHERE Id = :userId];
        if(userList.isEmpty()){
            return null;
        }
        return userList[0];
    }

    public static Boolean isCsEnabledForCurrentUser(String csName){
        return isCsEnabledForGivenCountry(csName, getCurrentUser().Country__c);
    }

    public static Boolean isCsEnabledForGivenCountry(String csName, String country){
        Cs_Settings__c csItem = Cs_Settings__c.getInstance(csName);
        if(csItem == null){
            return false;
        }else{
            Set<String> splitValue = new Set<String>();
            splitValue.addAll(csItem.Value__c.split(','));
            return splitValue.contains(country);
        }
    }
}