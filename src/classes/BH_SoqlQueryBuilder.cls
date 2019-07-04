public class BH_SoqlQueryBuilder {
    private List<String> resultFieldsNames;
    private List<String> sortFieldsNames;
    private Map<String, String> searchFieldsWithValues;
    private Map<String, String> searchFieldsEqualsWithValues;
    private Map<String, String> searchFieldsStartsWithValues;

    private String tableName = '';
    private String queryString = '';
    private String sortOrder = 'ASC';
    private Integer sortLimit = 1000;

    public BH_SoqlQueryBuilder() {
        this.resultFieldsNames = new List<String>();
        this.searchFieldsWithValues = new Map<String, String>();
        this.searchFieldsEqualsWithValues = new Map<String, String>();
        this.searchFieldsStartsWithValues = new Map<String, String>();
        this.sortFieldsNames = new List<String>();
    }

    public void clear(){
        resultFieldsNames.clear();
        sortFieldsNames.clear();
        searchFieldsWithValues.clear();
        searchFieldsEqualsWithValues.clear();
        searchFieldsStartsWithValues.clear();
        this.tableName = '';
        this.queryString = '';
        this.sortOrder = 'ASC';
        this.sortLimit = 1000;
    }
    
    public String getQueryString() {
        return this.queryString;
    }

    public BH_SoqlQueryBuilder addResultField(String fieldName) {
        this.resultFieldsNames.add(fieldName);
        return this;
    }

    public BH_SoqlQueryBuilder addTableName(String fieldName) {
        this.tableName = fieldName;
        return this;
    }

    public BH_SoqlQueryBuilder addSortField(String fieldName) {
        this.sortFieldsNames.add(fieldName);
        return this;
    }

    public BH_SoqlQueryBuilder addSortOrder(String sortOrder) {
        this.sortOrder = sortOrder;
        return this;
    }

    public BH_SoqlQueryBuilder addSortLimit(Integer sortLimit) {
        this.sortLimit = sortLimit;
        return this;
    }

    public BH_SoqlQueryBuilder addSearchFieldWithValue(String fieldName, String value) {
        this.searchFieldsWithValues.put(fieldName, value);
        return this;
    }

    public BH_SoqlQueryBuilder addSearchFieldEqualsWithValue(String fieldName, String value) {
        this.searchFieldsEqualsWithValues.put(fieldName, value);
        return this;
    }

    public BH_SoqlQueryBuilder addSearchFieldStartsWithValue(String fieldName, String value) {
        this.searchFieldsStartsWithValues.put(fieldName, value);
        return this;
    }

    public BH_SoqlQueryBuilder build() {
        buildResultFields();
        buildFromTable();
        buildSearchFields();
        buildSearchEqualsFields();
        buildSearchStartFields();
        buildSortFields();
        return this;
    }

    private void buildResultFields() {
        String resultFields = '';

        for (String fieldName : resultFieldsNames) {
            resultFields += ' ' + fieldName + ',';
        }
        this.queryString += 'SELECT' + resultFields.removeEnd(',') + ' ';
    }

    private void buildFromTable() {
        this.queryString += 'FROM' + ' ' + tableName;
    }

    private void buildSearchFields() {
        String searchText = '';

        if (searchFieldsWithValues.isEmpty()) {
            return;
        }
        for (String fieldName : searchFieldsWithValues.keySet()) {
            if (!String.isEmpty(searchFieldsWithValues.get(fieldName))) {
                searchText += ' ' + fieldName + ' LIKE \'%' + searchFieldsWithValues.get(fieldName) + '%\' AND';
            }
        }
        if (!String.isEmpty(searchText))
            this.queryString += ' WHERE' + searchText.removeEnd(' AND');
    }
    private void buildSearchStartFields() {
        String searchText = '';

        if (searchFieldsStartsWithValues.isEmpty()) {
            return;
        }
        for (String fieldName : searchFieldsStartsWithValues.keySet()) {
            if (!String.isEmpty(searchFieldsStartsWithValues.get(fieldName))) {
                searchText += ' ' + fieldName + ' LIKE \'' + searchFieldsStartsWithValues.get(fieldName) + '%\' AND';
            }
        }
        if (!String.isEmpty(searchText))
            this.queryString += ' WHERE' + searchText.removeEnd(' AND');
    }

    private void buildSearchEqualsFields() {
        String searchText = '';

        if (searchFieldsEqualsWithValues.isEmpty()) {
            return;
        }

        for (String fieldName : searchFieldsEqualsWithValues.keySet()) {
            if (!String.isEmpty(searchFieldsEqualsWithValues.get(fieldName))) {
                searchText += ' ' + fieldName + ' =\'' + searchFieldsEqualsWithValues.get(fieldName) + '\' AND';
            }
        }
        if (!String.isEmpty(searchText)) {
            if (this.queryString.contains('WHERE')) {
                this.queryString += ' AND ' + searchText.removeEnd(' AND');
            } else {
                this.queryString += ' WHERE' + searchText.removeEnd(' AND');
            }
        }
    }

    private void buildSortFields() {
        String sortText = '';

        if (sortFieldsNames.isEmpty()) {
            return;
        }
        for (String fieldName : sortFieldsNames) {
            sortText += fieldName + ' ' + sortOrder + ', ';
        }
        this.queryString += ' ORDER BY ' + sortText.removeEnd(', ') + ' LIMIT ' + this.sortLimit;
    }
}