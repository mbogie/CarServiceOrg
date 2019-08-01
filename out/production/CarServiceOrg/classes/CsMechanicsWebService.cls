global class CsMechanicsWebService {

    global class WrappedMechanic {
        webService String id;
        webService String lastName;
        webService String firstName;
        webService String country;
        webService String mail;
        webService String city;

        global WrappedMechanic(Mechanic__c mechanic){
            this.id = mechanic.Id;
            this.lastName = mechanic.Name;
            this.firstName = mechanic.First_Name__c;
            this.country = mechanic.Country__c;
            this.mail = mechanic.Email__c;
            this.city = mechanic.City__c;
        }
    }

    global class DatabaseStatusWrapper{
        webService String id;
        webService String message;
    }

    webService static List<WrappedMechanic> searchMechanics(String firstName,String lastName,String country,String city,String mail) {
        List<WrappedMechanic> wrappedList = new List<WrappedMechanic>();
        CsSoqlQueryBuilder queryBuilder = new CsSoqlQueryBuilder();
        queryBuilder.addResultField('First_Name__c').
                addResultField('Name').
                addResultField('Id').
                addResultField('Email__c').
                addResultField('Country__c').
                addResultField('City__c').
                addTableName('Mechanic__c').
                addSearchFieldStartsWithValue('Name', lastName).
                addSearchFieldStartsWithValue('First_Name__c', firstName).
                addSearchFieldStartsWithValue('Country__c', country).
                addSearchFieldStartsWithValue('Email__c', mail).
                addSearchFieldStartsWithValue('City__c', city).
                build();
        for(Mechanic__c mechanic :  Database.query(queryBuilder.getQueryString())){
            wrappedList.add(new WrappedMechanic(mechanic));
        }
        return wrappedList;
    }

    webService static DatabaseStatusWrapper deleteMechanic(String id){
        DatabaseStatusWrapper databaseStatusWrapper = new DatabaseStatusWrapper();
        Database.DeleteResult deleteResult = Database.delete(id,false);
        if(!deleteResult.isSuccess()){
            databaseStatusWrapper.message = deleteResult.getErrors().get(0).getMessage();
        }
        return databaseStatusWrapper;
    }

    webService static DatabaseStatusWrapper addOrEditMechanic(String id, String firstName,String lastName,String country,String city,String mail){
        DatabaseStatusWrapper databaseStatusWrapper = new DatabaseStatusWrapper();
        Mechanic__c newOrEditedMechanic = new Mechanic__c();
        newOrEditedMechanic.Id = id;
        newOrEditedMechanic.First_Name__c = firstName;
        newOrEditedMechanic.Name = lastName;
        newOrEditedMechanic.City__c = city;
        newOrEditedMechanic.Country__c = country;
        newOrEditedMechanic.Email__c = mail;
        Database.UpsertResult upsertResult = Database.upsert(newOrEditedMechanic,false);
        if(upsertResult.isSuccess()){
            databaseStatusWrapper.id = upsertResult.getId();
        }else{
            databaseStatusWrapper.id = '';
            databaseStatusWrapper.message = upsertResult.getErrors().get(0).getMessage();
        }
        return databaseStatusWrapper;
    }

    webService static String getCountryList(){
        String countries = '';
        Schema.DescribeFieldResult describeFieldResult = Mechanic__c.Country__c.getDescribe();
        Schema.sObjectField sObjectField = describeFieldResult.getSObjectField();
        List<PicklistEntry> entries = sObjectField.getDescribe().getPicklistValues();
        for(PicklistEntry picklistEntry : entries){
            countries +=picklistEntry.getValue()+',';
        }
        return countries.removeEnd(',');
    }
}