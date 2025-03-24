/**
 * @description AsyncTaskRunner is responsible for executing an async task
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public without sharing class AsyncTaskRunner {
    /** @description base exception class for the async runner */
    public virtual class AsyncException extends Exception {
    }
    /** @description thrown if the task with the given id was not found */
    public class TaskNotFoundException extends AsyncException {
    }
    /** @description thrown if the task has was already completed */
    public class TaskAlreadyCompletedException extends AsyncException {
    }
    /** @description thrown if the payload type is not found */
    public class UnknownPayloadTypeException extends AsyncException {
    }
    /** @description thrown if the type of the handler does not exists */
    public class UnknownHandlerTypeException extends AsyncException {
    }
    /** @description thrown if the payload attachment cannot be found */
    public class PayloadNotFoundException extends AsyncException {
    }

    private final Logger logger = LoggerFactory.getLogger(AsyncTaskRunner.class);

    /**
     * @description Load and run the task matching the given ID.
     *
     * @param taskId The ID of the async task to be invoked.
     */
    public void run(String taskId) {
        AsyncTask__c task = this.loadTask(taskId);
        if (task == null) {
            throw new TaskNotFoundException('No task found with Id: ' + taskId);
        }
        this.invoke(task);
    }

    /**
     * @description execute the given task.
     *
     * @param task the task to execute
     */
    private void invoke(AsyncTask__c task) {
        if (task.IsCompleted__c) {
            throw new TaskAlreadyCompletedException();
        }

        this.initializeTaskState(task);
        this.configureLogging(task);

        AsyncTaskHandler handler;
        Object payload;

        try {
            handler = this.createHandler(task.HandlerClassName__c);
            payload = this.buildPayload(task.Id, handler);
        } catch (Exception e) {
            this.markTaskAsNotRunnable(task, e);
            update task;
            logger.error('Could not initialize task', e);
            LoggerFactory.flush();
            return;
        }

        try {
            this.runTask(task, handler, payload);
        } catch (Exception e) {
            logger.error('Handler threw an exception.', e);
            task.IsCompleted__c = !handler.isRetryable(new AsyncTaskInfo(task), e);
            task.IsSuccess__c = false;
            task.IsFailure__c = true;
            task.LastErrorMessage__c = e.getMessage();
            task.LastStackTrace__c = e.getStackTraceString();
        } finally {
            task.LastRunEndTime__c = DateTime.now();
            task.LastRunDuration__c = DateTime.now().getTime() - task.LastRunStartTime__c.getTime();
            update task;

            if (task.IsSuccess__c) {
                logger.info('Job is finished.' + task.id);
            } else {
                logger.warn('Job is finished.' + task.id);
            }
            LoggerFactory.flush();
        }
    }

    private void runTask(AsyncTask__c task, AsyncTaskHandler handler, Object payload) {
        logger.debug('Calling handler.');
        AsyncTaskInfo info = new AsyncTaskInfo(task);
        AsyncResult result = handler.execute(info, payload);
        if (result.isSuccess) {
            task.IsCompleted__c = true;
            task.IsSuccess__c = true;
            task.LastResult__c = result.data == null ? null : JSON.serializePretty(result.data);
            task.LastSuccessMessage__c = result.successMessage == null
                ? null
                : result.successMessage.left(sObjectType.AsyncTask__c.fields.LastSuccessMessage__c.length);
        } else {
            task.IsCompleted__c = !handler.isRetryable(info, result);
            task.IsSuccess__c = false;
            task.IsFailure__c = true;
            task.LastResult__c = result.data == null ? null : JSON.serializePretty(result.data);
            task.LastErrorMessage__c = result.errorMessage == null
                ? null
                : result.errorMessage.left(sObjectType.AsyncTask__c.fields.LastErrorMessage__c.length);
        }
    }

    /**
     * @description Returns the task matching the given ID.
     *
     * @param taskId The ID of the task to be retrieved.
     * @return The task object if found, or null otehrwise.
     */
    private AsyncTask__c loadTask(String taskId) {
        if (String.isBlank(taskId)) {
            return null;
        }

        List<AsyncTask__c> tasks = [
            SELECT
                Id,
                Name,
                CreatedDate,
                Description__c,
                HandlerClassName__c,
                ExecutionCount__c,
                LastRunStartTime__c,
                LastRunEndTime__c,
                LastErrorMessage__c,
                LastStackTrace__c,
                LastResult__c,
                LastSuccessMessage__c,
                IsCompleted__c,
                IsFailure__c,
                IsSuccess__c
            FROM AsyncTask__c
            WHERE Id = :taskId
        ];

        if (tasks == null || tasks.isEmpty()) {
            return null;
        }
        return tasks[0];
    }

    private AsyncTaskHandler createHandler(String className) {
        Type handlerType = Type.forName(null, className);
        System.debug('HandlerType '+handlerType);
        if (handlerType == null) {
            throw new UnknownHandlerTypeException('Unable to find a type for name: ' + className);
        }
        System.debug('Test '+(AsyncTaskHandler) handlerType.newInstance());
        return (AsyncTaskHandler) handlerType.newInstance();
    }

    /**
     * @description build the payload object for the task
     * @param taskId ID of the AsyncTask
     * @param handler the AsyncTaskHandler
     * @return the payload or null
     */
    private Object buildPayload(Id taskId, AsyncTaskHandler handler) {
        if (handler.getPayloadType() == null) {
            return null;
        }

        List<Attachment> payloads = [
            SELECT Id, Body
            FROM Attachment
            WHERE ParentId = :taskId AND Name = 'async_task_payload'
        ];

        if (payloads.isEmpty()) {
            throw new PayloadNotFoundException('Unable to find the payload');
        }

        Attachment attach = payloads.get(0);
        if (attach.Body == null || String.isEmpty(attach.Body.toString())) {
            return null;
        }

        return JSON.deserialize(attach.Body.toString(), handler.getPayloadType());
    }

    private void markTaskAsNotRunnable(AsyncTask__c task, Exception e) {
        task.LastErrorMessage__c = e.getMessage();
        task.LastStackTrace__c = e.getStackTraceString();
        task.IsCompleted__c = true;
        task.IsFailure__c = true;
        task.IsSuccess__c = false;
        task.LastRunEndTime__c = DateTime.now();
        task.LastRunDuration__c = 0;
    }

    private void initializeTaskState(AsyncTask__c task) {
        task.ExecutionCount__c += 1;
        task.LastRunStartTime__c = DateTime.now();
        task.LastErrorMessage__c = null;
        task.LastStackTrace__c = null;
        task.LastSuccessMessage__c = null;
        task.LastResult__c = null;
        task.IsCompleted__c = false;
        task.IsFailure__c = false;
        task.IsSuccess__c = false;
    }

    private void configureLogging(AsyncTask__c task) {
        AsyncLoggingAppender appender = new AsyncLoggingAppender(task.Id, task.ExecutionCount__c.intValue());
        LoggerFactory.addAppender(appender);
    }
}
