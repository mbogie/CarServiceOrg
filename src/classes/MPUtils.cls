public with sharing class MPUtils {

    public static String getCsValues(String csName) {
        MP_Settings__c mpItem = MP_Settings__c.getInstance(csName);
        if (mpItem == null) {
            return '';
        } else {
            return mpItem.Value__c;
        }
    }
}