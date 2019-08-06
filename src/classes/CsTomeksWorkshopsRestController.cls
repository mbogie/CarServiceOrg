public with sharing class CsTomeksWorkshopsRestController {

    public WrappedTomeksWorkshop wrappedSearchFormTomeksWorkshop { get; set; }
    public WrappedTomeksWorkshop wrappedTomeksWorkshopToUpsert { get; set; }
    public List<WrappedTomeksWorkshop> wrappedTomeksWorkshopsList { get; set; }
    public Boolean isSearchWorkshopNameEmpty { get; set; }
    public Boolean isPopupWorkshopNameEmpty { get; set; }
    public String idToDelete { get; set; }
    private CsTomeksWorkshopsRestHandler restHandler;
    public List<String> responseStatusList;
    public List<WrappedTomeksWorkshop> workshops;
    private String responseBody;
    private List<String> responseStatus;

    public class WrappedTomeksWorkshop {
        public String externalId { get; set; }
        public String id { get; set; }
        public String name { get; set; }
        public String phone { get; set; }
        public String country { get; set; }
        public String website { get; set; }
        public String city { get; set; }
        public String zipCode { get; set; }
        public Boolean isSynchronized { get; set; }
    }

    public CsTomeksWorkshopsRestController() {
        this.wrappedSearchFormTomeksWorkshop = new WrappedTomeksWorkshop();
        this.wrappedTomeksWorkshopsList = new List<WrappedTomeksWorkshop>();
        this.isSearchWorkshopNameEmpty = false;
        this.isPopupWorkshopNameEmpty = false;
        this.wrappedTomeksWorkshopToUpsert = new WrappedTomeksWorkshop();
        this.restHandler = new CsTomeksWorkshopsRestHandler();
        this.responseStatusList = new List<String>();
        this.workshops = new List<WrappedTomeksWorkshop>();
        this.responseStatus = new List<String>();
    }

    public String createQuery() {
        String query = '?';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.name)) query += 'Name__c=' + wrappedSearchFormTomeksWorkshop.name + '&';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.phone)) query += 'Phone__c=' + wrappedSearchFormTomeksWorkshop.phone + '&';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.country)) query += 'Country__c=' + wrappedSearchFormTomeksWorkshop.country + '&';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.city)) query += 'City__c=' + wrappedSearchFormTomeksWorkshop.city + '&';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.website)) query += 'Website__c=' + wrappedSearchFormTomeksWorkshop.website + '&';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.zipCode)) query += 'Zip_Code__c=' + wrappedSearchFormTomeksWorkshop.zipCode + '&';
        return query.removeEnd('&');
    }

    public void searchWorkshop() {
        if (String.isBlank(wrappedSearchFormTomeksWorkshop.name)) {
            isSearchWorkshopNameEmpty = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,
                    String.format(System.Label.Required_Input_Field_Error, new List<String>{System.Label.Tomek_Workshop_Name})));
            return ;
        }
        isSearchWorkshopNameEmpty = false;
        wrappedTomeksWorkshopsList = new List<WrappedTomeksWorkshop>();
        try {
            responseBody = restHandler.createRequest(createQuery(), 'GET', null);
            wrappedTomeksWorkshopsList = (List<WrappedTomeksWorkshop>) JSON.deserialize(responseBody, List<WrappedTomeksWorkshop>.class);
        } catch (CsException csError) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, csError.getMessage()));
        }
    }

    public void editWorkshop() {
        for (WrappedTomeksWorkshop workshop : wrappedTomeksWorkshopsList) {
            if (workshop.id == wrappedTomeksWorkshopToUpsert.id) {
                wrappedTomeksWorkshopToUpsert.name = workshop.name;
                wrappedTomeksWorkshopToUpsert.website = workshop.website;
                wrappedTomeksWorkshopToUpsert.phone = workshop.phone;
                wrappedTomeksWorkshopToUpsert.city = workshop.city;
                wrappedTomeksWorkshopToUpsert.country = workshop.country;
                wrappedTomeksWorkshopToUpsert.zipCode = workshop.zipCode;
                wrappedTomeksWorkshopToUpsert.externalId = workshop.externalId;
                wrappedTomeksWorkshopToUpsert.isSynchronized = false;
            }
        }
    }

    public void saveWorkshop() {
        if (String.isBlank(wrappedTomeksWorkshopToUpsert.name)) {
            isPopupWorkshopNameEmpty = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,
                    String.format(System.Label.Required_Input_Field_Error, new List<String>{System.Label.Tomek_Workshop_Name})));
            return ;
        }
        isPopupWorkshopNameEmpty = false;
        workshops = new List<WrappedTomeksWorkshop>();
        responseStatus = new List<String>();
        workshops.add(wrappedTomeksWorkshopToUpsert);
        try {
            responseBody = restHandler.createRequest('', 'POST', workshops);
            responseStatusList = (List<String>) JSON.deserialize(responseBody, List<String>.class);
            responseStatus = responseStatusList.get(0).split(',');
            if (responseStatus.get(0) == System.Label.Status_Error) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, responseStatus.get(2)));
            } /*else {
                wrappedTomeksWorkshopToUpsert.id = responseStatus.get(1);
                Id jobId = System.enqueueJob(new CsUpsertWorkshop(wrappedTomeksWorkshopToUpsert));
            }*/
        } catch (CsException csError) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, csError.getMessage()));
        }

    }


    public void deleteWorkshop() {
        responseStatus = new List<String>();
        try {
            responseBody = restHandler.createRequest('?id=' + idToDelete, 'DELETE', null);
            responseStatusList = (List<String>) JSON.deserialize(responseBody, List<String>.class);
            responseStatus = responseStatusList.get(0).split(',');
            if (responseStatus.get(0) == System.Label.Status_Error) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, responseStatus.get(2)));
            } /*else {
                for (WrappedTomeksWorkshop tomeksWorkshop : wrappedTomeksWorkshopsList) {
                    if (tomeksWorkshop.id == idToDelete) {
                        if (String.isNotBlank(tomeksWorkshop.externalId)) {
                            try {
                                delete new Workshop__c(Id = tomeksWorkshop.externalId);
                            } catch (Exception err) {
                                System.debug(err.getMessage());
                            }
                        }
                    }
                }
            }*/
        } catch (CsException csError) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, csError.getMessage()));
        }
    }

    public void clearPage() {
        isSearchWorkshopNameEmpty = false;
        wrappedTomeksWorkshopsList = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>();
        wrappedSearchFormTomeksWorkshop = new CsTomeksWorkshopsRestController.WrappedTomeksWorkshop();
    }

    public void clearModal() {
        isPopupWorkshopNameEmpty = false;
        wrappedTomeksWorkshopToUpsert = new WrappedTomeksWorkshop();
    }

    public String getPopupHeader() {
        return(String.isBlank(wrappedTomeksWorkshopToUpsert.id)) ? System.Label.Add_New_Workshop : String.format(
                System.Label.Edit_Workshop_Header, new List<String>{wrappedTomeksWorkshopToUpsert.name});
    }

    public List<SelectOption> getCountryList() {
        List<SelectOption> listOfCountries = new List<SelectOption>();
        try {
            responseBody = restHandler.createRequest('/countries', 'GET', null);
            Map<String, String> countries = (Map<String, String>) JSON.deserialize(responseBody, Map<String, String>.class);
            for (String mapKey : countries.keySet()) {
                listOfCountries.add(new selectOption(mapKey, countries.get(mapKey)));
            }
        } catch (CsException csError) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, csError.getMessage()));
        }
        return listOfCountries;
    }
}