public with sharing class CsMechanicDetailController {

    public Workshop__c workshopPageFormController { get; set; }
    public Contract__c contractPageFormController { get; set; }
    public Mechanic__c mechanicPageFormController { get; set; }
    public List<Contract__c> agreementsForMechanicPageFormController { get; set; }
    public Workshop__c workshopChoosen { get; set; }
    public Contract__c editedContractInUse { get; set; }
    public List<Workshop__c> workshopsSearchResultList { get; private set; }
    private String workshopsQuery;
    private CsSoqlQueryBuilder queryBuilder;
    public String sortField { get; set; }
    public String sortDirection { get; set; }
    public Boolean isWorkshopSectionReady { get; set; }
    public Boolean isContractSectionReady { get; set; }
    private PageReference pageReference;
    public Attachment logoAttachment { get; set; }
    public Attachment image { get; set; }
    public String idOfAttachment { get; set; }
    public Boolean isDefaultPhotoDisplayed { get; set; }
    public transient String imageBody { get; set; }
    public String emailSubject { get; set; }
    public String emailBody { get; set; }

    public CsMechanicDetailController(ApexPages.StandardController controller) {
        this.mechanicPageFormController = (Mechanic__c) controller.getRecord();
        this.workshopPageFormController = new Workshop__c();
        this.contractPageFormController = new Contract__c();
        this.workshopChoosen = new Workshop__c();
        this.workshopsSearchResultList = new List<Workshop__c>();
        this.queryBuilder = new CsSoqlQueryBuilder();
        this.isWorkshopSectionReady = false;
        this.isContractSectionReady = false;
        this.sortDirection = 'DESC';
        this.editedContractInUse = new Contract__c();
        this.agreementsForMechanicPageFormController = new List<Contract__c>();
        refreshAgreementsList();
        setLogo();
        emailSubject = '';
        emailBody = '';
    }

    public void refreshAgreementsList() {
        queryBuilder = new CsSoqlQueryBuilder();
        queryBuilder.addResultField('Id').addResultField('Name').
                addResultField('Workshop__c').
                addResultField('Start_Date__c').
                addResultField('End_Date__c').
                addResultField('Status__c').
                addTableName('Contract__c').
                addSearchFieldEqualsWithValue('Mechanic__r.Id', mechanicPageFormController.Id).
                addSortField('Name').
                addSortOrder('DESC').
                build();
        agreementsForMechanicPageFormController = Database.query(queryBuilder.getQueryString());
    }

    public String getHirePopupLabel() {
        return String.format(System.Label.Mechanic_Hire_Label, new List<String>{
                mechanicPageFormController.Full_Name__c
        });
    }

    public List<Contract__c> getAgreementsForMechanicPageFormController() {
        return agreementsForMechanicPageFormController;
    }

    public PageReference deleteMechanic() {
        try{
            delete mechanicPageFormController;
        } catch (Exception err){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, String.format(System.Label.Error_Delete_With_Contracts, new List<String>{mechanicPageFormController.Full_Name__c})));
            return null;
        }
        pageReference = new PageReference('/' + SObjectType.Mechanic__c.getKeyPrefix() + '/o');
        pageReference.setRedirect(true);
        return pageReference;
    }

    public void sortByName() {
        sortField = 'Name';
        search();
    }

    public void sortByCity() {
        sortField = 'City__c';
        search();
    }

    public void sortByCountry() {
        sortField = 'Country__c';
        search();
    }

    public void clear() {
        clearData();
        workshopPageFormController = new Workshop__c();
        sortField = null;
        workshopChoosen.clear();
        isContractSectionReady = false;
    }

    public void cancel() {
        clearData();
        workshopPageFormController.clear();
        isContractSectionReady = false;
        workshopChoosen.clear();
    }

    private void clearData() {
        workshopsSearchResultList.clear();
        isWorkshopSectionReady = false;
        contractPageFormController = new Contract__c();
        queryBuilder.clear();
        workshopsQuery = '';
    }

    public void search() {
        if (String.isBlank(sortField)) sortField = 'Name';
        queryBuilder = new CsSoqlQueryBuilder();
        workshopsQuery = '';
        queryBuilder.addResultField('Name').
                addResultField('City__c').
                addResultField('Country__c').
                addTableName('Workshop__c').
                addSearchFieldWithValue('Name', workshopPageFormController.Name).
                addSearchFieldWithValue('City__c', workshopPageFormController.City__c).
                addSearchFieldWithValue('Country__c', workshopPageFormController.Country__c).
                addSortField(sortField).
                addSortOrder(sortDirection).
                build();
        workshopsQuery = queryBuilder.getQueryString();
        workshopsSearchResultList = Database.query(workshopsQuery);
        if (workshopsSearchResultList.size() > 0) isWorkshopSectionReady = true;
        sortDirection = (sortDirection.equals('ASC')) ? 'DESC' : 'ASC';
    }

    public void hire() {
        editedContractInUse.Mechanic__c = mechanicPageFormController.Id;
        editedContractInUse.Workshop__c = workshopChoosen.Id;
        editedContractInUse.Start_Date__c = contractPageFormController.Start_Date__c;
        editedContractInUse.End_Date__c = (contractPageFormController.End_Date__c != null) ? contractPageFormController.End_Date__c : null;
        try {
            insert editedContractInUse;
            cancel();
            refreshAgreementsList();
        } catch (DmlException error) {
            System.debug(error.getMessage());
        }
    }

    public PageReference choose() {
        isContractSectionReady = true;
        for (Workshop__c workshop : workshopsSearchResultList) {
            if (workshop.Id == workshopChoosen.Id) {
                workshopChoosen = workshop.clone(true);
                break;
            }
        }
        editedContractInUse = new Contract__c();
        return null;
    }

    public PageReference saveToPdf() {
        pageReference = Page.CsSaveMechanicRecordToPdf;
        pageReference.setRedirect(false);
        return pageReference;
    }

    public String getMechanicFullNameToPdfName() {
        return mechanicPageFormController.Full_Name__c.replaceAll(',', ' ');
    }

    public void dismiss() {
        for (Contract__c contract : agreementsForMechanicPageFormController) {
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

    public PageReference save() {
        if (!String.isEmpty(imageBody)) {
            System.debug('attach');
            logoAttachment = new Attachment();
            logoAttachment.parentId = mechanicPageFormController.Id;
            logoAttachment.Name = 'image';
            logoAttachment.ContentType = 'image/jpeg;base64';
            imageBody = imageBody.removeStart('data:image/jpeg;base64,');
            Blob body = EncodingUtil.base64Decode(imageBody);
            logoAttachment.body = body;
            try {
                insert logoAttachment;
            } catch (DmlException error) {
                System.debug(error.getMessage());
            }
        }
        pageReference = new ApexPages.StandardController(mechanicPageFormController).view();
        pageReference.setRedirect(true);
        return pageReference;
    }

    public PageReference deleteImage() {
        List<Attachment> attachedFiles = [SELECT Id FROM Attachment WHERE ParentId = :this.mechanicPageFormController.Id ORDER BY LastModifiedDate];
        try {
            delete attachedFiles;
        } catch (DmlException error) {
            System.debug(error.getMessage());
        }
        isDefaultPhotoDisplayed = true;
        pageReference = new ApexPages.StandardController(mechanicPageFormController).view();
        pageReference.setRedirect(true);
        return pageReference;
    }

    public void setLogo() {
        List<Attachment> attachedFiles = [SELECT Id FROM Attachment WHERE ParentId = :this.mechanicPageFormController.Id ORDER BY LastModifiedDate DESC LIMIT 1];
        if (attachedFiles.isEmpty()) {
            isDefaultPhotoDisplayed = true;
        } else {
            isDefaultPhotoDisplayed = false;
            idOfAttachment = attachedFiles[0].Id;
        }
    }

    public void sendEmailToMechanic() {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        String[] emailList = new String []{
                mechanicPageFormController.Email__c
        };
        message.setToAddresses(emailList);
        message.setSubject(emailSubject);
        message.setPlainTextBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{message});
        clearEmail();
    }

    public void clearEmail(){
        emailBody = '';
        emailSubject = '';
    }

    public String getEmailPopupLabel(){
        return String.format(System.Label.Send_Email_To, new List<String>{mechanicPageFormController.Full_Name__c});
    }

    public static Boolean getIsLicenseNumberEnabled(){
        return CsUtils.isCsEnabledForCurrentUser('MechanicLicenseNumberEnabled');
    }
}