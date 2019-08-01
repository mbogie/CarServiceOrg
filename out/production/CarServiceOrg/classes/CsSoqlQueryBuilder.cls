public class CsSoqlQueryBuilder {
    private List<String> resultFieldsNames;
    private List<String> sortFieldsNames;
    private Map<String, String> searchFieldsWithValues;
    private Map<String, String> searchFieldsEqualsWithValues;
    private Map<String, String> searchFieldsStartsWithValues;

    private String tableName = '';
    private String queryString = '';
    private String sortOrder = 'ASC';
    private Integer sortLimit = 1000;
    private Integer offsetNumber = 0;

    public CsSoqlQueryBuilder() {
        this.resultFieldsNames = new List<String>();
        this.searchFieldsWithValues = new Map<String, String>();
        this.searchFieldsEqualsWithValues = new Map<String, String>();
        this.searchFieldsStartsWithValues = new Map<String, String>();
        this.sortFieldsNames = new List<String>();
    }

    public void clear() {
        resultFieldsNames.clear();
        sortFieldsNames.clear();
        searchFieldsWithValues.clear();
        searchFieldsEqualsWithValues.clear();
        searchFieldsStartsWithValues.clear();
        this.tableName = '';
        this.queryString = '';
        this.sortOrder = 'ASC';
        this.sortLimit = 1000;
        this.offsetNumber = 0;
    }

    public String getQueryString() {
        return this.queryString;
    }

    public CsSoqlQueryBuilder addResultField(String fieldName) {
        this.resultFieldsNames.add(fieldName);
        return this;
    }

    public CsSoqlQueryBuilder addTableName(String fieldName) {
        this.tableName = fieldName;
        return this;
    }

    public CsSoqlQueryBuilder addSortField(String fieldName) {
        this.sortFieldsNames.add(fieldName);
        return this;
    }

    public CsSoqlQueryBuilder addSortOrder(String sortOrder) {
        this.sortOrder = sortOrder;
        return this;
    }

    public CsSoqlQueryBuilder addSortLimit(Integer sortLimit) {
        this.sortLimit = sortLimit;
        return this;
    }

    public CsSoqlQueryBuilder addOffset(Integer offsetNumber) {
        this.offsetNumber = offsetNumber;
        return this;
    }

    public CsSoqlQueryBuilder addSearchFieldWithValue(String fieldName, String value) {
        if (String.isBlank(value)) return this; else this.searchFieldsWithValues.put(fieldName, value);
        return this;
    }

    public CsSoqlQueryBuilder addSearchFieldEqualsWithValue(String fieldName, String value) {
        if (String.isBlank(value)) return this; else this.searchFieldsEqualsWithValues.put(fieldName, value);
        return this;
    }

    public CsSoqlQueryBuilder addSearchFieldStartsWithValue(String fieldName, String value) {
        if (String.isBlank(value)) return this; else this.searchFieldsStartsWithValues.put(fieldName, value);
        return this;
    }

    public CsSoqlQueryBuilder build() {
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
        this.queryString += ' ORDER BY ' + sortText.removeEnd(', ') + ' LIMIT ' + this.sortLimit + ' OFFSET ' + this.offsetNumber;
    }
}