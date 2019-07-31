@IsTest
private class CsTomeksWorkshopsRestControllerTest {

// other
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

    @isTest static void shouldReturnWorkshopListAfterGetMethod() {
        //given
        CsTomeksWorkshopsRestController controller = new CsTomeksWorkshopsRestController();
        controller.wrappedSearchFormTomeksWorkshop.name = 'test';

        //when
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CsSingleRequestMock());
        controller.saveWorkshop();
        Test.stopTest();

        //than
        System.assertEquals(1, controller.wrappedTomeksWorkshopsList.size());
    }

    @isTest static void shouldReturnStatus300() {
        //given
        CsTomeksWorkshopsRestController controller = new CsTomeksWorkshopsRestController();
        controller.wrappedSearchFormTomeksWorkshop.name = 'fail';

        //when
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CsSingleRequestMock());
        controller.saveWorkshop();
        Test.stopTest();

        //than
        System.assertEquals(0, controller.wrappedTomeksWorkshopsList.size());
    }
}