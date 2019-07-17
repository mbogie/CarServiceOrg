public with sharing class CsWorkshopDetailController {

    public Workshop__c workshopFormPageController { get; set; }
    public CsLocationCallouts locationController;
    public double lat { get; set; }
    public double lon { get; set; }
    public List<Contract__c> agreementsForWorkshopPageFormController { get; set; }
    private CsSoqlQueryBuilder queryBuilder;
    public Contract__c editedContractFromAgreementsList { get; set; }
    public Mechanic__c mechanicSearchFormController { get; set; }
    private List<Mechanic__c> mechanicsSearchResultList;
    public Boolean isMechanicListSectionReady { get; set; }
    public List<CsWrapperMechanic> wrappedMechanicResultList { get; set; }
    public Boolean isContractSectionReady { get; set; }
    public Mechanic__c selectedMechanic { get; set; }
    public Contract__c newContractToAdd { get; set; }
    private Contract__c contractTemplate;
    public List<CsWrapperContract> wrappedContractsListToInsert { get; set; }
    private List<Contract__c> contractListToInsert;
    private Boolean isMechanicOnTheWrapperContractList;
    public Mechanic__c mechanicToDeleteFromContractList { get; set; }
    public Mechanic__c mechanicToEditFromContractList { get; set; }
    public Mechanic__c mechanicToSaveFromContractList { get; set; }
    public Mechanic__c mechanicTemplateFromContractList { get; set; }
    private Integer indexOfUpsertResult;
    public Boolean isAllInsertContractSuccess { get; set; }

    public CsWorkshopDetailController(ApexPages.StandardController controller) {
        this.workshopFormPageController = (Workshop__c) controller.getRecord();
        this.locationController = new CsLocationCallouts();
        this.locationController.setAddress(workshopFormPageController.Address__c, workshopFormPageController.City__c, workshopFormPageController.Country__c);
        this.locationController.newAccmethod();
        this.lat = locationController.getLat();
        this.lon = locationController.getLon();
        this.agreementsForWorkshopPageFormController = new List<Contract__c>();
        this.editedContractFromAgreementsList = new Contract__c();
        refreshAgreementsList();
        this.mechanicSearchFormController = new Mechanic__c();
        this.isMechanicListSectionReady = false;
        this.isContractSectionReady = false;
        this.wrappedContractsListToInsert = new List<CsWrapperContract>();
        this.newContractToAdd = new Contract__c();
    }

    public void refreshAgreementsList() {
        queryBuilder = new CsSoqlQueryBuilder();
        queryBuilder.addResultField('Id').addResultField('Name').
                addResultField('Mechanic__r.Full_Name__c').
                addResultField('Start_Date__c').
                addResultField('End_Date__c').
                addResultField('Status__c').
                addTableName('Contract__c').
                addSearchFieldEqualsWithValue('Workshop__c', workshopFormPageController.Id).
                addSortField('Name').
                addSortOrder('DESC').
                build();
        agreementsForWorkshopPageFormController = Database.query(queryBuilder.getQueryString());
    }

    public void dismiss() {
        for (Contract__c contract : agreementsForWorkshopPageFormController) {
            if (editedContractFromAgreementsList.Id == contract.Id) {
                editedContractFromAgreementsList = contract.clone(true);
                break;
            }
        }
        if (editedContractFromAgreementsList.Start_Date__c > System.today()) {
            try {
                delete editedContractFromAgreementsList;
                refreshAgreementsList();
            } catch (DmlException error) {
                System.debug(error.getMessage());
            }
        } else {
            editedContractFromAgreementsList.End_Date__c = System.today();
            try {
                update editedContractFromAgreementsList;
                refreshAgreementsList();
            } catch (DmlException error) {
                System.debug(error.getMessage());
            }
        }
    }

    public String getHirePopupLabel() {
        return String.format(System.Label.Hire_Workshop_Popup_Label, new List<String>{workshopFormPageController.Name});
    }

    public void search() {
        queryBuilder = new CsSoqlQueryBuilder();
        mechanicsSearchResultList = new List<Mechanic__c>();
        wrappedMechanicResultList = new List<CsWrapperMechanic>();
        queryBuilder.addResultField('Full_Name__c').
                addResultField('Email__c').
                addResultField('Country__c').
                addTableName('Mechanic__c').
                addSearchFieldStartsWithValue('Name', mechanicSearchFormController.Name).
                addSearchFieldStartsWithValue('First_Name__c', mechanicSearchFormController.First_Name__c).
                addSearchFieldStartsWithValue('Country__c', mechanicSearchFormController.Country__c).
                addSearchFieldStartsWithValue('Email__c', mechanicSearchFormController.Email__c).
                build();
        mechanicsSearchResultList = Database.query(queryBuilder.getQueryString());
        if (mechanicsSearchResultList.size() > 0) {
            isMechanicListSectionReady = true;
        }
        for (Mechanic__c mechanic : mechanicsSearchResultList) {
            isMechanicOnTheWrapperContractList = false;
            for (CsWrapperContract wrappedContract : wrappedContractsListToInsert) {
                if (mechanic.Id == wrappedContract.innerContract.Mechanic__r.Id) {
                    isMechanicOnTheWrapperContractList = true;
                }
            }
            wrappedMechanicResultList.add(new CsWrapperMechanic(mechanic, isMechanicOnTheWrapperContractList));
        }
        selectedMechanic = new Mechanic__c();
    }

    public void clear() {
        queryBuilder = new CsSoqlQueryBuilder();
        mechanicsSearchResultList = new List<Mechanic__c>();
        isMechanicListSectionReady = false;
        mechanicSearchFormController = new Mechanic__c();
    }

    public void selectMechanic() {
        mechanicTemplateFromContractList = new Mechanic__c();
        mechanicToDeleteFromContractList = new Mechanic__c();
        mechanicToEditFromContractList = new Mechanic__c();
        mechanicToSaveFromContractList = new Mechanic__c();
        isContractSectionReady = true;
        for (CsWrapperMechanic wrappedMechanic : wrappedMechanicResultList) {
            if (wrappedMechanic.innerMechanic.Id == selectedMechanic.Id) {
                wrappedMechanic.isSelectedFromList = true;
                newContractToAdd.Mechanic__c = wrappedMechanic.innerMechanic.Id;
                newContractToAdd.Mechanic__r = wrappedMechanic.innerMechanic;
                newContractToAdd.Workshop__c = workshopFormPageController.Id;
                newContractToAdd.Start_Date__c = null;
                newContractToAdd.End_Date__c = null;
                wrappedContractsListToInsert.add(new CsWrapperContract(newContractToAdd));
            }
        }
        selectedMechanic = new Mechanic__c();
        newContractToAdd = new Contract__c();
    }

    public void removeContract() {
        for (CsWrapperMechanic wrappedMechanic : wrappedMechanicResultList) {
            if (wrappedMechanic.innerMechanic.Id == mechanicToDeleteFromContractList.Id) {
                wrappedMechanic.isSelectedFromList = false;
            }
        }
        Integer indexToDelete;
        for (Integer i = 0; i < wrappedContractsListToInsert.size(); i++) {
            if (wrappedContractsListToInsert.get(i).innerContract.Mechanic__r.Id == mechanicToDeleteFromContractList.Id) {
                indexToDelete = i;
            }
        }
        wrappedContractsListToInsert.remove(indexToDelete);
        if (wrappedContractsListToInsert.size() == 0) isContractSectionReady = false;
        mechanicToDeleteFromContractList = new Mechanic__c();
    }

    public void editContract() {
        for (CsWrapperContract wrappedContract : wrappedContractsListToInsert) {
            if (wrappedContract.innerContract.Mechanic__r.Id == mechanicToEditFromContractList.Id) {
                wrappedContract.isEdited = true;
            }
        }
        mechanicToEditFromContractList = new Mechanic__c();
    }

    public void saveContract() {
        for (CsWrapperContract wrappedContract : wrappedContractsListToInsert) {
            if (wrappedContract.innerContract.Mechanic__r.Id == mechanicToSaveFromContractList.Id) {
                wrappedContract.innerContract.Mechanic__c = mechanicToSaveFromContractList.Id;
                wrappedContract.innerContract.Start_Date__c = newContractToAdd.Start_Date__c;
                wrappedContract.innerContract.End_Date__c = newContractToAdd.End_Date__c;
                wrappedContract.errorMessage = '';
                wrappedContract.isEdited = false;
            }
        }
        mechanicToSaveFromContractList = new Mechanic__c();
        newContractToAdd = new Contract__c();
    }

    public void template() {
        contractTemplate = new Contract__c();
        for (CsWrapperContract wrappedContract : wrappedContractsListToInsert) {
            if (wrappedContract.innerContract.Mechanic__r.Id == mechanicTemplateFromContractList.Id) {
                contractTemplate = wrappedContract.innerContract.clone(true);
            }
        }
        if (!((contractTemplate.Start_Date__c == null) && (contractTemplate.End_Date__c == null))) {
            for (CsWrapperContract wrapperContract : wrappedContractsListToInsert) {
                wrapperContract.innerContract.Mechanic__c = wrapperContract.innerContract.Mechanic__c;
                wrapperContract.innerContract.Start_Date__c = contractTemplate.Start_Date__c;
                wrapperContract.innerContract.End_Date__c = contractTemplate.End_Date__c;
                wrapperContract.errorMessage = '';
            }
        }
        newContractToAdd = new Contract__c();
        mechanicTemplateFromContractList = new Mechanic__c();
    }

    public void cancelHire() {
        isMechanicListSectionReady = false;
        isContractSectionReady = false;
        mechanicToSaveFromContractList = new Mechanic__c();
        mechanicToEditFromContractList = new Mechanic__c();
        mechanicTemplateFromContractList = new Mechanic__c();
        mechanicToDeleteFromContractList = new Mechanic__c();
        selectedMechanic = new Mechanic__c();
        newContractToAdd = new Contract__c();
        mechanicSearchFormController = new Mechanic__c();
        mechanicsSearchResultList = new List<Mechanic__c>();
        wrappedContractsListToInsert = new List<CsWrapperContract>();
        wrappedMechanicResultList = new List<CsWrapperMechanic>();
    }

    public void hire() {
        isAllInsertContractSuccess = true;
        indexOfUpsertResult = 0;
        contractListToInsert = new List<Contract__c>();
        for (CsWrapperContract wrappedContract : wrappedContractsListToInsert) {
            contractListToInsert.add(wrappedContract.innerContract);
        }
        Database.UpsertResult[] upsertResult = Database.upsert(contractListToInsert, Contract__c.Id, false);
        for (Database.UpsertResult result : upsertResult) {
        }
        for (CsWrapperContract wrapperContract : wrappedContractsListToInsert) {
            wrapperContract.errorMessage = '';
            if (upsertResult.get(indexOfUpsertResult).isSuccess()) {
                wrapperContract.isInsertSuccess = true;
                wrapperContract.errorMessage = '';
            } else {
                wrapperContract.isInsertSuccess = false;
                for (Database.Error err : upsertResult.get(indexOfUpsertResult).getErrors()) {
                    wrapperContract.errorMessage += err.getMessage();
                }
            }
            indexOfUpsertResult++;
        }
        isAllInsertContractSuccess = check();
        refreshAgreementsList();
    }

    private Boolean check(){
        for (CsWrapperContract wrapperContract : wrappedContractsListToInsert) {
            if(wrapperContract.isInsertSuccess == false){
                return false;
            }
        }
        return true;
    }
}