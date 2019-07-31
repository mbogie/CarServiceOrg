@isTest
private class CsTomeksMechanicsSearchControllerTest {


// search
    @isTest static void shouldReturnListOfTomeksMechanics() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController();
        controller.searchFormMechanic.lastName = 'Search';
        controller.searchFormMechanic.firstName = 'Test';
        controller.searchFormMechanic.mail = 'test@test.pl';
        controller.searchFormMechanic.city = 'Lublin';
        controller.searchFormMechanic.country = 'PL';

        //when
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CsSoapMwMechanicMock('SEARCH_METHOD'));
        controller.searchMechanic();
        Test.stopTest();

        //then
        System.assertEquals(1, controller.tomeksMechanicsList.size());
        System.assertEquals('Test', controller.tomeksMechanicsList.get(0).firstName);
    }

    @isTest static void shouldBlockSearchMechanicMethodAndDisplayPageErrorMessageIfFormMechanicLastNameIsBlank() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController();
        controller.searchFormMechanic.lastName = null;
        controller.searchFormMechanic.firstName = 'Test';
        controller.searchFormMechanic.mail = 'test@test.pl';
        controller.searchFormMechanic.city = 'Lublin';
        controller.searchFormMechanic.country = 'PL';
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
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController();
        controller.searchFormMechanic.lastName = 'Search';
        controller.searchFormMechanic.firstName = 'Test';
        controller.searchFormMechanic.mail = 'test@test.pl';
        controller.searchFormMechanic.city = 'Lublin';
        controller.searchFormMechanic.country = 'PL';

        //when
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CsSoapMwMechanicMock('WEBSERVICE_FAILED'));
        controller.searchMechanic();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Test.stopTest();

        //then
        System.assertNotEquals(0,pageMessages.size());
    }

// save
    @isTest static void shouldReturnStatusOfSaveMechanic() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController();
        controller.indexToEdit = '123';
        controller.mechanicToInsertOrUpdate.lastName = 'Upsert';
        controller.mechanicToInsertOrUpdate.firstName = 'Upsert';
        controller.mechanicToInsertOrUpdate.mail = 'test@test.pl';
        controller.mechanicToInsertOrUpdate.city = 'Upsert';
        controller.mechanicToInsertOrUpdate.country = 'PL';

        //when
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CsSoapMwMechanicMock('UPSERT_METHOD'));
        controller.saveMechanic();
        Test.stopTest();

        //then
        System.assertEquals('Mechanic was upserted', controller.statusWrapper.id);
    }

    @isTest static void shouldBlockSaveMechanicMethodAndDisplayPageErrorMessageIfMechanicToInsertOrUpdateNameIsBlank() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController();
        controller.mechanicToInsertOrUpdate.lastName = null;
        controller.mechanicToInsertOrUpdate.firstName = 'Upsert';
        controller.mechanicToInsertOrUpdate.mail = 'test@test.pl';
        controller.mechanicToInsertOrUpdate.city = 'Upsert';
        controller.mechanicToInsertOrUpdate.country = 'PL';
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
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController();
        controller.indexToEdit = '123';
        controller.mechanicToInsertOrUpdate.lastName = 'Upsert';
        controller.mechanicToInsertOrUpdate.firstName = 'Upsert';
        controller.mechanicToInsertOrUpdate.mail = 'test@test.pl';
        controller.mechanicToInsertOrUpdate.city = 'Upsert';
        controller.mechanicToInsertOrUpdate.country = 'PL';

        //when
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CsSoapMwMechanicMock('FAIL_METHOD_ADD'));
        controller.saveMechanic();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Test.stopTest();

        //then
        System.assertEquals('Method failed', controller.statusWrapper.status);
        System.assertNotEquals(0, pageMessages.size());
    }

    @isTest static void shouldDisplayPageErrorMessageIfSaveMethodWasFail() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController();
        controller.indexToEdit = '123';
        controller.mechanicToInsertOrUpdate.lastName = 'Upsert';
        controller.mechanicToInsertOrUpdate.firstName = 'Upsert';
        controller.mechanicToInsertOrUpdate.mail = 'test@test.pl';
        controller.mechanicToInsertOrUpdate.city = 'Upsert';
        controller.mechanicToInsertOrUpdate.country = 'PL';

        //when
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CsSoapMwMechanicMock('WEBSERVICE_FAILED'));
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
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController();
        controller.indexToDelete = '123';

        //when
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CsSoapMwMechanicMock('DELETE_METHOD'));
        controller.deleteMechanic();
        Test.stopTest();

        //then
        System.assertEquals('Mechanic was deleted', controller.statusWrapper.id);
    }

    @isTest static void shouldDisplayPageErrorMessageIfDeleteMethodWasFail() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController();
        controller.indexToDelete = '123';

        //when
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CsSoapMwMechanicMock('WEBSERVICE_FAILED'));
        controller.deleteMechanic();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Test.stopTest();

        //then
        System.assertNotEquals(0, pageMessages.size());
    }

    @isTest static void shouldDisplayPageErrorMessageIfDeleteMethodReturnEmptyId(){
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController();
        controller.indexToDelete = null;

        //when
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CsSoapMwMechanicMock('FAIL_DELETE_METHOD'));
        controller.deleteMechanic();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Test.stopTest();

        //then
        System.assertEquals(null, controller.statusWrapper.id);
        System.assertNotEquals('Delete method fail', controller.statusWrapper.status);
        System.assertNotEquals(0, pageMessages.size());
    }

// other
    @isTest static void shouldClearModalValuesAfterClose() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController();
        controller.isPopupMechanicNameEmpty = true;
        controller.mechanicToInsertOrUpdate.lastName = 'Upsert';
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
        System.assertEquals(null, controller.mechanicToInsertOrUpdate.lastName);
    }

    @isTest static void shouldClearResultListAndFormValuesAfterPressingButtonClear() {
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController();
        controller.isNameEmpty = true;
        controller.tomeksMechanicsList = new List<CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic>{new CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic()};
        controller.searchFormMechanic.lastName = 'Test';

        //when
        Test.startTest();
        controller.clearPage();
        Test.stopTest();

        //then
        System.assertEquals(0, controller.tomeksMechanicsList.size());
        System.assertEquals(false, controller.isNameEmpty);
        System.assertEquals(null, controller.searchFormMechanic.lastName);
    }

    @isTest static void shouldCopyFieldValuesOfMechanicFromResultListIfIdIsEqualBeforeOpenEditPopup(){
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController();
        CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic tomeksMechanic = new CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic();
        tomeksMechanic.id = '123456';
        tomeksMechanic.firstName = 'FNTest';
        tomeksMechanic.lastName = 'LNTest';
        tomeksMechanic.mail = 'test@test.pl';
        tomeksMechanic.country = 'ConTest';
        tomeksMechanic.city = 'CitTest';
        controller.mechanicToInsertOrUpdate.lastName = null;
        controller.mechanicToInsertOrUpdate.firstName = null;
        controller.mechanicToInsertOrUpdate.mail = null;
        controller.mechanicToInsertOrUpdate.city = null;
        controller.mechanicToInsertOrUpdate.country = null;
        controller.indexToEdit = '123456';
        controller.tomeksMechanicsList = new List<CsSoapSforceComSchemasClassMwMechanic.WrappedMechanic>{tomeksMechanic};

        //when
        Test.startTest();
        controller.editMechanic();
        Test.stopTest();

        //then
        System.assertEquals(tomeksMechanic.firstName, controller.mechanicToInsertOrUpdate.firstName);
        System.assertEquals(tomeksMechanic.lastName, controller.mechanicToInsertOrUpdate.lastName);
        System.assertEquals(tomeksMechanic.mail, controller.mechanicToInsertOrUpdate.mail);
        System.assertEquals(tomeksMechanic.country, controller.mechanicToInsertOrUpdate.country);
        System.assertEquals(tomeksMechanic.city, controller.mechanicToInsertOrUpdate.city);
    }

    @isTest static void shouldReturnCountryList(){
        //given
        CsTomeksMechanicsSearchController controller = new CsTomeksMechanicsSearchController();
        List<SelectOption> countryList = new List<SelectOption>();

        //when
        Test.startTest();
        Test.setMock(WebServiceMock.class, new CsSoapMwMechanicMock('COUNTRY_LIST'));
        countryList = controller.getTomeksCountryList();
        Test.stopTest();

        //then
        System.assert(countryList.size()>0);
    }


}