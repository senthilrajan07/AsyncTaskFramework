/**
 * @description AsyncLoggingAppender which uses System.debug() to process message.
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public without sharing class AsyncLoggingAppender implements LoggingAppender  {
    private String taskId;
    private Integer executionCount;
    private List<LoggingEvent> events = new List<LoggingEvent>();
    private static final String NAME = AsyncLoggingAppender.class.getName();
    private LoggingAppenderSettings settings = new LoggingAppenderSettings(this.getName());
    private Boolean hasError = false;
    private Boolean hasWarning = false;
    private LoggingEventFormatter formatter;

    /**
     * @description constructor.
     *
     * @param taskId id of the task
     * @param executionCount the current execution count
     */
    public AsyncLoggingAppender(String taskId, Integer executionCount) {
        System.assert(taskId != null, 'taskId is required.');
        this.taskId = taskId;
        this.executionCount = executionCount;
        this.formatter = new LoggingEventDefaultFormatter();
    }

    public void doAppend(LoggingEvent event) {
        if (!settings.levelEnabled(event.getLevel())) {
            return;
        }
        if (event.getLevel() == LoggingLevel.ERROR) {
            this.hasError = true;
        }

        if (event.getLevel() == LoggingLevel.WARN) {
            this.hasWarning = true;
        }

        this.events.add(event);
    }

    public String getName() {
        return NAME;
    }


    /**
     * @description flush this appender content
     */
    public void flush() {
        try {
            Attachment att = this.createAttachment();
            System.debug('attach ' + att);
            insert att;
            this.events.clear();
        } catch (Exception e) {
            System.debug(
                'Error saving the logs as an attachment: ' + e.getMessage()
            );
        }
    }

    /**
     * @description creates the attachment containing the logs for the task
     * The attachment is not saved at this time
     *
     * @return the Attachment object
     */
    private Attachment createAttachment() {
        Attachment att = new Attachment();
        att.Body = getLogs();
        att.ParentID = this.taskId;
        att.ContentType = 'text/plain';
        att.Name = 'Log for execution run #' + executionCount + ' [' + DateTime.now().getTime() + ']';
        return att;
    }

    private Blob getLogs() {
        List<String> logs = new List<String>();
        for (LoggingEvent event: this.events) {
            logs.add(this.formatter.format(event));
        }
        return Blob.valueOf(String.join(logs, '\n'));
    }
}
