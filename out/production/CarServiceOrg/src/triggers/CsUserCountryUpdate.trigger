trigger CsUserCountryUpdate on User (after delete, after insert, after update, before delete, before insert, before update) {
    CsTriggerFactory.createHandler(User.SObjectType);
}