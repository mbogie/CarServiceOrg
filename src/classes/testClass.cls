public with sharing class FCC_ShopEditController {
    public final FCC_Shop__c shop;
    public ApexPages.StandardController controller { get; set;}
    public Attachment logoAttachment { get; set; }
    private Id parentId { get; set; }
    public Attachment image{ get; set; }
    public String idOfAttachment { get; set; }
    public Boolean defaultPhoto { get; set; }
    public transient String imageBody { get; set; }

    public FCC_ShopEditController(ApexPages.StandardController controller) {
        this.controller = controller;
        parentId = controller.getId();
        setLogo();
        this.shop = (FCC_Shop__c)controller.getRecord();
    }

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

    public PageReference save() {
        try {
            upsert shop;
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
        return new ApexPages.StandardController(shop).view();
    }

    public static Boolean getIsLicenseNumberEnabled() {
        return FCC_Util.isFunctionalityEnabled('ShopLicenseNoEnabled');
    }
}