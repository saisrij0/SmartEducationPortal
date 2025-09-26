import { LightningElement, api, wire } from 'lwc';
import getStudentProfile from '@salesforce/apex/StudentProfileController.getStudentProfile';

export default class StudentProfile extends LightningElement {
    @api recordId;

    @wire(getStudentProfile, { studentId: '$recordId' })
    student;
}
