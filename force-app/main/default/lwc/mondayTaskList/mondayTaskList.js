import { LightningElement, wire, track, api } from 'lwc';
import getLast20Tasks from '@salesforce/apex/MondayTaskController.getLast20Tasks';
import getBoardId from '@salesforce/apex/MondayTaskController.getBoardId';
import refreshMondayTasks from '@salesforce/apex/MondayTaskController.refreshMondayTasks';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class MondayTaskList extends LightningElement {
    @track tasks = [];
    @track boardOptions = [];
    selectedBoard;
    isLoading = false;
    wiredTasksResponse;

    // Columns for Data Table
    columns = [
        { label: 'Task Name', fieldName: 'Task_Name__c', type: 'text' },
        { label: 'Monday Task ID', fieldName: 'Monday_Task_Id__c', type: 'text' }
    ];

    // Fetch Last 20 Tasks
    @wire(getLast20Tasks)
    wiredTasks(response) {
        this.wiredTasksResponse = response; // Store the response for refreshing later
        const { data, error } = response;
        if (data) {
            this.tasks = data;
        } else if (error) {
            this.showToast('Error', 'Failed to load tasks', 'error');
        }
    }

    // Fetch Board ID from Custom Metadata
    connectedCallback() {
        getBoardId()
            .then(result => {
                this.boardOptions = [{ label: 'Board ' + result, value: result }];
                this.selectedBoard = result;
            })
            .catch(error => {
                this.showToast('Error', 'Failed to load board ID', 'error');
            });
    }

    // Handle Board Selection
    handleBoardSelection(event) {
        this.selectedBoard = event.detail.value;
    }

    // Refresh Tasks by Calling Apex
    handleRefresh() {
        if (!this.selectedBoard) {
            this.showToast('Error', 'Please select a board', 'error');
            return;
        }

        this.isLoading = true;
        refreshMondayTasks({ boardId: this.selectedBoard })
            .then(() => {
                this.showToast('Success', 'Tasks refreshed successfully', 'success');
                return refreshApex(this.wiredTasksResponse); // Refresh UI
            })
            .catch(error => {
                this.showToast('Error', 'Failed to refresh tasks', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    // Toast Notification
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}