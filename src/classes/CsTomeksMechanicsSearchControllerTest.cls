@isTest
private class CsTomeksMechanicsSearchControllerTest {
// search
    @isTest static void shouldReturnListOfTomeksMechanics() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController(new ApexPages.StandardController(new Mechanic__c()));
        controller.mechanicSearchFormController.Name = 'Search';
        controller.mechanicSearchFormController.First_Name__c = 'Test';
        controller.mechanicSearchFormController.Email__c = 'test@test.pl';
        controller.mechanicSearchFormController.City__c = 'Lublin';
        controller.mechanicSearchFormController.Country__c = 'PL';

        //when
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CsSoapSforceComSchemasClassMwMechaniMock('SEARCH_METHOD'));
        controller.searchMechanic();
        Test.stopTest();

        //then
        System.assertEquals(1, controller.tomeksMechanicsList.size());
        System.assertEquals('Test', controller.tomeksMechanicsList.get(0).firstName);
    }

    @isTest static void shouldBlockSearchMechanicMethodAndDisplayPageErrorMessageIfFormMechanicLastNameIsBlank() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController(new ApexPages.StandardController(new Mechanic__c()));
        controller.mechanicSearchFormController.Name = null;
        controller.mechanicSearchFormController.First_Name__c = 'Test';
        controller.mechanicSearchFormController.Email__c = 'test@test.pl';
        controller.mechanicSearchFormController.City__c = 'Lublin';
        controller.mechanicSearchFormController.Country__c = 'PL';
        controller.isNameEmpty = false;

        //when
        Test.startTest();
        controller.searchMechanic();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Test.stopTest();

        //then
        System.assertEquals(true, controller.isNameEmpty);
        System.assertNotEquals(0, pageMessages.size());
    }

    @isTest static void shouldDisplayPageErrorMessageIfSearchMethodWasFail() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController(new ApexPages.StandardController(new Mechanic__c()));
        controller.mechanicSearchFormController.Name = 'Search';
        controller.mechanicSearchFormController.First_Name__c = 'Test';
        controller.mechanicSearchFormController.Email__c = 'test@test.pl';
        controller.mechanicSearchFormController.City__c = 'Lublin';
        controller.mechanicSearchFormController.Country__c = 'PL';

        //when
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CsSoapSforceComSchemasClassMwMechaniMock('WEBSERVICE_FAILED'));
        controller.searchMechanic();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Test.stopTest();

        //then
        System.assertNotEquals(0,pageMessages.size());
    }

// save
    @isTest static void shouldReturnStatusOfSaveMechanic() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController(new ApexPages.StandardController(new Mechanic__c()));
        controller.indexToEdit = '123';
        controller.mechanicToInsertOrUpdate.Name = 'Upsert';
        controller.mechanicToInsertOrUpdate.First_Name__c = 'Upsert';
        controller.mechanicToInsertOrUpdate.Email__c = 'test@test.pl';
        controller.mechanicToInsertOrUpdate.City__c = 'Upsert';
        controller.mechanicToInsertOrUpdate.Country__c = 'PL';

        //when
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CsSoapSforceComSchemasClassMwMechaniMock('UPSERT_METHOD'));
        controller.saveMechanic();
        Test.stopTest();

        //then
        System.assertEquals('Mechanic was upserted', controller.statusWrapper.id);
    }

    @isTest static void shouldBlockSaveMechanicMethodAndDisplayPageErrorMessageIfMechanicToInsertOrUpdateNameIsBlank() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController(new ApexPages.StandardController(new Mechanic__c()));
        controller.mechanicToInsertOrUpdate.Name = null;
        controller.mechanicToInsertOrUpdate.First_Name__c = 'Upsert';
        controller.mechanicToInsertOrUpdate.Email__c = 'test@test.pl';
        controller.mechanicToInsertOrUpdate.City__c = 'Upsert';
        controller.mechanicToInsertOrUpdate.Country__c = 'PL';
        controller.isPopupMechanicNameEmpty = false;

        //when
        Test.startTest();
        controller.saveMechanic();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Test.stopTest();

        //then
        System.assertNotEquals(0, pageMessages.size());
        System.assertEquals(true, controller.isPopupMechanicNameEmpty);
    }

    @isTest static void shouldDisplayPageErrorMessageIfSaveMethodReturnEmptyId() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController(new ApexPages.StandardController(new Mechanic__c()));
        controller.indexToEdit = '123';
        controller.mechanicToInsertOrUpdate.Name = 'Upsert';
        controller.mechanicToInsertOrUpdate.First_Name__c = 'Upsert';
        controller.mechanicToInsertOrUpdate.Email__c = 'test@test.pl';
        controller.mechanicToInsertOrUpdate.City__c = 'Upsert';
        controller.mechanicToInsertOrUpdate.Country__c = 'PL';

        //when
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CsSoapSforceComSchemasClassMwMechaniMock('FAIL_METHOD'));
        controller.saveMechanic();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Test.stopTest();

        //then
        System.assertEquals('Method failed', controller.statusWrapper.status);
        System.assertNotEquals(0, pageMessages.size());
    }

    @isTest static void shouldDisplayPageErrorMessageIfSaveMethodWasFail() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController(new ApexPages.StandardController(new Mechanic__c()));
        controller.indexToEdit = '123';
        controller.mechanicToInsertOrUpdate.Name = 'Upsert';
        controller.mechanicToInsertOrUpdate.First_Name__c = 'Upsert';
        controller.mechanicToInsertOrUpdate.Email__c = 'test@test.pl';
        controller.mechanicToInsertOrUpdate.City__c = 'Upsert';
        controller.mechanicToInsertOrUpdate.Country__c = 'PL';

        //when
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CsSoapSforceComSchemasClassMwMechaniMock('WEBSERVICE_FAILED'));
        ApexPages.Message[] pageMessagesBefore = ApexPages.getMessages();
        controller.saveMechanic();
        ApexPages.Message[] pageMessagesAfter = ApexPages.getMessages();
        Test.stopTest();

        //then
        System.assertEquals(0,pageMessagesBefore.size());
        System.assertNotEquals(0,pageMessagesAfter.size());
    }

// delete
    @isTest static void shouldReturnStatusAfterDeleteMechanic() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController(new ApexPages.StandardController(new Mechanic__c()));
        controller.indexToDelete = '123';

        //when
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CsSoapSforceComSchemasClassMwMechaniMock('DELETE_METHOD'));
        controller.deleteMechanic();
        Test.stopTest();

        //then
        System.assertEquals('Mechanic was deleted', controller.statusWrapper.id);
    }

    @isTest static void shouldDisplayPageErrorMessageIfDeleteMethodWasFail() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController(new ApexPages.StandardController(new Mechanic__c()));
        controller.indexToDelete = '123';

        //when
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CsSoapSforceComSchemasClassMwMechaniMock('WEBSERVICE_FAILED'));
        controller.deleteMechanic();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Test.stopTest();

        //then
        System.assertNotEquals(0, pageMessages.size());
    }

    @isTest static void shouldDisplatPageErrorMessageIfDeleteMethodReturnEmptyId(){
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController(new ApexPages.StandardController(new Mechanic__c()));
        controller.indexToDelete = '123';
        controller.mechanicToInsertOrUpdate.Name = 'Upsert';
        controller.mechanicToInsertOrUpdate.First_Name__c = 'Upsert';
        controller.mechanicToInsertOrUpdate.Email__c = 'test@test.pl';
        controller.mechanicToInsertOrUpdate.City__c = 'Upsert';
        controller.mechanicToInsertOrUpdate.Country__c = 'PL';

        //when
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CsSoapSforceComSchemasClassMwMechaniMock('FAIL_METHOD'));
        controller.deleteMechanic();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Test.stopTest();

        //then
        System.assertEquals(null, controller.statusWrapper.id);
        System.assertNotEquals(0, pageMessages.size());
    }

// other
    @isTest static void shouldClearModalValuesAfterClose() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController(new ApexPages.StandardController(new Mechanic__c()));
        controller.isPopupMechanicNameEmpty = true;
        controller.mechanicToInsertOrUpdate = new Mechanic__c(Name = 'Test');
        controller.indexToEdit = '123';
        controller.popupHeader = 'WrongHeader';

        //when
        Test.startTest();
        controller.clearModal();
        Test.stopTest();

        //then
        System.assertEquals(false, controller.isPopupMechanicNameEmpty);
        System.assertEquals(null, controller.indexToEdit);
        System.assertEquals(System.Label.Add_New_Mechanic, controller.popupHeader);
        System.assertEquals(null, controller.mechanicToInsertOrUpdate.Name);
    }

    @isTest static void shouldClearResultListAndFormValuesAfterPressingButtonClear() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController(new ApexPages.StandardController(new Mechanic__c()));
        controller.isNameEmpty = true;
        controller.tomeksMechanicsList = new List<CsTomeksMechanicsSearchController.WrapperForTomeksMechanics>{new CsTomeksMechanicsSearchController.WrapperForTomeksMechanics()};
        controller.mechanicSearchFormController = new Mechanic__c(Name = 'Test');

        //when
        Test.startTest();
        controller.clearPage();
        Test.stopTest();

        //than
        System.assertEquals(0, controller.tomeksMechanicsList.size());
        System.assertEquals(false, controller.isNameEmpty);
        System.assertEquals(null, controller.mechanicSearchFormController.Name);
    }

    @isTest static void shouldCopyFieldValuesOfMechanicFromResultListIfIdIsEqualBeforeOpenEditPopup(){
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController(new ApexPages.StandardController(new Mechanic__c()));
        CsTomeksMechanicsSearchController.WrapperForTomeksMechanics tomeksMechanic = new CsTomeksMechanicsSearchController.WrapperForTomeksMechanics();
        tomeksMechanic.id = '123456';
        tomeksMechanic.firstName = 'FNTest';
        tomeksMechanic.lastName = 'LNTest';
        tomeksMechanic.mail = 'test@test.pl';
        tomeksMechanic.countryName = 'ConTest';
        tomeksMechanic.city = 'CitTest';
        controller.mechanicToInsertOrUpdate.Name = null;
        controller.mechanicToInsertOrUpdate.First_Name__c = null;
        controller.mechanicToInsertOrUpdate.Email__c = null;
        controller.mechanicToInsertOrUpdate.City__c = null;
        controller.mechanicToInsertOrUpdate.Country__c = null;
        controller.indexToEdit = '123456';
        controller.tomeksMechanicsList = new List<CsTomeksMechanicsSearchController.WrapperForTomeksMechanics>{tomeksMechanic};

        //when
        Test.startTest();
        controller.editMechanic();
        Test.stopTest();

        //than
        System.assertEquals(tomeksMechanic.firstName, controller.mechanicToInsertOrUpdate.First_Name__c);
        System.assertEquals(tomeksMechanic.lastName, controller.mechanicToInsertOrUpdate.Name);
        System.assertEquals(tomeksMechanic.mail, controller.mechanicToInsertOrUpdate.Email__c);
        System.assertEquals(tomeksMechanic.countryName, controller.mechanicToInsertOrUpdate.Country__c);
        System.assertEquals(tomeksMechanic.city, controller.mechanicToInsertOrUpdate.City__c);
    }
}