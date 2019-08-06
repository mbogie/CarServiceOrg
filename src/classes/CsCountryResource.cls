@RestResource(urlMapping='/workshops/countries')
global class CsCountryResource {

    @HttpGet
    global static Map<String,String> getCountryList(){
        return CsCountryResourceHandler.getCountryList();
    }
}