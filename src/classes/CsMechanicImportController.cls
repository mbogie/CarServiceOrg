public with sharing class CsMechanicImportController {

    private static final String columnSeparator = ';';
    private String[] fileLines = new String[]{};
    private Integer indexOfUpsertResult;
    private List<Mechanic__c> mechanicsListToInsert;
    private PageReference pageReference;
    private Mechanic__c newMechanicToAdd = new Mechanic__c();
    public Blob fileContent { get; set; }
    public String selectedFile { get; set; }
    public List<CsWrapperMechanic> wrappedMechanicList { get; set; }
    public Boolean isWrappedMechanicListReady { get; set; }
    public String mechanicStringCsvTemplate { get; set; }

    public CsMechanicImportController(ApexPages.StandardController controller) {
        this.wrappedMechanicList = new List<CsWrapperMechanic>();
        this.isWrappedMechanicListReady = false;
    }

    public PageReference downloadTemplateCsv() {
        mechanicStringCsvTemplate = getFieldName('Mechanic__c', 'First_Name__c').escapeCsv() +
                columnSeparator + getFieldName('Mechanic__c', 'Name').escapeCsv() +
                columnSeparator + getFieldName('Mechanic__c', 'City__c').escapeCsv() +
                columnSeparator + getFieldName('Mechanic__c', 'Email__c').escapeCsv() + '\n';
        pageReference = Page.CsMechanicImportTemplate;
        pageReference.setRedirect(false);
        return pageReference;
    }

    private String getFieldName(String obj, String field) {
        return Schema.getGlobalDescribe().get(obj).getDescribe().fields.getMap().get(field).getDescribe().getLabel();
    }

    public void readFile() {
        selectedFile = null;
        wrappedMechanicList = new List<CsWrapperMechanic>();
        try {
            selectedFile = blobToString(fileContent, 'ISO-8859-1');
            fileLines = selectedFile.split('\n');
            for (Integer i = 1; i < fileLines.size(); i++) {
                String[] inputValues = new String[]{};
                inputValues = fileLines[i].split(columnSeparator, 4);
                newMechanicToAdd = new Mechanic__c();
                newMechanicToAdd.First_Name__c = inputValues[0];
                newMechanicToAdd.Name = inputValues[1];
                newMechanicToAdd.City__c = inputValues[2];
                newMechanicToAdd.Email__c = inputValues[3];
                if (!checkForDuplicate(newMechanicToAdd)) {
                    wrappedMechanicList.add(new CsWrapperMechanic(newMechanicToAdd));
                }
            }
            isWrappedMechanicListReady = true;
        } catch (Exception e) {
            if (selectedFile == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Input_No_File));
            } else ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }

    public Boolean checkForDuplicate(Mechanic__c mechanicToCheck) {
        for (CsWrapperMechanic wrappedMechanic : wrappedMechanicList) {
            if ((wrappedMechanic.innerMechanic.Name == mechanicToCheck.Name) &&
                    (wrappedMechanic.innerMechanic.First_Name__c == mechanicToCheck.First_Name__c) &&
                    (wrappedMechanic.innerMechanic.Email__c == mechanicToCheck.Email__c)) {
                return true;
            }
        }
        return false;
    }

    public static String blobToString(Blob input, String inCharset) {
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for (Integer i = 0; i < bytesCount; ++i)
            bytes[i] = hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }

    public String getBadFileExtension() {
        return String.format(System.Label.Bad_File_Extension, new List<String>{'.csv'});
    }

    public void selectAllRecords() {
        for (CsWrapperMechanic wrappedMechanic : wrappedMechanicList) {
            wrappedMechanic.isSelectedFromList = true;
        }
    }

    public void deselectAllRecords() {
        for (CsWrapperMechanic wrappedMechanic : wrappedMechanicList) {
            wrappedMechanic.isSelectedFromList = false;
        }
    }

    public void reverseRecordsSelection() {
        for (CsWrapperMechanic wrappedMechanic : wrappedMechanicList) {
            wrappedMechanic.isSelectedFromList = (wrappedMechanic.isSelectedFromList == false) ? true : false;
        }
    }

    public void insertMechanics() {
        indexOfUpsertResult = 0;
        mechanicsListToInsert = new List<Mechanic__c>();
        for (CsWrapperMechanic wrappedMechanic : wrappedMechanicList) {
            if (wrappedMechanic.isSelectedFromList) mechanicsListToInsert.add(wrappedMechanic.innerMechanic);
        }
        Database.UpsertResult[] upsertResult = Database.upsert(mechanicsListToInsert, false);
        for (CsWrapperMechanic wrapperMechanic : wrappedMechanicList) {
            if (wrapperMechanic.isSelectedFromList) {
                if (upsertResult.get(indexOfUpsertResult).isSuccess()) {
                    wrapperMechanic.isInsertSuccess = true;
                } else {
                    wrapperMechanic.isInsertSuccess = false;
                    for (Database.Error err : upsertResult.get(indexOfUpsertResult).getErrors()) {
                        wrapperMechanic.errorMessage = err.getMessage();
                    }
                }
                indexOfUpsertResult++;
            }
        }
        deselectAllRecords();
    }
}