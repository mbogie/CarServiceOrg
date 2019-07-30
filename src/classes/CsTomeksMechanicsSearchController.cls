public with sharing class CsTomeksMechanicsSearchController {

    private CsSoqlQueryBuilder queryBuilder;
    public Boolean isNameEmpty { get; set; }
    public Boolean isPopupMechanicNameEmpty { get; set; }
    public String indexToDelete { get; set; }
    public String indexToEdit { get; set; }
    public String popupHeader { get; set; }
    public CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic searchFormMechanic { get; set; }
    public CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic mechanicToInsertOrUpdate { get; set; }
    public List<CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic> tomeksMechanicsList { get; set; }
    public CsSoapSforceComSchemasClassMwMechanic.MechanicIdStatusWrapper statusWrapper { get; set; }
    private CsSoapSforceComSchemasClassMwMechanic.MW_MechanicWebService tomeksWebService;
    private String sessionId;

    public CsTomeksMechanicsSearchController() {
        this.isNameEmpty = false;
        this.isPopupMechanicNameEmpty = false;
        this.searchFormMechanic = new CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic();
        this.mechanicToInsertOrUpdate = new CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic();
        this.tomeksMechanicsList = new List<CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic>();
        this.popupHeader = System.Label.Add_New_Mechanic;
        this.statusWrapper = new CsSoapSforceComSchemasClassMwMechanic.MechanicIdStatusWrapper();
        this.tomeksWebService = new CsSoapSforceComSchemasClassMwMechanic.MW_MechanicWebService();
    }

    public static String loginToTomeksMechanics() {
        try {
            CsPartnerSoapSforceCom.Soap partnerSoap = new CsPartnerSoapSforceCom.Soap();
            CsPartnerSoapSforceCom.LoginResult loginResult = partnerSoap.login(CsUtils.getCredentialsValues('TomekUsername'), CsUtils.getCredentialsValues('TomekPassword'));
            return loginResult.sessionId;
        } catch (Exception err) {
            System.debug('Login error: ' + err.getMessage());
            return null;
        }
    }

    public Boolean isServiceInitialized() {
        if (Cache.Session.get('SessionId') == null && !Test.isRunningTest()) {
            sessionId = loginToTomeksMechanics();Cache.Session.put('SessionId', sessionId);
        } else {
            sessionId = (String) Cache.Session.get('SessionId');
        }if (String.isBlank(sessionId) && !Test.isRunningTest()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Error_No_SOAP_SessionId));
            return false;
        } else {
            tomeksWebService.SessionHeader = new CsSoapSforceComSchemasClassMwMechanic.SessionHeader_element();
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
            tomeksMechanicsList = new List<CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic>();
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
        tomeksMechanicsList = new List<CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic>();
        searchFormMechanic = new CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic();
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
        this.mechanicToInsertOrUpdate = new CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic();
        popupHeader = System.Label.Add_New_Mechanic;
    }

    public void editMechanic() {
        for (CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic mechanic : tomeksMechanicsList) {
            if (mechanic.id == indexToEdit) {
                mechanicToInsertOrUpdate.firstName = mechanic.firstName;
                mechanicToInsertOrUpdate.lastName = mechanic.lastName;
                mechanicToInsertOrUpdate.mail = mechanic.mail;
                mechanicToInsertOrUpdate.city = mechanic.city;
                mechanicToInsertOrUpdate.country = mechanic.country;
                popupHeader = String.format(System.Label.Edit_Mechanic_Header, new List<String>{
                        mechanic.firstName, mechanic.lastName});
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

    public List<SelectOption> getTomeksCountryList() {
        List<SelectOption> listOfCountries = new List<SelectOption>();
        if (isServiceInitialized()) {
            listOfCountries.add(new selectOption('', '- None -'));
            for (String country : tomeksWebService.getCountryList().split(',')) {
                listOfCountries.add(new selectoption(country, country));
            }
        }
        return listOfCountries;
    }
}