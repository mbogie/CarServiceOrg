public with sharing class CsTomeksMechanicsSearchController {

    public Mechanic__c mechanicSearchFormController { get; set; }
    public List<WrapperForTomeksMechanics> tomeksMechanicsList { get; set; }
    private CsSoqlQueryBuilder queryBuilder;
    public Boolean isNameEmpty { get; set; }
    public Mechanic__c mechanicToInsertOrUpdate { get; set; }
    public Boolean isPopupMechanicNameEmpty { get; set; }
    public Boolean isEditedMechanicNameEmpty { get; set; }
    public Boolean isActionSuccess { get; set; }
    public String indexToDelete { get; set; }
    public String indexToEdit { get; set; }

    public class WrapperForTomeksMechanics {
        public String id { get; set; }
        public String lastName { get; set; }
        public String firstName { get; set; }
        public String countryName { get; set; }
        public String mail { get; set; }
        public String city { get; set; }

        public WrapperForTomeksMechanics(){}

        public WrapperForTomeksMechanics(CsSoapSforceComSchemasClassMwMechani.WrappedMechanic mechanic) {
            this.id = mechanic.id;
            this.lastName = mechanic.lastName;
            this.firstName = mechanic.firstName;
            this.countryName = mechanic.country;
            this.mail = mechanic.mail;
            this.city = mechanic.city;
        }
    }

    public CsTomeksMechanicsSearchController(ApexPages.StandardController controller) {
        this.mechanicSearchFormController = (Mechanic__c) controller.getRecord();
        this.isNameEmpty = false;
        this.isPopupMechanicNameEmpty = false;
        this.isEditedMechanicNameEmpty = false;
        this.mechanicToInsertOrUpdate = new Mechanic__c();
        this.isActionSuccess = false;
        this.tomeksMechanicsList = new List<WrapperForTomeksMechanics>();
    }

    public static String loginToTomeksMechanics() {
        try {
            CsPartnerSoapSforceCom.Soap partnerSoap = new CsPartnerSoapSforceCom.Soap();
            CsPartnerSoapSforceCom.LoginResult loginResult = partnerSoap.login('tomek.starzak@gmail.com', 'Test1234sDKbP76CNGMdzE4aTTfL1gSEn');
            return loginResult.sessionId;
        } catch (Exception err) {
            System.debug('Login error: ' + err.getMessage());
            return null;
        }
    }

    public void searchMechanic() {
        if (String.isEmpty(mechanicSearchFormController.Name)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Required_Input_Field_Error));
            isNameEmpty = true;
            return ;
        }
        isNameEmpty = false;
        String sessionId = loginToTomeksMechanics();
        if (String.isBlank(sessionId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Empty SessionId'));
        } else {
            CsSoapSforceComSchemasClassMwMechani.MW_MechanicWebService tomeksWebService = new CsSoapSforceComSchemasClassMwMechani.MW_MechanicWebService();
            tomeksWebService.SessionHeader = new CsSoapSforceComSchemasClassMwMechani.SessionHeader_element();
            tomeksWebService.SessionHeader.sessionId = sessionId;

            tomeksMechanicsList = new List<CsTomeksMechanicsSearchController.WrapperForTomeksMechanics>();
            List<CsSoapSforceComSchemasClassMwMechani.WrappedMechanic> wrappedMechanics = new List<CsSoapSforceComSchemasClassMwMechani.WrappedMechanic>();
            wrappedMechanics =
                    tomeksWebService.fetchRecords(mechanicSearchFormController.First_Name__c, mechanicSearchFormController.Name, mechanicSearchFormController.Email__c, mechanicSearchFormController.City__c, mechanicSearchFormController.Country__c);
            if(wrappedMechanics != null) {
                for (CsSoapSforceComSchemasClassMwMechani.WrappedMechanic wrappedMechanic : wrappedMechanics) {
                    tomeksMechanicsList.add(new WrapperForTomeksMechanics(wrappedMechanic));
                }
            }
        }
    }

    public void clearPage() {
        isNameEmpty = false;
        tomeksMechanicsList = new List<WrapperForTomeksMechanics>();
        mechanicSearchFormController = new Mechanic__c();
    }

    public void saveMechanic() {
        isActionSuccess = true;
        isPopupMechanicNameEmpty = false;
        if (String.isEmpty(mechanicToInsertOrUpdate.Name)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error field'));
            isPopupMechanicNameEmpty = true;
            isActionSuccess = false;
            return ;
        } else {
            String sessionId = loginToTomeksMechanics();
            if (String.isBlank(sessionId)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Empty SessionId'));
            } else {
                CsSoapSforceComSchemasClassMwMechani.MW_MechanicWebService tomeksWebService = new CsSoapSforceComSchemasClassMwMechani.MW_MechanicWebService();
                tomeksWebService.SessionHeader = new CsSoapSforceComSchemasClassMwMechani.SessionHeader_element();
                tomeksWebService.SessionHeader.sessionId = sessionId;

                CsSoapSforceComSchemasClassMwMechani.MechanicIdStatusWrapper statusWrapper = tomeksWebService.addOrEditMechanic(indexToEdit,mechanicToInsertOrUpdate.First_Name__c,mechanicToInsertOrUpdate.Name,mechanicToInsertOrUpdate.Email__c,mechanicToInsertOrUpdate.City__c,mechanicToInsertOrUpdate.Country__c);
                System.debug('status --> ' + statusWrapper);

            }
            if (!String.isBlank(mechanicSearchFormController.Name)) {
                searchMechanic();
            }
        }
    }

    public void clearModal() {
        isPopupMechanicNameEmpty = false;
        mechanicToInsertOrUpdate = new Mechanic__c();
    }

    public void addMechanic() {
        indexToEdit = null;
    }

    public void editMechanic() {
        for (WrapperForTomeksMechanics mechanic : tomeksMechanicsList) {
            if (mechanic.id == indexToEdit) {
                mechanicToInsertOrUpdate.First_Name__c = mechanic.firstName;
                mechanicToInsertOrUpdate.Name = mechanic.lastName;
                mechanicToInsertOrUpdate.Email__c = mechanic.mail;
                mechanicToInsertOrUpdate.City__c = mechanic.city;
                mechanicToInsertOrUpdate.Country__c = mechanic.countryName;
                System.debug('mechanicToInsert -->' + mechanic);
            }
        }
    }

    public void deleteMechanic() {
        String sessionId = loginToTomeksMechanics();
        if (String.isBlank(sessionId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Empty SessionId'));
        } else {
            CsSoapSforceComSchemasClassMwMechani.MW_MechanicWebService tomeksWebService = new CsSoapSforceComSchemasClassMwMechani.MW_MechanicWebService();
            tomeksWebService.SessionHeader = new CsSoapSforceComSchemasClassMwMechani.SessionHeader_element();
            tomeksWebService.SessionHeader.sessionId = sessionId;
            CsSoapSforceComSchemasClassMwMechani.MechanicIdStatusWrapper statusWrapper = tomeksWebService.deleteMechanic(indexToDelete);
        }
        if (!String.isBlank(mechanicSearchFormController.Name)) {
            searchMechanic();
        }
    }
}