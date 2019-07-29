public with sharing class CsTomeksWorkshopsRestController {

    public WrappedTomeksWorkshop wrappedSearchFormTomeksWorkshop { get; set; }
    public WrappedTomeksWorkshop wrappedTomeksWorkshopToUpsert { get; set; }
    public List<WrappedTomeksWorkshop> wrappedTomeksWorkshopsList { get; set; }
    public Boolean isSearchWorkshopNameEmpty { get; set; }
    public Boolean isPopupWorkshopNameEmpty { get; set; }
    public List<SelectOption> tomeksCountryList { get; set; }
    public String idToEdit { get; set; }
    public String idToDelete { get; set; }
    public String popupHeader { get; set; }

    public class WrappedTomeksWorkshop {
        public String id { get; set; }
        public String name { get; set; }
        public String phone { get; set; }
        public String country { get; set; }
        public String website { get; set; }
        public String city { get; set; }
        public String zipCode { get; set; }
    }

    public CsTomeksWorkshopsRestController() {
        this.wrappedSearchFormTomeksWorkshop = new WrappedTomeksWorkshop();
        this.wrappedTomeksWorkshopsList = new List<WrappedTomeksWorkshop>();
        this.isSearchWorkshopNameEmpty = false;
        this.isPopupWorkshopNameEmpty = false;
        this.wrappedTomeksWorkshopToUpsert = new WrappedTomeksWorkshop();
        this.popupHeader = System.Label.Add_New_Workshop;
    }

    public String createQuery() {
        String query = '';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.name)) query += 'Name__c=' + wrappedSearchFormTomeksWorkshop.name + '&';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.phone)) query += 'Phone__c=' + wrappedSearchFormTomeksWorkshop.phone + '&';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.country)) query += 'Country__c=' + wrappedSearchFormTomeksWorkshop.country + '&';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.city)) query += 'City__c=' + wrappedSearchFormTomeksWorkshop.city + '&';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.website)) query += 'Website__c=' + wrappedSearchFormTomeksWorkshop.website + '&';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.zipCode)) query += 'Zip_Code__c=' + wrappedSearchFormTomeksWorkshop.zipCode + '&';
        return query.removeEnd('&');
    }

    public String getSessionId() {
        String sessionId = (String) Cache.Session.get('RestSessionId');
        if (sessionId == null && !Test.isRunningTest()) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://login.salesforce.com/services/oauth2/token?grant_type=password&' +
                    'client_id=' + CsUtils.getLoginValues('TomekClientId') +
                    '&client_secret=' + CsUtils.getLoginValues('TomekClientSecret') +
                    '&username=' + CsUtils.getLoginValues('TomekUsername') +
                    '&password=' + CsUtils.getLoginValues('TomekPassword'));
            request.setMethod('POST');
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> objectsList = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                sessionId = (String) objectsList.get('access_token');
                Cache.Session.put('RestSessionId',sessionId);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, response.getStatusCode() + ' ' + response.getStatus()));
            }
        }
        return sessionId;
    }

    public void searchWorkshop() {
       /* if (String.isBlank(wrappedSearchFormTomeksWorkshop.name)) {
            isSearchWorkshopNameEmpty = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, String.format(System.Label.Required_Input_Field_Error,
                    new List<String>{Schema.getGlobalDescribe().get('Workshop__c').getDescribe().fields.getMap().get('Name').getDescribe().getLabel()})));
            return ;
        }*/
        if(!Pattern.matches(System.Label.Phone_Pattern, wrappedSearchFormTomeksWorkshop.phone) && String.isNotBlank(wrappedSearchFormTomeksWorkshop.phone)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.Error_Phone_Pattern));
            return ;
        }
        isSearchWorkshopNameEmpty = false;
        wrappedTomeksWorkshopsList = new List<WrappedTomeksWorkshop>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String urlQuery = createQuery();
        request.setEndpoint('https://eu26.salesforce.com/services/apexrest/workshops?' + urlQuery);
        request.setHeader('Authorization', 'Bearer ' + getSessionId());
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            wrappedTomeksWorkshopsList = (List<WrappedTomeksWorkshop>) JSON.deserialize(response.getBody(), List<WrappedTomeksWorkshop>.class);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, response.getStatusCode() + ' ' + response.getStatus()));
        }
    }

    public void editWorkshop() {
        for (WrappedTomeksWorkshop workshop : wrappedTomeksWorkshopsList) {
            if (workshop.id == idToEdit) {
                wrappedTomeksWorkshopToUpsert.id = idToEdit;
                wrappedTomeksWorkshopToUpsert.name = workshop.name;
                wrappedTomeksWorkshopToUpsert.website = workshop.website;
                wrappedTomeksWorkshopToUpsert.phone = workshop.phone;
                wrappedTomeksWorkshopToUpsert.city = workshop.city;
                wrappedTomeksWorkshopToUpsert.country = workshop.country;
                wrappedTomeksWorkshopToUpsert.zipCode = workshop.zipCode;
                popupHeader = String.format(System.Label.Edit_Workshop_Header, new List<String>{
                        workshop.name});
            }
        }
        popupHeader = String.format(System.Label.Edit_Workshop_Header, new List<String>{
                wrappedTomeksWorkshopToUpsert.name});
    }

    public void saveWorkshop() {
       /* if(String.isBlank(wrappedTomeksWorkshopToUpsert.name)){
            isPopupWorkshopNameEmpty = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, String.format(System.Label.Required_Input_Field_Error,
                    new List<String>{Schema.getGlobalDescribe().get('Workshop__c').getDescribe().fields.getMap().get('Name').getDescribe().getLabel()})));
            return ;
        }*/
     /*   if(!Pattern.matches(System.Label.Phone_Pattern, wrappedTomeksWorkshopToUpsert.phone) && String.isNotBlank(wrappedTomeksWorkshopToUpsert.phone)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.Error_Phone_Pattern));
            return ;
        }*/
     //   isPopupWorkshopNameEmpty = false;
        String bodyString = '';
        List<WrappedTomeksWorkshop> workshops = new List<WrappedTomeksWorkshop>();
        List<String> upsertStatus = new List<String>();
        workshops.add(wrappedTomeksWorkshopToUpsert);
        Map<String,List<WrappedTomeksWorkshop>> jsonMap = new Map<String, List<WrappedTomeksWorkshop>>();
        jsonMap.put('workshops',workshops);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://eu26.salesforce.com/services/apexrest/workshops');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + getSessionId());
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(JSON.serialize(jsonMap));
        System.debug('jason --> ' + JSON.serialize(jsonMap));
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            List<String> responseStatusList = (List<String>) JSON.deserialize(response.getBody(), List<String>.class);
            for (String status : responseStatusList) {
                upsertStatus = status.split(',');
                if (upsertStatus.get(0) == 'Error') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, upsertStatus.get(2)));
                } else if(String.isNotBlank(wrappedSearchFormTomeksWorkshop.name)) searchWorkshop();
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, response.getStatusCode() + ' ' + response.getStatus()));
        }
    }

    public void deleteWorkshop() {
        List<String> deleteStatus = new List<String>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://eu26.salesforce.com/services/apexrest/workshops?id=' + idToDelete);
        request.setHeader('Authorization', 'Bearer ' + getSessionId());
        request.setMethod('DELETE');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            List<String> responseStatusList = (List<String>) JSON.deserialize(response.getBody(), List<String>.class);
            for (String status : responseStatusList) {
                deleteStatus = status.split(',');
                if (deleteStatus.get(0) == 'Error') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, deleteStatus.get(2)));
                } else if(String.isNotBlank(wrappedSearchFormTomeksWorkshop.name)) searchWorkshop();
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, response.getStatusCode() + ' ' + response.getStatus()));
        }
    }

    public void clearPage() {
        isSearchWorkshopNameEmpty = false;
        wrappedTomeksWorkshopsList = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>();
        wrappedSearchFormTomeksWorkshop = new CsTomeksWorkshopsRestController.WrappedTomeksWorkshop();
    }

    public void clearModal(){
        isPopupWorkshopNameEmpty = false;
        idToEdit = null;
        wrappedTomeksWorkshopToUpsert = new WrappedTomeksWorkshop();
        popupHeader = System.Label.Add_New_Workshop;
    }
}