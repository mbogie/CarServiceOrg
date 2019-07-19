public with sharing class CsUtils {

    public static User getCurrentUser() {
        return getUser(UserInfo.getUserId());
    }

    public static User getUser(String userId) {
        if (Cache.Session.get('CurrentUser') != null) {
            System.debug('user form cache --> ' + Cache.Session.get('CurrentUser'));
            return (User) Cache.Session.get('CurrentUser');
        } else {
            List<User> userList = [SELECT Id, Username, Country__c FROM User WHERE Id = :userId];
            if (userList.isEmpty()) {
                return null;
            }
            System.debug('user from base --> ' + userList[0]);
            Cache.Session.put('CurrentUser', userList.get(0));
            return userList[0];
        }
    }

    public static Boolean isCsEnabledForCurrentUser(String csName) {
        return isCsEnabledForGivenCountry(csName, getCurrentUser().Country__c);
    }

    public static Boolean isCsEnabledForGivenCountry(String csName, String country) {
        Cs_Settings__c csItem = Cs_Settings__c.getInstance(csName);
        if (csItem == null) {
            return false;
        } else {
            Set<String> splitValue = new Set<String>();
            splitValue.addAll(csItem.Value__c.split(','));
            return splitValue.contains(country);
        }
    }

    public static Boolean isContractOverlappingEnabled() {
        Trigger_Exception__c teItem = Trigger_Exception__c.getInstance();
        if (teItem == null) {
            return false;
        }
        return teItem.OverlappingErrorEnable__c;
    }
}