public with sharing class CsTomeksWorkshopsRestController {

    public WrappedTomeksWorkshop wrappedSearchFormTomeksWorkshop { get; set; }
    public WrappedTomeksWorkshop wrappedTomeksWorkshopToUpsert { get; set; }
    public List<WrappedTomeksWorkshop> wrappedTomeksWorkshopsList { get; set; }
    public Boolean isSearchWorkshopNameEmpty { get; set; }
    public Boolean isPopupWorkshopNameEmpty { get; set; }
    public String idToEdit { get; set; }
    public String idToDelete { get; set; }
    public String popupHeader { get; set; }
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
        this.popupHeader = System.Label.Add_New_Workshop;
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
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, String.format(System.Label.Required_Input_Field_Error, new List<String>{System.Label.Tomek_Workshop_Name})));
            return ;
        }
        isSearchWorkshopNameEmpty = false;
        wrappedTomeksWorkshopsList = new List<WrappedTomeksWorkshop>();
        responseBody = restHandler.createRequest(createQuery(), 'GET', null);
        if (responseBody.startsWith(System.Label.Status_Error)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, responseBody));
        } else {
            wrappedTomeksWorkshopsList = (List<WrappedTomeksWorkshop>) JSON.deserialize(responseBody, List<WrappedTomeksWorkshop>.class);
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
                wrappedTomeksWorkshopToUpsert.externalId = workshop.externalId;
                popupHeader = String.format(System.Label.Edit_Workshop_Header, new List<String>{workshop.name});
            }
        }
        popupHeader = String.format(System.Label.Edit_Workshop_Header, new List<String>{
                wrappedTomeksWorkshopToUpsert.name
        });
    }

    public void saveWorkshop() {
        if (String.isBlank(wrappedTomeksWorkshopToUpsert.name)) {
            isPopupWorkshopNameEmpty = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, String.format(System.Label.Required_Input_Field_Error, new List<String>{System.Label.Tomek_Workshop_Name})));
            return ;
        }
        Workshop__c workshopToUpsert = new Workshop__c();
        wrappedTomeksWorkshopToUpsert.isSynchronized = false;
        isPopupWorkshopNameEmpty = false;
        workshops = new List<WrappedTomeksWorkshop>();
        responseStatus = new List<String>();
        workshops.add(wrappedTomeksWorkshopToUpsert);
        Map<String, List<WrappedTomeksWorkshop>> jsonMap = new Map<String, List<WrappedTomeksWorkshop>>();
        jsonMap.put('workshops', workshops);
        responseBody = restHandler.createRequest('', 'POST', jsonMap);
        if (responseBody.startsWith(System.Label.Status_Error)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, responseBody));
        } else {
            responseStatusList = (List<String>) JSON.deserialize(responseBody, List<String>.class);
            for (String status : responseStatusList) {
                responseStatus = status.split(',');
                if (responseStatus.get(0) == System.Label.Status_Error) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, responseStatus.get(2)));
                } else {
                    workshopToUpsert.External_Id__c = responseStatus.get(1);
                    workshopToUpsert.Name = wrappedTomeksWorkshopToUpsert.name;
                    workshopToUpsert.Website__c = wrappedTomeksWorkshopToUpsert.website;
                    workshopToUpsert.Phone__c = wrappedTomeksWorkshopToUpsert.phone;
                    workshopToUpsert.City__c = wrappedTomeksWorkshopToUpsert.city;
                    workshopToUpsert.Country__c = wrappedTomeksWorkshopToUpsert.country;
                    workshopToUpsert.Zip_Code__c = wrappedTomeksWorkshopToUpsert.zipCode;
                    workshopToUpsert.Id = wrappedTomeksWorkshopToUpsert.externalId;
                    workshopToUpsert.Is_Synchronized__c = false;
                    System.enqueueJob(new CsUpsertWorkshop(new List<Workshop__c>{workshopToUpsert}));
                }
            }
        }
    }

    public void deleteWorkshop() {
        responseStatus = new List<String>();
        Workshop__c workshopToDelete = new Workshop__c();
        responseBody = restHandler.createRequest('?id=' + idToDelete, 'DELETE', null);
        if (responseBody.startsWith(System.Label.Status_Error)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, responseBody));
        } else {
            responseStatusList = (List<String>) JSON.deserialize(responseBody, List<String>.class);
            for (String status : responseStatusList) {
                responseStatus = status.split(',');
                if (responseStatus.get(0) == System.Label.Status_Error) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, responseStatus.get(2)));
                } else {
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
                }
            }
        }
    }

    public void clearPage() {
        isSearchWorkshopNameEmpty = false;
        wrappedTomeksWorkshopsList = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>();
        wrappedSearchFormTomeksWorkshop = new CsTomeksWorkshopsRestController.WrappedTomeksWorkshop();
    }

    public void clearModal() {
        isPopupWorkshopNameEmpty = false;
        idToEdit = null;
        wrappedTomeksWorkshopToUpsert = new WrappedTomeksWorkshop();
        popupHeader = System.Label.Add_New_Workshop;
    }

    public List<SelectOption> getCountryList() {
        List<SelectOption> listOfCountries = new List<SelectOption>();
        responseBody = restHandler.createRequest('/countries', 'GET', null);
        if (responseBody.startsWith(System.Label.Status_Error)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, responseBody));
            return null;
        } else {
            List<String> countries = (List<String>) JSON.deserialize(responseBody, List<String>.class);
            listOfCountries.add(new selectOption('', System.Label.Select_Option_None));
            for (String country : countries) {
                listOfCountries.add(new selectOption(country, country));
            }
            return listOfCountries;
        }
    }
}