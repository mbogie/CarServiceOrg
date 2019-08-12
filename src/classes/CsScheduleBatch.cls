global with sharing class CsScheduleBatch implements Schedulable{

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CsRepeatCallouts(),200);
        /*String cron_exp = '0 0 23 * * ?';
        String jobName = 'Repeat Callouts';
        System.Schedule(jobName, cron_exp, new CsScheduleBatch());*/
    }
}