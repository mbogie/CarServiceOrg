public interface CsITrigger {

    void bulkBefore();
    void bulkAfter();
    void beforeInsert(List<SObject> newlstObj);
    void beforeUpdate(List<SObject> newlstObj,List<SObject> oldlstObj,Map<Id,SObject> newMapObj, Map<Id,SObject> oldMapObj);
    void beforeDelete(List<SObject> oldlstObj,Map<Id,SObject> oldMapObj);
    void afterInsert(List<SObject> newlstObj,Map<Id,SObject> newMapObj);
    void afterUpdate(List<SObject> newlstObj,List<SObject> oldlstObj,Map<Id,SObject> newMapObj, Map<Id,SObject> oldMapObj);
    void afterDelete(List<SObject> oldlstObj,Map<Id,SObject> oldMapObj);
    void andFinally();
}