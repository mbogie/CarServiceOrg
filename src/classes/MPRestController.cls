public with sharing class MPRestController {

    public static String MOVIE_DB_API_KEY = MPUtils.getCsValues('movieDbApiKey');
    public static String MOVIE_DB_URL = MPUtils.getCsValues('movieDbApiUrl');

    public static String movieId = '550';
    public static String actorId = '2894';
    public static String query = 'jack nicholson';

    public static String getDbValues(String endpoint){
        System.debug(endpoint);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() == 200) {
            return response.getBody();
            //System.debug(response.getBody());
        } else throw new MpException(response.getStatusCode() + ' ' + response.getStatus());
    }

    public static void getMovieById() {
        String endpoint = MOVIE_DB_URL+'/movie/'+movieId+'?'+MOVIE_DB_API_KEY;
        String jsonActors = getDbValues(endpoint);
        Map<String, Object> mapOfActors = (Map<String, Object>) JSON.deserializeUntyped(jsonActors);
        for (String key : mapOfActors.keySet()){
            System.debug(key +' -----> '+ mapOfActors.get(key));
        }
    }

    public static void getActorById() {
        String endpoint = MOVIE_DB_URL+'/person/'+actorId+'?'+MOVIE_DB_API_KEY;
        String jsonActors = getDbValues(endpoint);
        Map<String, Object> mapOfActors = (Map<String, Object>) JSON.deserializeUntyped(jsonActors);
        for (String key : mapOfActors.keySet()){
            System.debug(key +' --->' +mapOfActors.get(key));
        }
    }

    public static void getMovieCast() {
        String endpoint = MOVIE_DB_URL+'/movie/'+movieId+'/credits?'+MOVIE_DB_API_KEY;
        getDbValues(endpoint);
    }

    public static void getActorFilmography() {
        String endpoint = MOVIE_DB_URL+'/person/'+actorId+'/movie_credits?'+MOVIE_DB_API_KEY;
        getDbValues(endpoint);
    }

    public static void getPopularFilms() {
        String endpoint = MOVIE_DB_URL+'/movie/popular?'+MOVIE_DB_API_KEY;
        getDbValues(endpoint);
    }

    public static void getGenres() {
        String endpoint = MOVIE_DB_URL+'/genre/movie/list?'+MOVIE_DB_API_KEY;
        getDbValues(endpoint);
    }

    public static void searchMovies() {
        String endpoint = MOVIE_DB_URL+'/search/movie?'+MOVIE_DB_API_KEY+'&query='+query;
        String jsonActors = getDbValues(endpoint);
        Map<String, Object> mapOfActors = (Map<String, Object>) JSON.deserializeUntyped(jsonActors);
        for (String key : mapOfActors.keySet()){
            System.debug(key +' -----> '+ mapOfActors.get(key));
        }
    }

    public static void searchActors(){
        String endpoint = MOVIE_DB_URL+'/search/person?'+MOVIE_DB_API_KEY+'&query='+query;
        String jsonActors = getDbValues(endpoint);
        Map<String, Object> mapOfActors = (Map<String, Object>) JSON.deserializeUntyped(jsonActors);
        for (String key : mapOfActors.keySet()){
            System.debug(key +' -----> '+ mapOfActors.get(key));
        }
        List<Object> listcc = (List<Object>) mapOfActors.get('results');
        Map<String, Object> result = new Map<String, Object>();
        List<Map<String, Object>> listMapOfActors = new List<Map<String, Object>>();
        for( Object obj : listcc) {
          //  result = (Map<String, Object>) JSON.deserializeUntyped((String) obj);
         //   System.debug(obj);
          //  listMapOfActors.add(result);
        }
     /*   Map<String, Object> mapOfActors2 = (Map<String, Object>) JSON.deserializeUntyped(jsonActors);

        for (String key : mapOfActors2.keySet()){
            System.debug(key +' --->' +mapOfActors2.get(key));
        }*/
    }

    public Map<String,Object> wrapActors(String jsonActors){
        Map<String, Object> mapOfActors = (Map<String, Object>) JSON.deserializeUntyped(jsonActors);
        return mapOfActors;
    }
}