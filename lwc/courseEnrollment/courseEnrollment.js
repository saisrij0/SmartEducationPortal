import { LightningElement, track, wire, api } from 'lwc';
import getAvailableCourses from '@salesforce/apex/CourseController.getAvailableCourses';
import getEnrollments from '@salesforce/apex/CourseController.getEnrollments';
import enrollStudent from '@salesforce/apex/CourseController.enrollStudent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CourseEnrollment extends LightningElement {
    @api recordId; // Student Id
    @track courseOptions = [];
    @track selectedCourse;
    @track enrollments;
    
    columns = [
        { label: 'Course', fieldName: 'Course__r.Name' },
        { label: 'Status', fieldName: 'Status__c' },
        { label: 'Date', fieldName: 'Enrollment_Date__c' }
    ];

    // Load available courses
    @wire(getAvailableCourses)
    wiredCourses({ error, data }) {
        if (data) {
            this.courseOptions = data.map(course => ({
                label: course.Name + ' (Seats: ' + course.Seats_Available__c + ')',
                value: course.Id
            }));
        } else if (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    // Load student enrollments
    @wire(getEnrollments, { studentId: '$recordId' })
    wiredEnrollments({ error, data }) {
        if (data) {
            this.enrollments = data;
        } else if (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    handleCourseChange(event) {
        this.selectedCourse = event.detail.value;
    }

    handleEnroll() {
        if (!this.selectedCourse) {
            this.showToast('Warning', 'Please select a course', 'warning');
            return;
        }
        enrollStudent({ studentId: this.recordId, courseId: this.selectedCourse })
            .then(() => {
                this.showToast('Success', 'Enrolled successfully!', 'success');
                return refreshApex(this.wiredEnrollments);
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
