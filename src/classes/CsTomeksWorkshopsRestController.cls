public with sharing class CsTomeksWorkshopsRestController {

    public WrappedTomeksWorkshop wrappedSearchFormTomeksWorkshop { get; set; }
    public WrappedTomeksWorkshop wrappedTomeksWorkshopToUpsertOrDelete { get; set; }
    public List<WrappedTomeksWorkshop> wrappedTomeksWorkshopsList { get; set; }
    public Boolean isSearchWorkshopNameEmpty { get; set; }
    public Boolean isPopupWorkshopNameEmpty { get; set; }
    private CsTomeksWorkshopsRestHandler restHandler;
    private List<String> responseStatusList;
    private String responseBody;
    private List<String> responseStatus;
    private Map<String, String> countries;

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
        this.wrappedTomeksWorkshopToUpsertOrDelete = new WrappedTomeksWorkshop();
        this.restHandler = new CsTomeksWorkshopsRestHandler();
        this.responseStatusList = new List<String>();
        this.responseStatus = new List<String>();
        this.countries = new Map<String,String>();
    }

    public void generatePageErrorMessage(String message){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, message));
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

    public void searchWorkshop() {
        if (String.isBlank(wrappedSearchFormTomeksWorkshop.name)) {
            isSearchWorkshopNameEmpty = true;
            generatePageErrorMessage(String.format(System.Label.Required_Input_Field_Error, new List<String>{System.Label.Tomek_Workshop_Name}));
            return ;
        }
        isSearchWorkshopNameEmpty = false;
        wrappedTomeksWorkshopsList = new List<WrappedTomeksWorkshop>();
        try {
            responseBody = restHandler.createRequest(CsUtils.getCredentialsValues('TomekGetWorkshopsEndpoint') + createQuery(), 'GET', null);
            wrappedTomeksWorkshopsList = (List<WrappedTomeksWorkshop>) JSON.deserialize(responseBody, List<WrappedTomeksWorkshop>.class);
        } catch (CsException csError) {
            generatePageErrorMessage(csError.getMessage());
        }
    }

    public void editWorkshop() {
        for (WrappedTomeksWorkshop workshop : wrappedTomeksWorkshopsList) {
            if (workshop.id == wrappedTomeksWorkshopToUpsertOrDelete.id) {
                wrappedTomeksWorkshopToUpsertOrDelete.name = workshop.name;
                wrappedTomeksWorkshopToUpsertOrDelete.website = workshop.website;
                wrappedTomeksWorkshopToUpsertOrDelete.phone = workshop.phone;
                wrappedTomeksWorkshopToUpsertOrDelete.city = workshop.city;
                wrappedTomeksWorkshopToUpsertOrDelete.country = workshop.country;
                wrappedTomeksWorkshopToUpsertOrDelete.zipCode = workshop.zipCode;
                wrappedTomeksWorkshopToUpsertOrDelete.externalId = workshop.externalId;
            }
        }
    }

    public void saveWorkshop() {
        if (String.isBlank(wrappedTomeksWorkshopToUpsertOrDelete.name)) {
            isPopupWorkshopNameEmpty = true;
            generatePageErrorMessage(String.format(System.Label.Required_Input_Field_Error, new List<String>{System.Label.Tomek_Workshop_Name}));
            return ;
        }
        isPopupWorkshopNameEmpty = false;
        responseStatus = new List<String>();
        wrappedTomeksWorkshopToUpsertOrDelete.isSynchronized = false;
        try {
            responseBody = restHandler.createRequest(CsUtils.getCredentialsValues('TomekPostWorkshopsEndpoint'), 'POST', new List<WrappedTomeksWorkshop>{wrappedTomeksWorkshopToUpsertOrDelete});
            responseStatusList = (List<String>) JSON.deserialize(responseBody, List<String>.class);
            responseStatus = responseStatusList.get(0).split(',');
            if (responseStatus.get(0) == System.Label.Status_Error) {
                generatePageErrorMessage(responseStatus.get(2));
            } /*else {
                wrappedTomeksWorkshopToUpsertOrDelete.id = responseStatus.get(1);
                Id jobId = System.enqueueJob(new CsUpsertWorkshop(wrappedTomeksWorkshopToUpsertOrDelete));
            }*/
        } catch (CsException csError) {
            generatePageErrorMessage(csError.getMessage());
        }

    }


    public void deleteWorkshop() {
        responseStatus = new List<String>();
        try {
            responseBody = restHandler.createRequest(CsUtils.getCredentialsValues('TomekDeleteWorkshopsEndpoint') + wrappedTomeksWorkshopToUpsertOrDelete.id, 'DELETE', null);
            responseStatusList = (List<String>) JSON.deserialize(responseBody, List<String>.class);
            responseStatus = responseStatusList.get(0).split(',');
            if (responseStatus.get(0) == System.Label.Status_Error) {
                generatePageErrorMessage(responseStatus.get(2));
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
            generatePageErrorMessage(csError.getMessage());
        }
    }

    public void clearPage() {
        isSearchWorkshopNameEmpty = false;
        wrappedTomeksWorkshopsList = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>();
        wrappedSearchFormTomeksWorkshop = new CsTomeksWorkshopsRestController.WrappedTomeksWorkshop();
    }

    public void clearModal() {
        isPopupWorkshopNameEmpty = false;
        wrappedTomeksWorkshopToUpsertOrDelete = new WrappedTomeksWorkshop();
    }

    public String getPopupHeader() {
        return(String.isBlank(wrappedTomeksWorkshopToUpsertOrDelete.id)) ? System.Label.Add_New_Workshop : String.format(
                System.Label.Edit_Workshop_Header, new List<String>{wrappedTomeksWorkshopToUpsertOrDelete.name});
    }

    public List<SelectOption> getCountryList() {
        List<SelectOption> listOfCountries = new List<SelectOption>();
        try {
            responseBody = restHandler.createRequest(CsUtils.getCredentialsValues('TomekGetCountriesEndpoint'), 'GET', null);
            countries = (Map<String, String>) JSON.deserialize(responseBody, Map<String, String>.class);
            for (String mapKey : countries.keySet()) {
                listOfCountries.add(new selectOption(mapKey, countries.get(mapKey)));
            }
        } catch (CsException csError) {
            generatePageErrorMessage(csError.getMessage());
        }
        return listOfCountries;
    }
}