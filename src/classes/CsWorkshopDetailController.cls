public with sharing class CsWorkshopDetailController {

    public Workshop__c workshopFormPageController { get; set; }
    public CsLocationCallouts locationController;
    public double lat { get; set; }
    public double lon { get; set; }
    public List<Contract__c> agreementsForWorkshopPageFormController { get; set; }
    public Contract__c editedContractFromAgreementsList { get; set; }
    private CsSoqlQueryBuilder queryBuilder;
    public Mechanic__c mechanicSearchFormController { get; set; }
    public Mechanic__c selectedMechanic { get; set; }
    private List<Mechanic__c> mechanicsSearchResultList;
    public List<CsWrapperMechanic> wrappedMechanicResultList { get; set; }
    public Contract__c selectedContract { get; set; }
    public List<CsWrapperContract> wrappedContractsListToInsert { get; set; }
    private List<Contract__c> contractListToInsert;
    public Boolean isAllInsertContractSuccess { get; set; }
    public Boolean isMechanicListSectionReady { get; set; }
    public Boolean isContractSectionReady { get; set; }
    private Boolean isMechanicOnTheWrapperContractList;
    public Boolean isButtonsDisabledAfterEditedContract { get; set; }
    private Integer indexOfUpsertResult;

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
        this.isButtonsDisabledAfterEditedContract = false;
        this.isMechanicListSectionReady = false;
        this.isContractSectionReady = false;
        this.wrappedContractsListToInsert = new List<CsWrapperContract>();
        this.mechanicSearchFormController = new Mechanic__c();
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
        return String.format(System.Label.Hire_Workshop_Popup_Label, new List<String>{
                workshopFormPageController.Name
        });
    }

    public void search() {
        if (checkIfButtonsAreDisabled()) return;
        isAllInsertContractSuccess = false;
        queryBuilder = new CsSoqlQueryBuilder();
        selectedMechanic = new Mechanic__c();
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
        if (mechanicsSearchResultList.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, System.Label.Search_Empty_Record_List));
            isMechanicListSectionReady = false;
        }else {
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
    }

    public void clear() {
        if (checkIfButtonsAreDisabled()) return;
        mechanicsSearchResultList = new List<Mechanic__c>();
        isMechanicListSectionReady = false;
        mechanicSearchFormController = new Mechanic__c();
    }

    public void selectMechanic() {
        if (checkIfButtonsAreDisabled()) return;
        selectedContract = new Contract__c();
        for (CsWrapperMechanic wrappedMechanic : wrappedMechanicResultList) {
            if (wrappedMechanic.innerMechanic.Id == selectedMechanic.Id) {
                wrappedMechanic.isSelectedFromList = true;
                selectedContract.Mechanic__c = wrappedMechanic.innerMechanic.Id;
                selectedContract.Mechanic__r = wrappedMechanic.innerMechanic;
                selectedContract.Workshop__c = workshopFormPageController.Id;
                selectedContract.Start_Date__c = null;
                selectedContract.End_Date__c = null;
                wrappedContractsListToInsert.add(new CsWrapperContract(selectedContract));
            }
        }
        selectedMechanic = new Mechanic__c();
        isContractSectionReady = true;
    }

    public void removeContract() {
        if (checkIfButtonsAreDisabled()) return;
        for (CsWrapperMechanic wrappedMechanic : wrappedMechanicResultList) {
            if (wrappedMechanic.innerMechanic.Id == selectedMechanic.Id) {
                wrappedMechanic.isSelectedFromList = false;
            }
        }
        Integer indexToDelete;
        for (Integer i = 0; i < wrappedContractsListToInsert.size(); i++) {
            if (wrappedContractsListToInsert.get(i).innerContract.Mechanic__r.Id == selectedMechanic.Id) {
                indexToDelete = i;
            }
        }
        wrappedContractsListToInsert.remove(indexToDelete);
        if (wrappedContractsListToInsert.size() == 0) isContractSectionReady = false;
        selectedMechanic = new Mechanic__c();
    }

    public void editContract() {
        if (checkIfButtonsAreDisabled()) return;
        for (CsWrapperContract wrappedContract : wrappedContractsListToInsert) {
            if (wrappedContract.innerContract.Mechanic__r.Id == selectedMechanic.Id) {
                wrappedContract.isEdited = true;
            }
        }
        isButtonsDisabledAfterEditedContract = true;
        selectedMechanic = new Mechanic__c();
    }

    public void saveContract() {
        for (CsWrapperContract wrappedContract : wrappedContractsListToInsert) {
            if (wrappedContract.innerContract.Mechanic__r.Id == selectedMechanic.Id) {
                wrappedContract.errorMessage = '';
                wrappedContract.isEdited = false;
            }
        }
        isButtonsDisabledAfterEditedContract = false;
        selectedMechanic = new Mechanic__c();
    }

    public void template() {
        if (checkIfButtonsAreDisabled()) return;
        for (CsWrapperContract wrappedContract : wrappedContractsListToInsert) {
            if (wrappedContract.innerContract.Mechanic__r.Id == selectedMechanic.Id) {
                selectedContract = wrappedContract.innerContract.clone(true);
            }
        }
        if (!((selectedContract.Start_Date__c == null) && (selectedContract.End_Date__c == null))) {
            for (CsWrapperContract wrappedContract : wrappedContractsListToInsert) {
                if (!wrappedContract.isInsertSuccess) {
                    wrappedContract.innerContract.Start_Date__c = selectedContract.Start_Date__c;
                    wrappedContract.innerContract.End_Date__c = selectedContract.End_Date__c;
                    wrappedContract.errorMessage = '';
                }
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, System.Label.Workshop_Hire_Template_Message));
        }
        selectedContract = new Contract__c();
        selectedMechanic = new Mechanic__c();
    }

    public void cancelHire() {
        isMechanicListSectionReady = false;
        isContractSectionReady = false;
        selectedMechanic = new Mechanic__c();
        selectedContract = new Contract__c();
        mechanicSearchFormController = new Mechanic__c();
        mechanicsSearchResultList = new List<Mechanic__c>();
        wrappedContractsListToInsert = new List<CsWrapperContract>();
        wrappedMechanicResultList = new List<CsWrapperMechanic>();
        isButtonsDisabledAfterEditedContract = false;
    }

    public void hire() {
        if (checkIfButtonsAreDisabled()) return;
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
        isAllInsertContractSuccess = checkIfAllInsertsAreSuccess();
        refreshAgreementsList();
    }
    private Boolean checkIfAllInsertsAreSuccess() {
        for (CsWrapperContract wrapperContract : wrappedContractsListToInsert) {
            if (!wrapperContract.isInsertSuccess) {
                return false;
            }
        }
        return true;
    }

    private Boolean checkIfButtonsAreDisabled() {
        if (isButtonsDisabledAfterEditedContract) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, System.Label.Workshop_Hire_Block_Button_Message));
            return true;
        }
        return false;
    }
}