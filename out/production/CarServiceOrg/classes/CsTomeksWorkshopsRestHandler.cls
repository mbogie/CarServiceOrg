public with sharing class CsTomeksWorkshopsRestHandler {

    private final String URL = CsUtils.getCredentialsValues('TomekUrl');

    public String getSessionId() {
        String sessionId = null;
        if (sessionId == null && !Test.isRunningTest()) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://login.salesforce.com/services/oauth2/token?grant_type=password&' +
                    'client_id=' + CsUtils.getCredentialsValues('TomekClientId') +
                    '&client_secret=' + CsUtils.getCredentialsValues('TomekClientSecret') +
                    '&username=' + CsUtils.getCredentialsValues('TomekUsername') +
                    '&password=' + CsUtils.getCredentialsValues('TomekPassword'));
            request.setMethod('POST');
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> objectsList = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                sessionId = (String) objectsList.get('access_token');
            } else {
                System.debug(response.getStatusCode() + ' ' + response.getStatus());
            }
        }
        return sessionId;
    }

    public HttpRequest createRequest(String parameters, String method, Map<String, List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>> body) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(URL + parameters);
        request.setHeader('Authorization', 'Bearer ' + getSessionId());
        request.setMethod(method);
        if (body != null) {
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setBody(JSON.serialize(body));
        }
        return request;
    }

}