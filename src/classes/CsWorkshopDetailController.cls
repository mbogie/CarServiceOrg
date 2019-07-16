public with sharing class CsWorkshopDetailController {

    public Workshop__c workshopFormPageController { get; set; }
    public CsLocationCallouts locationController;
    public double lat { get; set; }
    public double lon { get; set; }
    public List<Contract__c> agreementsForWorkshopPageFormController { get; set; }
    private CsSoqlQueryBuilder queryBuilder;
    public Mechanic__c mechanicSearchPageController { get; set; }
    public List<Mechanic__c> mechanicSearchResultList { get; set; }
    public Boolean isMechanicListSectionReady { get; set; }
    public Mechanic__c mechanicChoosen { get; set; }
    public Mechanic__c mechanicToDelete { get; set; }
    public Contract__c editedContractInUse { get; set; }
    public Boolean isContractSectionReady { get; set; }
    public List<CsContractInsertWrapper> wrappedContractToInsertList { get; set; }
    public List<Contract__c> contractToInsertList { get; set; }
    public CsImportMechanicWrapper wrappedMechanic { get; set; }
    public List<CsImportMechanicWrapper> wrappedMechanicsList { get; set; }
    public Boolean isMechanicOnTheWrapperList;

    public CsWorkshopDetailController(ApexPages.StandardController controller) {
        this.workshopFormPageController = (Workshop__c) controller.getRecord();
        this.locationController = new CsLocationCallouts();
        this.locationController.setAddress(workshopFormPageController.Address__c, workshopFormPageController.City__c, workshopFormPageController.Country__c);
        this.locationController.newAccmethod();
        this.lat = locationController.getLat();
        this.lon = locationController.getLon();
        this.agreementsForWorkshopPageFormController = new List<Contract__c>();
        this.editedContractInUse = new Contract__c();
        refreshAgreementsList();
        this.mechanicSearchPageController = new Mechanic__c();
        this.isMechanicListSectionReady = false;
        this.isContractSectionReady = false;
        this.mechanicSearchResultList = new List<Mechanic__c>();
        this.wrappedMechanicsList = new List<CsImportMechanicWrapper>();
        this.mechanicChoosen = new Mechanic__c();
        this.mechanicToDelete = new Mechanic__c();
        this.contractToInsertList = new List<Contract__c>();
        this.wrappedContractToInsertList = new List<CsContractInsertWrapper>();
        this.isMechanicOnTheWrapperList = false;
    }

    public void refreshAgreementsList() {
        queryBuilder = new CsSoqlQueryBuilder();
        queryBuilder.addResultField('Id').addResultField('Name').
                addResultField('Mechanic__r.Full_Name__c').
                addResultField('Start_Date__c').
                addResultField('End_Date__c').
                addTableName('Contract__c').
                addSearchFieldEqualsWithValue('Workshop__c', workshopFormPageController.Id).
                addSortField('Name').
                addSortOrder('DESC').
                build();
        agreementsForWorkshopPageFormController = Database.query(queryBuilder.getQueryString());
    }

    public void dismiss() {
        for (Contract__c contract : agreementsForWorkshopPageFormController) {
            if (editedContractInUse.Id == contract.Id) {
                editedContractInUse = contract.clone(true);
                break;
            }
        }
        if (editedContractInUse.Start_Date__c > System.today()) {
            try {
                delete editedContractInUse;
                refreshAgreementsList();
            } catch (DmlException error) {
                System.debug(error.getMessage());
            }
        } else {
            editedContractInUse.End_Date__c = System.today();
            try {
                update editedContractInUse;
                refreshAgreementsList();
            } catch (DmlException error) {
                System.debug(error.getMessage());
            }
        }
    }

    public String getHirePopupLabel() {
        return String.format(System.Label.Hire_Workshop_Popup_Label, new List<String>{
                workshopFormPageController.Name
        });
    }

    public void search() {
        queryBuilder = new CsSoqlQueryBuilder();
        wrappedMechanicsList = new List<CsImportMechanicWrapper>();
        mechanicSearchResultList = new List<Mechanic__c>();
        queryBuilder.addResultField('Full_Name__c').
                addResultField('Email__c').
                addResultField('Country__c').
                addTableName('Mechanic__c').
                addSearchFieldStartsWithValue('Name', mechanicSearchPageController.Name).
                addSearchFieldStartsWithValue('First_Name__c', mechanicSearchPageController.First_Name__c).
                addSearchFieldStartsWithValue('Country__c', mechanicSearchPageController.Country__c).
                addSearchFieldStartsWithValue('Email__c', mechanicSearchPageController.Email__c).
                build();
        mechanicSearchResultList = Database.query(queryBuilder.getQueryString());
        if (mechanicSearchResultList.size() > 0) {
            isMechanicListSectionReady = true;
        }
        for (Mechanic__c mechanic : mechanicSearchResultList) {
            isMechanicOnTheWrapperList = false;
            for(CsContractInsertWrapper wrappedMechanic : wrappedContractToInsertList){
                if(mechanic.Id == wrappedMechanic.contractToInsert.Mechanic__r.Id){
                    isMechanicOnTheWrapperList = true;
                }
            }
            if(isMechanicOnTheWrapperList) wrappedMechanicsList.add(new CsImportMechanicWrapper(mechanic, true));
            else wrappedMechanicsList.add(new CsImportMechanicWrapper(mechanic, false));

        }
    }

    public void clear() {
        queryBuilder.clear();
        mechanicSearchResultList.clear();
        isMechanicListSectionReady = false;
        mechanicSearchPageController = new Mechanic__c();
    }

    public void selectMechanic() {
        isContractSectionReady = true;
        for (CsImportMechanicWrapper wrappedMechanic : wrappedMechanicsList) {
            if (wrappedMechanic.wrappedMechanic.Id == mechanicChoosen.Id) {
                wrappedMechanic.isSelectedFromList = true;
                mechanicChoosen = wrappedMechanic.wrappedMechanic.clone(true);
                editedContractInUse = new Contract__c();
                editedContractInUse.Mechanic__r = mechanicChoosen;
                editedContractInUse.Workshop__c = workshopFormPageController.Id;
                wrappedContractToInsertList.add(new CsContractInsertWrapper(editedContractInUse));
                break;
            }
        }
        mechanicChoosen = new Mechanic__c();
        editedContractInUse = new Contract__c();
    }

    public void removeContract() {
        for (CsImportMechanicWrapper wrappedMechanic : wrappedMechanicsList) {
            if (wrappedMechanic.wrappedMechanic.Id == mechanicToDelete.Id) {
                wrappedMechanic.isSelectedFromList = false;
            }
        }
        Integer indexToDelete;
        for(Integer i = 0; i<wrappedContractToInsertList.size();i++){
            if(wrappedContractToInsertList.get(i).contractToInsert.Mechanic__r.Id == mechanicToDelete.Id){
                indexToDelete = i;
            }
        }
        wrappedContractToInsertList.remove(indexToDelete);
        if(wrappedContractToInsertList.size()==0) isContractSectionReady = false;
        mechanicToDelete = new Mechanic__c();
    }

    public void editContract(){
        for(CsContractInsertWrapper wrappedContract : wrappedContractToInsertList){
            if(wrappedContract.contractToInsert.Mechanic__r.Id == mechanicChoosen.Id){
                wrappedContract.isChoosenToEdit = true;
            }
        }
        mechanicChoosen = new Mechanic__c();
    }

    public void template(){
        for(CsContractInsertWrapper wrappedContract : wrappedContractToInsertList){
            if(wrappedContract.contractToInsert.Mechanic__r.Id == mechanicChoosen.Id){
                editedContractInUse = wrappedContract.contractToInsert.clone(true);
            }
        }
        for(CsContractInsertWrapper wrappedContract : wrappedContractToInsertList){
            wrappedContract.contractToInsert.Start_Date__c = editedContractInUse.Start_Date__c;
            wrappedContract.contractToInsert.End_Date__c = editedContractInUse.End_Date__c;
        }

    }

    public void saveContract(){
        for(CsContractInsertWrapper wrappedContract : wrappedContractToInsertList){
            if(wrappedContract.contractToInsert.Mechanic__r.Id == mechanicChoosen.Id){
                wrappedContract.contractToInsert.Start_Date__c = editedContractInUse.Start_Date__c;
                wrappedContract.contractToInsert.End_Date__c = editedContractInUse.End_Date__c;
                wrappedContract.isChoosenToEdit = false;
            }
        }
        mechanicChoosen = new Mechanic__c();
        editedContractInUse = new Contract__c();
    }

    public void cancelHire() {
        editedContractInUse = new Contract__c();
        mechanicSearchPageController = new Mechanic__c();
        isMechanicListSectionReady = false;
        isContractSectionReady = false;
        mechanicSearchResultList = new List<Mechanic__c>();
        wrappedMechanicsList = new List<CsImportMechanicWrapper>();
        mechanicChoosen = new Mechanic__c();
        mechanicToDelete = new Mechanic__c();
        contractToInsertList = new List<Contract__c>();
        wrappedContractToInsertList = new List<CsContractInsertWrapper>();
    }

    public void hire(){



    }
}