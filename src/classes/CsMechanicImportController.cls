public with sharing class CsMechanicImportController {
    private String columnSeparator = ';';
    private String[] fileLines = new String[]{
    };
    public Blob fileContent { get; set; }
    public String selectedFile { get; set; }
    public List<CsImportMechanicWrapper> wrappedMechanicList { get; set; }
    public List<CsImportMechanicWrapper> selectedMechanicsList;
    public List<Mechanic__c> mechanicsListToInsert = new List<Mechanic__c>();
    public Boolean isWrappedMechanicListReady { get; set; }
    public String mechanicStringTemplate { get; set; }
    private PageReference pageReference;

    public CsMechanicImportController(ApexPages.StandardController controller) {
        wrappedMechanicList = new List<CsImportMechanicWrapper>();
        selectedMechanicsList = new List<CsImportMechanicWrapper>();
        isWrappedMechanicListReady = false;
    }

    public void clear() {
        selectedFile = null;
        wrappedMechanicList = null;
    }

    public void selectAllRecords() {
        for (CsImportMechanicWrapper mechanicWrapper : wrappedMechanicList) {
            mechanicWrapper.isSelectedFromList = true;
        }
    }

    public void deselectAllRecords() {
        for (CsImportMechanicWrapper mechanicWrapper : wrappedMechanicList) {
            mechanicWrapper.isSelectedFromList = false;
        }
    }

    public void reverseRecordsSelection() {
        for (CsImportMechanicWrapper mechanicWrapper : wrappedMechanicList) {
            mechanicWrapper.isSelectedFromList = (mechanicWrapper.isSelectedFromList == false) ? true : false;
        }
    }

    public PageReference getSelectedRecords() {
        selectedMechanicsList.clear();
        for (Integer i = 0; i < wrappedMechanicList.size(); i++) {
            CsImportMechanicWrapper tempWrapper = wrappedMechanicList.get(i);
            if (tempWrapper.isSelectedFromList == true) {
                tempWrapper.indexOfInsert = i;
                tempWrapper.displayInsertStatus = true;
                selectedMechanicsList.add(tempWrapper);
            }
        }
        return null;
    }

    public PageReference downloadTemplateCsv() {
        mechanicStringTemplate = getFieldName('Mechanic__c', 'First_Name__c').escapeCsv() +
                columnSeparator + getFieldName('Mechanic__c', 'Name').escapeCsv() +
                columnSeparator + getFieldName('Mechanic__c', 'City__c').escapeCsv() +
                columnSeparator + getFieldName('Mechanic__c', 'Email__c').escapeCsv() +
                '\n';
        pageReference = Page.CsMechanicImportTemplate;
        pageReference.setRedirect(false);
        return pageReference;
    }

    private String getFieldName(String obj, String field) {
        return Schema.getGlobalDescribe().get(obj).getDescribe().fields.getMap().get(field).getDescribe().getLabel();
    }

    public void insertMechanics() {
        getSelectedRecords();
        if (selectedMechanicsList.isEmpty()) return;
        mechanicsListToInsert = new List<Mechanic__c>();
        for (CsImportMechanicWrapper mechanicWrapper : selectedMechanicsList) {
            mechanicsListToInsert.add(mechanicWrapper.wrappedMechanic);
        }
        Database.UpsertResult[] upsertResult = Database.upsert(mechanicsListToInsert, false);
        for (Integer i = 0; i < selectedMechanicsList.size(); i++) {
            if (upsertResult.get(i).isSuccess()) {
                selectedMechanicsList.get(i).isInsertedSuccessfully = true;
            } else {
                selectedMechanicsList.get(i).isInsertedSuccessfully = false;
                for (Database.Error err : upsertResult.get(i).getErrors()) {
                    selectedMechanicsList.get(i).errorMessage = err.getMessage();
                }
            }
        }
        for (Integer i = 0; i < wrappedMechanicList.size(); i++) {
            CsImportMechanicWrapper tempWrapper = wrappedMechanicList.get(i);
            for (Integer j = 0; j < selectedMechanicsList.size(); j++) {
                CsImportMechanicWrapper tempSelectedWrapper = selectedMechanicsList.get(j);
                if (tempWrapper.indexOfInsert == tempSelectedWrapper.indexOfInsert) {
                    tempWrapper.isInsertedSuccessfully = tempSelectedWrapper.isInsertedSuccessfully;
                }
            }
        }
        deselectAllRecords();
        selectedMechanicsList = new List<CsImportMechanicWrapper>();
    }

    public String getBadFileExtension() {
        return String.format(System.Label.Bad_File_Extension, new List<String>{
                '.csv'
        });
    }

    public Boolean checkForDuplicate(CsImportMechanicWrapper mechanicToCheck) {
        for (CsImportMechanicWrapper wrappedMechanic : wrappedMechanicList) {
            if ((wrappedMechanic.wrappedMechanic.Name == mechanicToCheck.wrappedMechanic.Name) &&
                    (wrappedMechanic.wrappedMechanic.First_Name__c == mechanicToCheck.wrappedMechanic.First_Name__c) &&
                    (wrappedMechanic.wrappedMechanic.Email__c == mechanicToCheck.wrappedMechanic.Email__c)) {
                return true;
            }
        }
        return false;
    }

    public PageReference readFile() {
        clear();
        try {
            selectedFile = blobToString(fileContent, 'ISO-8859-1');
            fileLines = selectedFile.split('\n');
            wrappedMechanicList = new List<CsImportMechanicWrapper>();
            for (Integer i = 1; i < fileLines.size(); i++) {
                String[] inputValues = new String[]{
                };
                inputValues = fileLines[i].split(columnSeparator, 4);
                Mechanic__c tempMechanic = new Mechanic__c();
                tempMechanic.First_Name__c = inputValues[0];
                tempMechanic.Name = inputValues[1];
                tempMechanic.City__c = inputValues[2];
                tempMechanic.Email__c = inputValues[3];
                CsImportMechanicWrapper tempWrapper = new CsImportMechanicWrapper(tempMechanic);
                tempWrapper.indexOnList = i;
                if (!checkForDuplicate(tempWrapper)) {
                    wrappedMechanicList.add(tempWrapper);
                }
            }
            isWrappedMechanicListReady = true;
        } catch (Exception e) {
            if (selectedFile == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Input_No_File));
            } else ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }
        return null;
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
}