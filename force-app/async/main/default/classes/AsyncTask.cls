/**
 * @description AsyncTask represents an asynchronous task
 * in the system.
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public without sharing class AsyncTask {
    /**
     * @description newTask() creates an async task in the database.
     *
     * @param config the task configuration
     * @return the task ID
     */
    public static Id newTask(AsyncTask.Configuration config) {
        AsyncTask__c task = AsyncTask.build(config);
        insert task;
        if (config.payload != null) {
            Attachment payload = AsyncTask.buildPayload(task, config.payload);
            insert payload;
        }
        return task.Id;
    }

    /**
     * @description newTasks() bulk creates new async tasks
     *
     * @param configs a collection of task configurations
     */
    public static void newTasks(List<AsyncTask.Configuration> configs) {
        if (configs == null || configs.isEmpty()) {
            return;
        }

        List<AsyncTask__c> tasks = new List<AsyncTask__c>();
        for (AsyncTask.Configuration config : configs) {
            tasks.add(AsyncTask.build(config));
        }
        insert tasks;

        List<Attachment> attachments = new List<Attachment>();
        Integer index = 0;
        for (AsyncTask__c task : tasks) {
            AsyncTask.Configuration config = configs.get(index);
            if (config.payload != null) {
                attachments.add(AsyncTask.buildPayload(task, config.payload));
            }
            index++;
        }
        insert attachments;
    }

    /**
     * @description builds the attachement payload for the task
     * The attachement is not saved in the db at this stage.
     *
     * @param task the task to link the attachment to
     * @param content the JSON serialized payload
     * @return the attachment object.
     */
    private static Attachment buildPayload(AsyncTask__c task, String content) {
        Attachment payload = new Attachment();
        payload.ContentType = 'application/json';
        payload.Body = Blob.valueOf(content);
        payload.Description = 'Async task payload';
        payload.IsPrivate = true;
        payload.Name = 'async_task_payload';
        payload.ParentId = task.Id;
        return payload;
    }

    /**
     * @description builds an async task from the given configuration.
     * The task is not saved in the db at this stage.
     *
     * @param config the async task configuration
     * @return the newly built async task.
     */
    private static AsyncTask__c build(AsyncTask.Configuration config) {
        AsyncTask__c task = new AsyncTask__c();
        task.Description__c = config.description;
        task.HandlerClassName__c = config.handlerClass.getName();
        task.ExecutionCount__c = 0;
        task.Priority__c = config.priority;
        task.OnHold__c = config.onHold;
        task.SkipUntil__c = config.skipUntil;
        return task;
    }

    /**
     * @description an Async task configuration
     */
    public class Configuration {
        /** @description description of the task */
        public String description { get; private set; }
        /** @description System.Type of the task handler */
        public System.Type handlerClass { get; private set; }
        /** @description serialized paylod of the task */
        public String payload { get; private set; }
        /** @description priority */
        public Integer priority {
            get {
                if (this.priority == null) {
                    return 0;
                }
                return this.priority;
            }
            set;
        }
        /** @description sets the task on hold */
        public Boolean onHold {
            get {
                if (this.onHold == null) {
                    this.onHold = false;
                }
                return this.onHold;
            }
            set;
        }
        /** @description skip the task execution until this moment */
        public DateTime skipUntil { get; set; }

        /**
         * @description contructor.
         *
         * @param description the task description (mandatory)
         * @param handlerClass the class which will handle this task execution
         */
        public Configuration(String description, Type handlerClass) {
            this.description = description;
            this.handlerClass = handlerClass;
        }

        /**
         * @description contructor.
         *
         * @param description the task description (mandatory)
         * @param handlerClass the class which will handle this task execution
         * @param payload the payload to link to this task. Note that the payload will be serialized
         *     to JSON at this stage so it is safe to modify after the creation of the configuration
         */
        public Configuration(String description, Type handlerClass, Object payload) {
            System.assert(description != null, 'description is required');
            System.assert(handlerClass != null, 'handlerClass is required');
            if (payload != null) {
                this.payload = JSON.serializePretty(payload);
            }

            this.description = description;
            this.handlerClass = handlerClass;
        }
    }
}
