/**
 * @description inforamtion about the current task execution
 */
public class AsyncTaskInfo {
    private AsyncTask__c task;

    /**
     * @description constructor.
     * @param task the task to use
     */
    public AsyncTaskInfo(AsyncTask__c task) {
        System.assert(task != null, 'task is required');
        this.task = task;
    }

    /**
     * @description return the creation date for the task
     * @return the creationDate for the task
     */
    public DateTime getCreatedDate() {
        return this.task.CreatedDate;
    }

    /**
     * @description return the description of the task
     * @return the description of the task
     */
    public String getDescription() {
        return this.task.Description__c;
    }

    /**
     * @description return the Id of the task
     * @return the Id of the task
     */
    public String getTaskId() {
        return this.task.id;
    }

    /**
     * @description return the execution count of the task
     * @return the execution count of the task
     */
    public Integer getExecutionCount() {
        return this.task.ExecutionCount__c.intValue();
    }

    /**
     * @description returns the task's on hold status
     * @return returns the task's on hold status
     */
    public Boolean isOnHold() {
        return this.task.OnHold__c;
    }

    /**
     * @description sets the task on hold statud
     * @param value the new value;
     */
    public void setOnHold(Boolean value) {
        this.task.OnHold__c = (value == true);
    }

    /**
     * @description returns the date until when the task is skipped, or null
     * @return the date until when the task is skipped, or null
     */
    public DateTime getSkipUntil() {
        // FIXME: do we need to return a copy of the value ?
        return this.task.SkipUntil__c;
    }

    /**
     * @description sets the moment until the task is skipped
     * (use null to disable the skipping)
     * @param value the moment, or null to stop skipping the task
     */
    public void setSkipUntil(DateTime value) {
        this.task.SkipUntil__c = value;
    }

    /**
     * @description returns the priority
     * @return the priority
     */
    public Decimal getPriority() {
        Decimal p = this.task.Priority__c;
        if (p == null) {
            p = 0;
        }
        return p;
    }

    /**
     * @description sets the priority value
     * @param value the new priority
     */
    public void setPriority(Decimal value) {
        if (value != null) {
            this.task.Priority__c = value;
        }
    }
}