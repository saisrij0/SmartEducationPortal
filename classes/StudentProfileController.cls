public with sharing class StudentProfileController {
    
    @AuraEnabled(cacheable=true)
    public static Student__c getStudentProfile(Id studentId) {
        return [
            SELECT Id, Name, Email__c, Phone__c, Date_of_Birth__c
            FROM Student__c
            WHERE Id = :studentId
            LIMIT 1
        ];
    }
}
