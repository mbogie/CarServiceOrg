@IsTest
private class CsTomeksWorkshopsRestControllerTest {

    @isTest static void shouldClearModalValuesAfterClose() {
        //given
        CsTomeksWorkshopsRestController controller = new CsTomeksWorkshopsRestController();
        controller.isPopupWorkshopNameEmpty = true;
        controller.wrappedTomeksWorkshopToUpsert.name = 'Upsert';
        controller.idToEdit = '123';
        controller.popupHeader = 'WrongHeader';

        //when
        Test.startTest();
        controller.clearModal();
        Test.stopTest();

        //then
        System.assertEquals(false, controller.isPopupWorkshopNameEmpty);
        System.assertEquals(null, controller.idToEdit);
        System.assertEquals(System.Label.Add_New_Workshop, controller.popupHeader);
        System.assertEquals(null, controller.wrappedTomeksWorkshopToUpsert.name);
    }

    @isTest static void shouldClearResultListAndFormValuesAfterPressingButtonClear() {
        //given
        CsTomeksWorkshopsRestController controller = new CsTomeksWorkshopsRestController();
        controller.isSearchWorkshopNameEmpty = true;
        controller.wrappedTomeksWorkshopsList = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>{new CsTomeksWorkshopsRestController.WrappedTomeksWorkshop()};
        controller.wrappedSearchFormTomeksWorkshop.name = 'Test';

        //when
        Test.startTest();
        controller.clearPage();
        Test.stopTest();

        //then
        System.assertEquals(0, controller.wrappedTomeksWorkshopsList.size());
        System.assertEquals(false, controller.isSearchWorkshopNameEmpty);
        System.assertEquals(null, controller.wrappedSearchFormTomeksWorkshop.name);
    }

    @isTest static void shouldCopyFieldValuesOfMechanicFromResultListIfIdIsEqualBeforeOpenEditPopup(){
        //given
        CsTomeksWorkshopsRestController controller = new CsTomeksWorkshopsRestController();
        CsTomeksWorkshopsRestController.WrappedTomeksWorkshop tomeksWorkshop = new CsTomeksWorkshopsRestController.WrappedTomeksWorkshop();
        tomeksWorkshop.name = 'Test';
        tomeksWorkshop.website = 'Test';
        tomeksWorkshop.phone = '123456';
        tomeksWorkshop.country = 'PL';
        tomeksWorkshop.city = 'Test';
        tomeksWorkshop.zipCode = '23';
        tomeksWorkshop.id = '123456';
        controller.wrappedTomeksWorkshopToUpsert.name = null;
        controller.wrappedTomeksWorkshopToUpsert.phone = null;
        controller.wrappedTomeksWorkshopToUpsert.website = null;
        controller.wrappedTomeksWorkshopToUpsert.city = null;
        controller.wrappedTomeksWorkshopToUpsert.country = null;
        controller.wrappedTomeksWorkshopToUpsert.zipCode = null;
        controller.idToEdit = '123456';
        controller.wrappedTomeksWorkshopsList = new List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>{tomeksWorkshop};

        //when
        Test.startTest();
        controller.editWorkshop();
        Test.stopTest();

        //then
        System.assertEquals(tomeksWorkshop.name, controller.wrappedTomeksWorkshopToUpsert.name);
        System.assertEquals(tomeksWorkshop.phone, controller.wrappedTomeksWorkshopToUpsert.phone);
        System.assertEquals(tomeksWorkshop.website, controller.wrappedTomeksWorkshopToUpsert.website);
        System.assertEquals(tomeksWorkshop.country, controller.wrappedTomeksWorkshopToUpsert.country);
        System.assertEquals(tomeksWorkshop.city, controller.wrappedTomeksWorkshopToUpsert.city);
        System.assertEquals(tomeksWorkshop.zipCode, controller.wrappedTomeksWorkshopToUpsert.zipCode);
    }

    @isTest static void shouldReturnQueryString(){
        //given
        CsTomeksWorkshopsRestController controller = new CsTomeksWorkshopsRestController();
        controller.wrappedSearchFormTomeksWorkshop.name = 'test';
        String query;

        //when
        Test.startTest();
        query = controller.createQuery();
        Test.stopTest();

        //then
        System.assertEquals('?Name__c=test',query);
    }

    @isTest static void shouldDisplayErrorMessageIfSearchNameIsEmpty() {
        //given
        CsTomeksWorkshopsRestController controller = new CsTomeksWorkshopsRestController();
        controller.wrappedSearchFormTomeksWorkshop.name = null;

        //when
        Test.startTest();
        controller.searchWorkshop();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Test.stopTest();

        //than
        System.assertEquals(true, controller.isSearchWorkshopNameEmpty);
        System.assertEquals(1, pageMessages.size());
    }

    @isTest static void shouldDisplayErrorMessageIfPopupSearchNameIsEmpty() {
        //given
        CsTomeksWorkshopsRestController controller = new CsTomeksWorkshopsRestController();
        controller.wrappedTomeksWorkshopToUpsert.name = null;

        //when
        Test.startTest();
        controller.saveWorkshop();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Test.stopTest();

        //than
        System.assertEquals(true, controller.isPopupWorkshopNameEmpty);
        System.assertEquals(1, pageMessages.size());
    }

    @isTest static void shouldReturnGoodResponseListsWithStatus200(){
        //given
        CsTomeksWorkshopsRestController controller = new CsTomeksWorkshopsRestController();
        List<SelectOption> countryList = new List<SelectOption>();
        controller.wrappedSearchFormTomeksWorkshop.name = 'test';
        controller.wrappedTomeksWorkshopToUpsert.name = 'testupsert';
        controller.idToDelete = '1111';

        Map<String, HttpCalloutMock> responseMap = new Map<String, HttpCalloutMock>();
        responseMap.put('/countries', new CsSingleRequestMock(200, '["AU","NL","PL","UA","USA"]'));
        responseMap.put('?Name__c=test', new CsSingleRequestMock(200,'[{"zipCode":null,"website":null,"phone":null,"name":"testname","id":"a012p00001GYD05AAH","country":null,"city":"testcity"}]'));
        responseMap.put('?id=1111', new CsSingleRequestMock(200,'["Success, a002p00000uNavUAAS"]'));
        responseMap.put('', new CsSingleRequestMock(200,'["Success, a002p00000uNavUAAS"]'));

        HttpCalloutMock multiCalloutMock = new CsMultiRequestMock(responseMap);

        //when
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        countryList = controller.getCountryList();
        controller.searchWorkshop();
        controller.deleteWorkshop();
        controller.saveWorkshop();
        Test.stopTest();

        //than
        System.assertEquals(6, countryList.size());
        System.assertEquals(1, controller.wrappedTomeksWorkshopsList.size());
        System.assertEquals(1, controller.responseStatusList.size());
    }

    @isTest static void shouldDisplayErrorMessageIfResponseStatusCode200(){
        //given
        CsTomeksWorkshopsRestController controller = new CsTomeksWorkshopsRestController();
        List<SelectOption> countryList = new List<SelectOption>();
        controller.wrappedSearchFormTomeksWorkshop.name = 'test';
        controller.wrappedTomeksWorkshopToUpsert.name = 'testupsert';
        controller.idToDelete = '1111';

        Map<String, HttpCalloutMock> responseMap = new Map<String, HttpCalloutMock>();
        responseMap.put('/countries', new CsSingleRequestMock(400, '[]'));
        responseMap.put('?Name__c=test', new CsSingleRequestMock(400,'[]'));
        responseMap.put('?id=1111', new CsSingleRequestMock(400,'[]'));
        responseMap.put('', new CsSingleRequestMock(400,'[]'));

        HttpCalloutMock multiCalloutMock = new CsMultiRequestMock(responseMap);

        //when
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        countryList = controller.getCountryList();
        controller.searchWorkshop();
        controller.deleteWorkshop();
        controller.saveWorkshop();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Test.stopTest();

        //than
        System.assertEquals(null, countryList);
        System.assertEquals(0, controller.wrappedTomeksWorkshopsList.size());
        System.assertEquals(0, controller.responseStatusList.size());
        System.assert(pageMessages.size()>0);
    }

    @isTest static void shouldDisplayErrorMessageIfDeleteAndSaveMethodWasFail(){
        //given
        CsTomeksWorkshopsRestController controller = new CsTomeksWorkshopsRestController();
        List<SelectOption> countryList = new List<SelectOption>();
        controller.wrappedTomeksWorkshopToUpsert.name = 'testupsert';
        controller.idToDelete = '1111';

        Map<String, HttpCalloutMock> responseMap = new Map<String, HttpCalloutMock>();
        responseMap.put('?id=1111', new CsSingleRequestMock(200,'["Error, a002p00000uNavUAAS, entity is deleted"]'));
        responseMap.put('', new CsSingleRequestMock(200,'["Error, a002p00000uNavUAAS, entity is deleted"]'));

        HttpCalloutMock multiCalloutMock = new CsMultiRequestMock(responseMap);

        //when
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        controller.deleteWorkshop();
        controller.saveWorkshop();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Test.stopTest();

        //than
        System.assertEquals(1, controller.responseStatusList.size());
        System.assert(pageMessages.size()>0);
    }
}