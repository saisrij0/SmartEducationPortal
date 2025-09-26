import { LightningElement, wire } from 'lwc';
import fetchStudents from '@salesforce/apex/LMSIntegrationController.fetchStudents';

export default class StudentList extends LightningElement {
    students;
    error;

    @wire(fetchStudents)
    wiredStudents({ error, data }) {
        if(data) {
            this.students = data;
            this.error = undefined;
        } else if(error) {
            this.error = error.body ? error.body.message : error;
            this.students = undefined;
        }
    }
}