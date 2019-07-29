public with sharing class CsTomeksWorkshopsRestController {

    public CsTomeksWorkshopsRestController.WrappedTomeksWorkshop wrappedSearchFormTomeksWorkshop { get; set; }
    public CsTomeksWorkshopsRestController.WrappedTomeksWorkshop wrappedTomeksWorkshopToAdd { get; set; }
    public List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop> wrappedTomeksWorkshopsList { get; set; }
    public List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshopWithStatus> wrappedTomeksWorkshopWithStatusList { get; set; }
    public Boolean isSearchWorkshopNameEmpty { get; set; }
    public List<SelectOption> tomeksCountryList { get; set; }
    public Boolean isEdited { get; set; }

    public class WrappedTomeksWorkshop {
        public String wrapperId;
        public String name { get; set; }
        public String phone { get; set; }
        public String country { get; set; }
        public String website { get; set; }
        public String city { get; set; }
        public String zipCode { get; set; }
    }

    public class WrappedTomeksWorkshopWithStatus {
        public CsTomeksWorkshopsRestController.WrappedTomeksWorkshop innerWorkshop { get; set; }
        public Boolean isSelectedToDelete { get; set; }
        public String message { get; set; }
        public String status { get; set; }

        public WrappedTomeksWorkshopWithStatus(CsTomeksWorkshopsRestController.WrappedTomeksWorkshop workshop) {
            this.innerWorkshop = workshop;
            this.isSelectedToDelete = false;
            this.message = '';
            this.status = '';
        }
    }

    public CsTomeksWorkshopsRestController() {
        this.wrappedSearchFormTomeksWorkshop = new CsTomeksWorkshopsRestController.WrappedTomeksWorkshop();
        this.wrappedTomeksWorkshopsList = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>();
        this.wrappedTomeksWorkshopWithStatusList = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshopWithStatus>();
        this.isEdited = false;
        this.isSearchWorkshopNameEmpty = false;
     //   this.tomeksCountryList = tomeksCountryList();

    }

/*    public List<SelectOption> tomeksCountryList() {
        List<SelectOption> listOfCountries = new List<SelectOption>();
        listOfCountries.add(new selectOption('', '- None -'));
        for (String country : System.Label.Tomeks_Country_List.split(',')) {
            listOfCountries.add(new selectoption(country, country));
        }
        return listOfCountries;
    }*/

    public String createQuery() {
        String query = '';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.name)) query += 'name=' + wrappedSearchFormTomeksWorkshop.name + '&';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.phone)) query += 'phone=' + wrappedSearchFormTomeksWorkshop.phone + '&';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.country)) query += 'country=' + wrappedSearchFormTomeksWorkshop.country + '&';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.city)) query += 'city=' + wrappedSearchFormTomeksWorkshop.city + '&';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.website)) query += 'website=' + wrappedSearchFormTomeksWorkshop.website + '&';
        if (String.isNotBlank(wrappedSearchFormTomeksWorkshop.zipCode)) query += 'zipCode=' + wrappedSearchFormTomeksWorkshop.zipCode + '&';
        return query.removeEnd('&');
    }

    public String getSessionId(){

        return null;
    }

    public void searchMechanic() {
        if (String.isBlank(wrappedSearchFormTomeksWorkshop.name)) {
            isSearchWorkshopNameEmpty = true;
            return ;
        }
        isSearchWorkshopNameEmpty = false;
        wrappedTomeksWorkshopWithStatusList = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshopWithStatus>();
        wrappedTomeksWorkshopsList = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String urlQuery = createQuery();
        request.setEndpoint('https://eu26.salesforce.com/services/apexrest/workshops?' + urlQuery);
  //      request.setHeader('Authorization', 'Bearer 00D2p00000134ts!ARUAQMo1H.0kmUuHSTcWSovqilEyvipXxPcFivhi4HzB7WCXeFQlqG0ANGjpQQLwzPJtJZpGcAR0Sqi0TAfcYq_LaBBJqOFE');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            System.debug(JSON.deserializeUntyped(response.getBody()));
            List<Object> objectsList = (List<Object>) JSON.deserializeUntyped(response.getBody());
          //  wrappedTomeksWorkshopsList = (List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>) JSON.deserializeUntyped(response.getBody());
            for (CsTomeksWorkshopsRestController.WrappedTomeksWorkshop workshop : wrappedTomeksWorkshopsList) {
                wrappedTomeksWorkshopWithStatusList.add(new WrappedTomeksWorkshopWithStatus(workshop));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, response.getStatusCode() + ' ' + response.getStatus()));
        }
    }

    public void addMechanic() {
        String bodyString = '';
        List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop> wrappers = new List<WrappedTomeksWorkshop>();
        wrappers.add(wrappedTomeksWorkshopToAdd);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://eu26.salesforce.com/services/apexrest/workshops');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(JSON.serializePretty(wrappers));
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            List<String> responseStatusList = (List<String>) JSON.deserializeUntyped(response.getBody());
            if (responseStatusList.get(0).split(',')[0] == 'Error') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, responseStatusList.get(0).split(',')[1]));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, response.getStatusCode() + ' ' + response.getStatus()));
        }
    }
    public void editMechanics() {
        isEdited = true;
    }

    public void saveMechanic() {
        isEdited = false;
        String bodyString = '';
        List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop> wrappers = new List<WrappedTomeksWorkshop>();
        List<String> upsertStatus = new List<String>();
        for (CsTomeksWorkshopsRestController.WrappedTomeksWorkshopWithStatus workshopWithStatus : wrappedTomeksWorkshopWithStatusList) {
            wrappers.add(workshopWithStatus.innerWorkshop);
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://eu26.salesforce.com/services/apexrest/workshops');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(JSON.serializePretty(wrappers));
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            List<String> responseStatusList = (List<String>) JSON.deserializeUntyped(response.getBody());
            for (String status : responseStatusList) {
                upsertStatus = status.split(',');
                if (upsertStatus.get(0) == 'Fail') {
                    for (CsTomeksWorkshopsRestController.WrappedTomeksWorkshopWithStatus workshop : wrappedTomeksWorkshopWithStatusList) {
                        if (workshop.innerWorkshop.wrapperId == upsertStatus.get(1)) {
                            workshop.status = upsertStatus.get(0);
                            workshop.message = upsertStatus.get(2);
                        }
                    }
                }
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, response.getStatusCode() + ' ' + response.getStatus()));
        }
    }

    public void deleteMechanic() {
        String ids = '';
        List<String> upsertStatus = new List<String>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        for (CsTomeksWorkshopsRestController.WrappedTomeksWorkshopWithStatus workshop : wrappedTomeksWorkshopWithStatusList) {
            if (workshop.isSelectedToDelete) ids += workshop.innerWorkshop.wrapperId + ',';
        }
        request.setEndpoint('https://eu26.salesforce.com/services/apexrest/workshops?Ids=' + ids.removeEnd(','));
        request.setMethod('DELETE');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            List<String> responseStatusList = (List<String>) JSON.deserializeUntyped(response.getBody());
            for (String status : responseStatusList) {
                upsertStatus = status.split(',');
                for (CsTomeksWorkshopsRestController.WrappedTomeksWorkshopWithStatus workshop : wrappedTomeksWorkshopWithStatusList) {
                    if (workshop.innerWorkshop.wrapperId == upsertStatus.get(1)) {
                        workshop.status = upsertStatus.get(0);
                        if (upsertStatus.get(0) == 'Fail') {
                            workshop.message = upsertStatus.get(2);
                        }
                    }
                }
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, response.getStatusCode() + ' ' + response.getStatus()));
        }
    }

    public void clearPage() {
        isSearchWorkshopNameEmpty = false;
        wrappedTomeksWorkshopWithStatusList = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshopWithStatus>();
        wrappedTomeksWorkshopsList = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>();
        wrappedSearchFormTomeksWorkshop = new CsTomeksWorkshopsRestController.WrappedTomeksWorkshop();
    }

}