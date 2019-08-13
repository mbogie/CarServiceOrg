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

    public static String getCredentialsValues(String csName) {
        Cs_Settings__c csItem = Cs_Settings__c.getInstance(csName);
        if (csItem == null) {
            return '';
        } else {
            return csItem.Value__c;
        }
    }

    public static Decimal getNumberValues(String csName) {
        Cs_Settings__c csItem = Cs_Settings__c.getInstance(csName);
        if (csItem == null) {
            return 0;
        } else {
            return csItem.Number__c;
        }
    }

    public static void changePublicGroup(String username, String fromGroup, String toGroup){
        Group groupFrom = getGroupByName(fromGroup);
        Group groupTo = getGroupByName(toGroup);
        User user = getUserByUsername(username);

        GroupMember oldGroupMember  = [SELECT Id from GroupMember WHERE GroupId = :groupFrom.Id AND UserOrGroupId = :user.Id];
        delete oldGroupMember;

        GroupMember newGroupMember = new GroupMember();
        newGroupMember.GroupId = groupTo.Id;
        newGroupMember.UserOrGroupId = user.Id;
        insert newGroupMember;
    }

    public static void switchPublicGroup(String username){
        User user = getUserByUsername(username);
        Group groupPl = getGroupByName(getCredentialsValues('Group_PL_Users'));
        Group groupUsa = getGroupByName(getCredentialsValues('Group_Usa_Users'));

        GroupMember oldGroupMember  = [SELECT Id, GroupId from GroupMember WHERE  UserOrGroupId = :user.Id];
        Group groupTo = (oldGroupMember.GroupId == groupPl.Id) ? groupUsa : groupPl;
        delete oldGroupMember;

        GroupMember newGroupMember = new GroupMember(GroupId = groupTo.Id,UserOrGroupId = user.Id);
        insert newGroupMember;
    }

    public static Group getGroupByName(String name){
        return [SELECT Id FROM Group WHERE DeveloperName LIKE :name];
    }

    public static User getUserByUsername(String username){
        return [SELECT Id FROM user WHERE Username LIKE :username][0];
    }

    public static List<User> getUsersByGroupName(String groupName){
        Group groupId = [SELECT Id FROM Group WHERE DeveloperName LIKE :groupName][0];
        return [SELECT Id, Username, Email FROM user WHERE  Id IN (SELECT UserOrGroupId from GroupMember WHERE GroupId = :groupId.Id)];
    }
}



