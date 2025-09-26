public with sharing class StudentService {

    // Fetch enrolled courses for a given student
    public static List<Course_Enrollment__c> getEnrolledCourses(Id studentId) {
        return [
            SELECT Course__r.Name, Status__c
            FROM Course_Enrollment__c
            WHERE Student__c = :studentId
        ];
    }

    // Search students by name or email
    public static List<Contact> searchStudents(String searchText) {
        List<List<Contact>> results = [
            FIND :searchText IN ALL FIELDS RETURNING Contact(Id, Name, Email)
        ];

        if(!results.isEmpty()) {
            return results[0]; // Return list of Contacts
        }
        return new List<Contact>();
    }
}
