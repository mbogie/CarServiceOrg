public with sharing class CsMechanicEditController {
    private Mechanic__c mechanicPageFormController;
    private PageReference pageReference;

    public CsMechanicEditController(ApexPages.StandardController controller) {
        this.mechanicPageFormController = (Mechanic__c) controller.getRecord();
        parentId = controller.getId();
        setLogo();
    }

    public PageReference cancel() {
        pageReference = new ApexPages.StandardController(mechanicPageFormController).view();
        pageReference.setRedirect(true);
        return pageReference;
    }
    public PageReference save() {
        System.debug('save');
        Database.SaveResult saveResult = Database.update(mechanicPageFormController, false);
        upsert mechanicPageFormController;
        if (!String.isEmpty(imageBody)) {
            System.debug('attach');
            logoAttachment = new Attachment();
            logoAttachment.parentId = mechanicPageFormController.Id;
            logoAttachment.Name = 'image';
            logoAttachment.ContentType = 'image/jpeg;base64';
            imageBody = imageBody.removeStart('data:image/jpeg;base64,');
            Blob body = EncodingUtil.base64Decode(imageBody);
            logoAttachment.body = body;
            insert logoAttachment;
        }
        if (!saveResult.isSuccess()) {
            for (Database.Error error : saveResult.getErrors()) {
                if (error instanceof Database.DuplicateError) {
                    Database.DuplicateError duplicateError = (Database.DuplicateError) error;
                    Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate Error: ' + duplicateResult.getErrorMessage()));
                }
            }
            return null;
        }
        pageReference = new ApexPages.StandardController(mechanicPageFormController).view();
        pageReference.setRedirect(true);
        return pageReference;
    }

    public ApexPages.StandardController controller { get; set;}
    public Attachment logoAttachment { get; set; }
    private Id parentId { get; set; }
    public Attachment image{ get; set; }
    public String idOfAttachment { get; set; }
    public Boolean defaultPhoto { get; set; }
    public transient String imageBody { get; set; }

    public void uploadImage() {
        logoAttachment = new Attachment();
        logoAttachment.parentId = parentId;
        logoAttachment.Name = 'image';
        logoAttachment.ContentType = 'image/jpeg;base64';
        imageBody = imageBody.removeStart('data:image/jpeg;base64,');
        Blob body = EncodingUtil.base64Decode(imageBody);
        logoAttachment.body = body;
        insert logoAttachment;
    }

    public void deleteImage() {
        List<Attachment> attachedFiles = [ SELECT Id FROM Attachment WHERE ParentId =: this.parentId ORDER BY LastModifiedDate];
        delete attachedFiles;
        defaultPhoto = true;
    }

    public void setLogo() {
        List<Attachment> attachedFiles = [ SELECT Id FROM Attachment WHERE ParentId=:this.parentId ORDER BY LastModifiedDate DESC LIMIT 1];
        if (attachedFiles.isEmpty()) {
            defaultPhoto = true;
        } else {
            defaultPhoto = false;
            idOfAttachment = attachedFiles[0].Id;
        }
    }

/*    public PageReference save() {
        try {
            upsert mechanicPageFormController;
            if (!String.isEmpty(imageBody)) {
                logoAttachment = new Attachment();
                logoAttachment.parentId = controller.getId();
                logoAttachment.Name = 'image';
                logoAttachment.ContentType = 'image/jpeg;base64';
                imageBody = imageBody.removeStart('data:image/jpeg;base64,');
                Blob body = EncodingUtil.base64Decode(imageBody);
                logoAttachment.body = body;
                insert logoAttachment;
            }
        } catch (DMLException e) {

        }
        return new ApexPages.StandardController(mechanicPageFormController).view();
    }*/
}