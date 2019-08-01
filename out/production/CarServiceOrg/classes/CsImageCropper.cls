public with sharing class CsImageCropper {

    Mechanic__c mechanicPageFormController {get; set;}
    /**********Profile Pic***************/
    Public Transient blob propFileBody{get;set;}
    Public Transient string propFileName{get;set;}
    Public Transient string propContentType{get;set;}
    Public Integer fsize{get;set;}
    public boolean doneuploading{get; set;}
    public boolean doneuploadingCroping{get; set;}
    public boolean uploadCroping{get; set;}
    Public Transient string upldocUrl{get;set;}
    Public Transient String inputdataUrl{get;set;}
    Public String DocID{get;set;}

    public CsImageCropper(ApexPages.StandardController controller) {
        this.mechanicPageFormController = (Mechanic__c) controller.getRecord();
    }

    public CsImageCropper()
    {
        try
        {
            upldocUrl='';
            inputdataUrl='';
            uploadCroping=false;
            doneuploading=false;
            doneuploadingCroping=false;
        }
        catch(Exception ex)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getStackTraceString()+' Message: SaveProfile() '+ex.getMessage());
            ApexPages.addMessage(msg);
        }
    }

    public PageReference uploadPicture()
    {
        try
        {
            Transient User UserContactId;
            if(!uploadCroping)
                return EditProfilePic();
            else
                    return uploadCrop();
        }
        catch(Exception ex)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getStackTraceString()+' Message: SaveProfile() '+ex.getMessage());
            ApexPages.addMessage(msg);
        }
        return null;
    }

    public PageReference EditProfilePic()
    {
        try
        {
            system.debug('@@@@# propFileBody'+propFileBody+''+propFileName+''+propContentType+'fsize'+fsize+'propFileName'+propFileName);

            // checking file size should be less then 5 MB
            if(fsize > 5242880)
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to upload '+propFileName+' because it exceeds the maximum file size (5MB).');
                ApexPages.addMessage(msg);
            }
            else if((propContentType != 'image/png') && (propContentType != 'image/x-png') && (propContentType  != 'image/pjpeg') && (propContentType != 'image/jpeg') && (propContentType != 'image/gif') && (propContentType  != 'image/bmp')&& (propContentType  != 'image/tiff'))
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: File Type Not Correct.');
                ApexPages.addMessage(msg);
            }
            else
            {
                String strtemp=EncodingUtil.base64Encode(propFileBody);
                if(!String.isblank(strtemp))
                    upldocUrl='data:'+propContentType+';base64,'+strtemp;    // set the image url to display image on the page
                else
                        upldocUrl='';
                doneuploading=true;
            }
        }
        catch(Exception ex)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getStackTraceString()+' Message: '+ex.getMessage());
            ApexPages.addMessage(msg);
        }
        return null;
    }

    public Pagereference uploadCrop()
    {
        try
        {
            doneuploadingCroping=false;
            if(!string.isblank(inputdataUrl))
            {
                List<String> datalist = inputdataUrl.split(',');
                if(datalist.size()>0)
                {
                    propContentType=datalist[0].split(';')[0];
                    propContentType=propContentType.removeStart('data:');
                    inputdataUrl=datalist[1].trim();
                }

                propFileBody=EncodingUtil.base64Decode(inputdataUrl);

                Document doc = new Document();
                doc.Body = propFileBody;
                doc.Name = 'ABC';
                doc.IsPublic = true;
                doc.ContentType = propContentType;
                doc.Type = propContentType.substring((propContentType.indexOf('/')+1),propContentType.length());
                doc.FolderId = UserInfo.getUserId();
                System.debug('doc------'+doc);
                insert doc;
                DocID = doc.Id;
                doneuploadingCroping=true;
            }
        }
        catch(Exception ex)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getStackTraceString()+' Message: '+ex.getMessage());
            ApexPages.addMessage(msg);
        }
        return null;
    }
}