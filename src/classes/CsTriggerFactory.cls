public with sharing class CsTriggerFactory {

    public static void createHandler(Schema.sObjectType soType) {
        CsITrigger handler = getHandler(soType);
        if (handler != null) execute(handler);
    }

    private static void execute(CsITrigger handler) {
        if (Trigger.isBefore) {
            handler.bulkBefore();
            if (Trigger.isDelete) {
                handler.beforeDelete(trigger.old,trigger.oldMap);
            } else if (Trigger.isInsert) {
                handler.beforeInsert(trigger.new);
            } else if (Trigger.isUpdate) {
                handler.beforeUpdate(trigger.new,trigger.old,trigger.newMap,trigger.oldMap);
            }
        } else {
            handler.bulkAfter();
            if (Trigger.isDelete) {
                handler.afterDelete(trigger.old,trigger.oldMap);
            } else if (Trigger.isInsert) {
                handler.afterInsert(trigger.new,trigger.newMap);
            } else if (Trigger.isUpdate) {
                handler.afterUpdate(trigger.new,trigger.old,trigger.newMap,trigger.oldMap);
            }
        }
        handler.andFinally();
    }

    private static CsITrigger getHandler(Schema.sObjectType soType) {
        if (soType == Contract__c.sObjectType) {
            return (CsUtils.isTriggerEnabled('CsContractOverlapping'))? new CsContractTriggerHandler() : null;
        } else if (soType == User.sObjectType) {
                return new CsUserTriggerHandler();
        }
        return null;
    }
}