public with sharing class CsUserTriggerHandler implements CsITrigger {

    private List<User> oldUsersList = new List<User>();
    private List<User> newUsersList = new List<User>();

    public CsUserTriggerHandler() {
    }

    public void bulkBefore(){
    }

    public void bulkAfter(){
    }

    public void beforeInsert(List<SObject> newlstObj){
    }

    public void beforeUpdate(List<SObject> newlstObj,List<SObject> oldlstObj,Map<Id,SObject> newMapObj, Map<Id,SObject> oldMapObj){
    }

    public void beforeDelete(List<SObject> oldlstObj,Map<Id,SObject> oldMapObj){
    }

    public void afterInsert(List<SObject> newlstObj,Map<Id,SObject> newMapObj){
    }

    public void afterUpdate(List<SObject> newlstObj,List<SObject> oldlstObj,Map<Id,SObject> newMapObj, Map<Id,SObject> oldMapObj){
        newUsersList = newlstObj;
        oldUsersList = oldlstObj;
        if(oldUsersList.get(0).Country__c != newUsersList.get(0).Country__c){
            System.debug('country form trigger --> ' + newUsersList.get(0).Country__c);
            Cache.Session.put('CurrentUser', newUsersList.get(0));
        }
    }

    public void afterDelete(List<SObject> oldlstObj,Map<Id,SObject> oldMapObj){
    }

    public void andFinally(){
    }
}