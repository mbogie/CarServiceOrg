public with sharing class CsUtils {

    public static User getCurrentUser() {
        User currentUser = (User) Cache.Session.get('CurrentUser');
        if (currentUser == null){
            currentUser = getUser(UserInfo.getUserId());
            Cache.Session.put('CurrentUser',currentUser);
        }
        return currentUser;
    }

    public static User getUser(String userId) {
        List<User> userList = [SELECT Id, Username, Country__c FROM User WHERE Id = :userId];
        if (userList.isEmpty()) {
            return null;
        }
        return userList[0];
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

    public static Boolean isTriggerEnabled(String triggerName) {
        Boolean isTriggerEnabled = true;
        Trigger_Exception__c teItem = Trigger_Exception__c.getInstance();
        if (teItem != null) {
            try {
                isTriggerEnabled = Boolean.valueOf(teItem.get(triggerName + '__c'));
            } catch (Exception err) {
                System.debug(err.getMessage());
            }
        }
        return isTriggerEnabled;
    }

    public static String getLoginValues(String csName) {
        Cs_Settings__c csItem = Cs_Settings__c.getInstance(csName);
        if (csItem == null) {
            return '';
        } else {
            return csItem.Value__c;
        }
    }
}