public with sharing class CsTomeksWorkshopsRestHandler {

    private final String TOMEKS_URL = CsUtils.getCredentialsValues('TomekUrl');

    public String getSessionId() {
        String sessionId = null;
            if (sessionId == null && !Test.isRunningTest()) {
                HttpRequest request = new HttpRequest();
                request.setEndpoint(String.format(System.Label.Tomeks_Oath2, new List<String>{
                        CsUtils.getCredentialsValues('TomekClientId'),
                        CsUtils.getCredentialsValues('TomekClientSecret'),
                        CsUtils.getCredentialsValues('TomekUsername'),
                        CsUtils.getCredentialsValues('TomekPassword')}));
                request.setMethod('POST');
                HttpResponse response = new Http().send(request);
                if (response.getStatusCode() == 200) {
                    Map<String, Object> objectsList = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    sessionId = (String) objectsList.get('access_token');
                } else {
                    System.debug(response.getStatusCode() + ' ' + response.getStatus());
                }
            }
        return sessionId;
    }

    public String createRequest(String parameters, String method, Map<String, List<CsTomeksWorkshopsRestController.WrappedTomeksWorkshop>> body) {
        String responseString = '';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(TOMEKS_URL + parameters);
        request.setHeader('Authorization', 'Bearer ' + getSessionId());
        request.setMethod(method);
        if (body != null) {
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setBody(JSON.serialize(body));
        }
        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() == 200) {
            responseString = response.getBody();
        } else {
            responseString = System.Label.Status_Error + ' ' + response.getStatusCode() + ' ' + response.getStatus();
        }
        return responseString;
    }
}