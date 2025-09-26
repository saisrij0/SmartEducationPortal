public with sharing class ApplicationController {

    // Fetch all applications for a particular student
    @AuraEnabled(cacheable=true)
    public static List<Student_Application__c> getStudentApplications(Id studentId) {
        try {
            List<Student_Application__c> applications = [
                SELECT Id, Name, Status__c, Program__c, CreatedDate
                FROM Student_Application__c
                WHERE Student__c = :studentId
                ORDER BY CreatedDate DESC
            ];
            return applications;
        } catch(Exception e) {
            throw new AuraHandledException('Error fetching applications: ' + e.getMessage());
        }
    }

    // Fetch upcoming interviews for a student
    @AuraEnabled(cacheable=true)
    public static List<Interview_Schedule__c> getUpcomingInterviews(Id studentId) {
        try {
            DateTime nowDT = System.now();
            List<Interview_Schedule__c> interviews = [
                SELECT Id, Interview_Date__c, Interview_Time__c, Status__c, Interviewer__c
                FROM Interview_Schedule__c
                WHERE Student__c = :studentId
                AND Interview_Date__c >= :Date.today()
                ORDER BY Interview_Date__c ASC
            ];
            return interviews;
        } catch(Exception e) {
            throw new AuraHandledException('Error fetching interviews: ' + e.getMessage());
        }
    }

    // Fetch enrollment records for a student
    @AuraEnabled(cacheable=true)
    public static List<Course_Enrollment__c> getEnrollments(Id studentId) {
        try {
            List<Course_Enrollment__c> enrollments = [
                SELECT Id, Course__r.Name, Status__c, Enrollment_Date__c
                FROM Course_Enrollment__c
                WHERE Student__c = :studentId
                ORDER BY Enrollment_Date__c DESC
            ];
            return enrollments;
        } catch(Exception e) {
            throw new AuraHandledException('Error fetching enrollments: ' + e.getMessage());
        }
    }

    // Optional: Fetch application summary for dashboard
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getApplicationSummary(Id studentId) {
        Map<String, Integer> summary = new Map<String, Integer>();
        try {
            // AggregateResult[] results = [
            //     SELECT Status__c, COUNT(Id) count
            //     FROM Student_Application__c
            //     WHERE Student__c = :studentId
            //     GROUP BY Status__c
            // ];
            // for (AggregateResult ar : results) {
            //     summary.put((String)ar.get('Status__c'), (Integer)ar.get('count'));
            // }
            AggregateResult[] results = [
                SELECT Status__c, COUNT(Id) total
                FROM Student_Application__c
                WHERE Student__c = :studentId
                GROUP BY Status__c
            ];
            for (AggregateResult ar : results) {
                summary.put((String)ar.get('Status__c'), (Integer)ar.get('total'));
            }

        } catch(Exception e) {
            throw new AuraHandledException('Error fetching summary: ' + e.getMessage());
        }
        return summary;
    }
    
    @AuraEnabled
    public static Boolean updateApplicationStatus(Id applicationId, String newStatus) {
        try {
            Student_Application__c app = [
                SELECT Id, Status__c
                FROM Student_Application__c
                WHERE Id = :applicationId
                LIMIT 1
            ];
            app.Status__c = newStatus;
            update app;
            return true;
        } catch(Exception e) {
            throw new AuraHandledException('Error updating status: ' + e.getMessage());
        }
    }
}
