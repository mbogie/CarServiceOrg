public with sharing class LocationCallouts {

    public String address { get; set; }
    public double lat { get; set; }
    public double lng { get; set; }

    public void setAddress(String street, String city, String country) {
        this.address = '';
        if (street != null)
            this.address += street + '+in+';
        if (city != null)
            this.address += city + '+in+';
        if (country != null)
            this.address += country;
    }

    public void newAccmethod() {
        this.address = EncodingUtil.urlEncode(address, 'UTF-8');
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=' + address + '&inputtype=textquery&fields=geometry/location&key=AIzaSyBAuc9CZJTHNAGjTLg85spMeQw2MJl03u4');
        System.debug('address >>>' + address);
        req.setMethod('GET');
        req.setTimeout(5000);
        try {
            HttpResponse res = h.send(req);
            JSONParser parser = JSON.createParser(res.getBody());
            this.lat = null;
            this.lng = null;
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                        (parser.getText() == 'location')) {
                    parser.nextToken();
                    while (parser.nextToken() != JSONToken.END_OBJECT) {
                        String txt = parser.getText();
                        parser.nextToken();
                        if (txt == 'lat') lat = parser.getDoubleValue();
                        else if (txt == 'lng') lng = parser.getDoubleValue();
                    }
                }
            }
            if (lat != null) {
                system.debug(lat + ' ' + lng);
                system.debug(lat + 'a.Geo__Latitude__s');
                system.debug(lng + 'a.Geo__Longitude__s');
            }
        } catch (Exception e) {
            system.debug(e);
        }
    }

    public Double getLon() {
        return this.lng;
    }

    public Double getLat() {
        return this.lat;
    }
}
