public with sharing class CsTomeksMechanicsSearchController {

    private CsSoqlQueryBuilder queryBuilder;
    public Boolean isNameEmpty { get; set; }
    public Boolean isPopupMechanicNameEmpty { get; set; }
    public String indexToDelete { get; set; }
    public String indexToEdit { get; set; }
    public String popupHeader { get; set; }
    public CsSoapSforceComSchemasClassMwMechani.WrappedMechanic searchFormMechanic { get; set; }
    public CsSoapSforceComSchemasClassMwMechani.WrappedMechanic mechanicToInsertOrUpdate { get; set; }
    public List<CsSoapSforceComSchemasClassMwMechani.WrappedMechanic> tomeksMechanicsList { get; set; }
    public CsSoapSforceComSchemasClassMwMechani.MechanicIdStatusWrapper statusWrapper { get; set; }
    private CsSoapSforceComSchemasClassMwMechani.MW_MechanicWebService tomeksWebService;
    public List<SelectOption> tomeksCountryList { get; set; }
    private String sessionId;

    public CsTomeksMechanicsSearchController() {
        this.isNameEmpty = false;
        this.isPopupMechanicNameEmpty = false;
        this.searchFormMechanic = new CsSoapSforceComSchemasClassMwMechani.WrappedMechanic();
        this.mechanicToInsertOrUpdate = new CsSoapSforceComSchemasClassMwMechani.WrappedMechanic();
        this.tomeksMechanicsList = new List<CsSoapSforceComSchemasClassMwMechani.WrappedMechanic>();
        this.popupHeader = System.Label.Add_New_Mechanic;
        this.statusWrapper = new CsSoapSforceComSchemasClassMwMechani.MechanicIdStatusWrapper();
        this.tomeksWebService = new CsSoapSforceComSchemasClassMwMechani.MW_MechanicWebService();
        this.tomeksCountryList = tomeksCountryList();
    }

    public static String loginToTomeksMechanics() {
        try {
            CsPartnerSoapSforceCom.Soap partnerSoap = new CsPartnerSoapSforceCom.Soap();
            CsPartnerSoapSforceCom.LoginResult loginResult = partnerSoap.login('tomek.starzak@gmail.com', 'Test1234sDKbP76CNGMdzE4aTTfL1gSEn');
            return loginResult.sessionId;
        } catch (Exception err) {
            System.debug('Login error: ' + err.getMessage());return null;
        }
    }

    public Boolean isServiceInitialized() {
        if (Cache.Session.get('SessionId') == null && !Test.isRunningTest()) {
            sessionId = loginToTomeksMechanics();Cache.Session.put('SessionId', sessionId);
        } else {
            sessionId = (String) Cache.Session.get('SessionId');
        }
        if (String.isBlank(sessionId) && !Test.isRunningTest()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Error_No_SOAP_SessionId));
            return false;
        } else {
            tomeksWebService.SessionHeader = new CsSoapSforceComSchemasClassMwMechani.SessionHeader_element();
            tomeksWebService.SessionHeader.sessionId = sessionId;
            return true;
        }
    }

    public void searchMechanic() {
        if (String.isEmpty(searchFormMechanic.lastName)) {
            isNameEmpty = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, String.format(System.Label.Required_Input_Field_Error,
                    new List<String>{
                            Schema.getGlobalDescribe().get('Mechanic__c').getDescribe().fields.getMap().get('Name').getDescribe().getLabel()
                    })));
            return ;
        }
        isNameEmpty = false;
        if (isServiceInitialized()) {
            tomeksMechanicsList = new List<CsSoapSforceComSchemasClassMwMechani.WrappedMechanic>();
            try {
                tomeksMechanicsList =
                        tomeksWebService.fetchRecords(searchFormMechanic.firstName, searchFormMechanic.lastName, searchFormMechanic.mail, searchFormMechanic.city, searchFormMechanic.country);
            } catch (Exception err) {
                System.debug(err.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Error_WebService));
                return;
            }
        }
    }

    public void clearPage() {
        isNameEmpty = false;
        tomeksMechanicsList = new List<CsSoapSforceComSchemasClassMwMechani.WrappedMechanic>();
        searchFormMechanic = new CsSoapSforceComSchemasClassMwMechani.WrappedMechanic();
    }


    public void saveMechanic() {
        if (String.isEmpty(mechanicToInsertOrUpdate.lastName)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, String.format(System.Label.Required_Input_Field_Error,
                    new List<String>{
                            Schema.getGlobalDescribe().get('Mechanic__c').getDescribe().fields.getMap().get('Name').getDescribe().getLabel()
                    })));
            isPopupMechanicNameEmpty = true;
            return ;
        }
        isPopupMechanicNameEmpty = false;
        if (isServiceInitialized()) {
            try {
                statusWrapper = tomeksWebService.addOrEditMechanic(indexToEdit, mechanicToInsertOrUpdate.firstName, mechanicToInsertOrUpdate.lastName, mechanicToInsertOrUpdate.mail, mechanicToInsertOrUpdate.city, mechanicToInsertOrUpdate.country);
            } catch (Exception err) {
                System.debug(err.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Error_WebService));
                return;
            }
            if (statusWrapper.id == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, statusWrapper.status));
            }
            if (String.isNotBlank(searchFormMechanic.lastName)) {
                searchMechanic();
            }
        }
    }

    public void clearModal() {
        isPopupMechanicNameEmpty = false;
        indexToEdit = null;
        this.mechanicToInsertOrUpdate = new CsSoapSforceComSchemasClassMwMechani.WrappedMechanic();
        popupHeader = System.Label.Add_New_Mechanic;
    }

    public void editMechanic() {
        for (CsSoapSforceComSchemasClassMwMechani.WrappedMechanic mechanic : tomeksMechanicsList) {
            if (mechanic.id == indexToEdit) {
                mechanicToInsertOrUpdate.firstName = mechanic.firstName;
                mechanicToInsertOrUpdate.lastName = mechanic.lastName;
                mechanicToInsertOrUpdate.mail = mechanic.mail;
                mechanicToInsertOrUpdate.city = mechanic.city;
                mechanicToInsertOrUpdate.country = mechanic.country;
                popupHeader = String.format(System.Label.Edit_Mechanic_Header, new List<String>{
                        mechanic.firstName, mechanic.lastName
                });
            }
        }
    }

    public void deleteMechanic() {
        if (isServiceInitialized()) {
            try {
                statusWrapper = tomeksWebService.deleteMechanic(indexToDelete);
            } catch (Exception err) {
                System.debug(err.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Error_WebService));
                return;
            }
            if (statusWrapper.id == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, statusWrapper.status));
            }
            if (String.isNotBlank(searchFormMechanic.lastName)) {
                searchMechanic();
            }
        }
    }

    Public List<SelectOption> tomeksCountryList() {
        List<SelectOption> listOfCountries = new List<SelectOption>();
        listOfCountries.add(new selectOption('', '- None -'));
        for (String country : System.Label.Tomeks_Country_List.split(',')) {
            listOfCountries.add(new selectoption(country, country));
        }
        return listOfCountries;
    }
}