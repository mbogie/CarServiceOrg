public with sharing class testClass {

    public void clearPage() {
        isNameEmpty = false;
        tomeksMechanicsList = new List<WrapperForTomeksMechanics>();
        mechanicsSearchResultList = new List<Mechanic__c>();
        mechanicPageFormController = new Mechanic__c();
    }

    public void addMechanic() {
        isActionSuccess = true;
        isNewMechanicNameEmpty = false;
        if (String.isEmpty(newMechanic.Name)) {
            isNewMechanicNameEmpty = true;
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

                CsSoapSforceComSchemasClassMwMechani.MechanicIdStatusWrapper statusWrapper = tomeksWebService.addOrEditMechanic(null,newMechanic.First_Name__c,newMechanic.Name,newMechanic.Email__c,newMechanic.City__c,newMechanic.Country__c);
                System.debug('newMechanic --> ' + statusWrapper);
            }
            if (!String.isBlank(mechanicPageFormController.Name)) {
                searchMechanic();
            }
        }
    }

    public void clearNewMechanic() {
        isNewMechanicNameEmpty = false;
        newMechanic = new Mechanic__c();
    }

    public void editMechanic() {
        for (WrapperForTomeksMechanics mechanic : tomeksMechanicsList) {
            if (mechanic.id == indexToEdit) {
                editedMechanic.First_Name__c = mechanic.firstName;
                editedMechanic.Name = mechanic.lastName;
                editedMechanic.Email__c = mechanic.mail;
                editedMechanic.City__c = mechanic.city;
                editedMechanic.Country__c = mechanic.countryName;
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
            System.debug('newMechanic --> ' + statusWrapper);
        }
        if (!String.isBlank(mechanicPageFormController.Name)) {
            searchMechanic();
        }
    }

    public void clearEditMechanic() {
        isEditedMechanicNameEmpty = false;
        editedMechanic = new Mechanic__c();
    }

    public void saveEditedMechanic() {
        isActionSuccess = true;
        isEditedMechanicNameEmpty = false;
        if (String.isBlank(editedMechanic.Name)) {
            isEditedMechanicNameEmpty = true;
            isActionSuccess = false;
            return ;
        }else {
            String sessionId = loginToTomeksMechanics();
            if (String.isBlank(sessionId)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Empty SessionId'));
            } else {
                CsSoapSforceComSchemasClassMwMechani.MW_MechanicWebService tomeksWebService = new CsSoapSforceComSchemasClassMwMechani.MW_MechanicWebService();
                tomeksWebService.SessionHeader = new CsSoapSforceComSchemasClassMwMechani.SessionHeader_element();
                tomeksWebService.SessionHeader.sessionId = sessionId;

                CsSoapSforceComSchemasClassMwMechani.MechanicIdStatusWrapper statusWrapper = tomeksWebService.addOrEditMechanic(indexToEdit,editedMechanic.First_Name__c,editedMechanic.Name,editedMechanic.Email__c,editedMechanic.City__c,editedMechanic.Country__c);
                System.debug('newMechanic --> ' + statusWrapper);
            }
            if (!String.isBlank(mechanicPageFormController.Name)) {
                searchMechanic();
            }
        }
    }

}