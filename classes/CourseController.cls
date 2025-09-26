public with sharing class CourseController {
    
    // Fetch available courses for enrollment
    @AuraEnabled(cacheable=true)
    public static List<Course__c> getAvailableCourses() {
        try {
            return [
                SELECT Id, Name, Seats_Available__c, Prerequisites__c
                FROM Course__c
                WHERE Seats_Available__c > 0
                ORDER BY Name
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching courses: ' + e.getMessage());
        }
    }

    // Fetch enrolled courses for a student
    @AuraEnabled(cacheable=true)
    public static List<Course_Enrollment__c> getEnrollments(Id studentId) {
        try {
            return [
                SELECT Id, Course__r.Name, Status__c, Enrollment_Date__c
                FROM Course_Enrollment__c
                WHERE Student__c = :studentId
                ORDER BY Enrollment_Date__c DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching enrollments: ' + e.getMessage());
        }
    }

    // Enroll student in a course
    @AuraEnabled
    public static Boolean enrollStudent(Id studentId, Id courseId) {
        try {
            Course_Enrollment__c newEnrollment = new Course_Enrollment__c(
                Student__c = studentId,
                Course__c = courseId,
                Status__c = 'Enrolled',
                Enrollment_Date__c = Date.today()
            );
            insert newEnrollment;

            // Update seat availability
            Course__c c = [SELECT Id, Seats_Available__c FROM Course__c WHERE Id = :courseId];
            c.Seats_Available__c = c.Seats_Available__c - 1;
            update c;

            return true;
        } catch (Exception e) {
            throw new AuraHandledException('Error enrolling student: ' + e.getMessage());
        }
    }
}
