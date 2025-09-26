public with sharing class LMSIntegrationController {

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> fetchStudents() {
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        // Use Named Credential
        req.setEndpoint('callout:StudentAPI/users'); 
        req.setMethod('GET');

        HttpResponse res = http.send(req);

        if(res.getStatusCode() == 200){
            List<Map<String, Object>> students = 
                (List<Map<String, Object>>) JSON.deserializeUntyped(res.getBody());
            return students;
        } else {
            throw new AuraHandledException('Error fetching students: ' + res.getStatus());
        }
    }
}