import { LightningElement, api, wire } from 'lwc';
import getStudentApplications from '@salesforce/apex/ApplicationController.getStudentApplications';
import updateApplicationStatus from '@salesforce/apex/ApplicationController.updateApplicationStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ApplicationList extends LightningElement {
    @api studentId;
    applications;
    error;

    columns = [
        { label: 'Application Name', fieldName: 'Name' },
        { label: 'Program', fieldName: 'Program__c' },
        { label: 'Status', fieldName: 'Status__c', type: 'text' }
    ];

    @wire(getStudentApplications, { studentId: '$studentId' })
    wiredApplications({ error, data }) {
        if (data) {
            this.applications = data;
            this.error = undefined;
        } else if (error) {
            this.error = error.body.message;
            this.applications = undefined;
        }
    }

    handleStatusChange(event) {
        const applicationId = event.target.dataset.id;
        const newStatus = event.detail.value;

        updateApplicationStatus({ applicationId, newStatus })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Application status updated',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}