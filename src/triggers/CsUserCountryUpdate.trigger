trigger CsUserCountryUpdate on User (after update) {

 /*   User oldUser = Trigger.old.get(0);
    System.debug('old user --> ' + oldUser.Country__c);*/
    User newUser = Trigger.new.get(0);
    System.debug('new user --> ' + newUser.Country__c);
    Cache.Session.put('CurrentUser', newUser);
}