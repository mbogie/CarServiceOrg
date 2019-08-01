@istest
global class CsSingleRequestMock implements HttpCalloutMock{

    protected Integer code;
    protected String bodyAsString;

    public CsSingleRequestMock(Integer code, String body) {
        this.code = code;
        this.bodyAsString = body;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(code);
        resp.setBody(bodyAsString);
        return resp;
    }
}