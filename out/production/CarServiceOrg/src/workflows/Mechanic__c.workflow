<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Birthday_Reminder_Email</fullName>
        <description>Birthday Reminder Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>michal.bogusz@britenet.com.pl</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Birthday_Reminder</template>
    </alerts>
    <fieldUpdates>
        <fullName>Next_Birthday_Evaluate</fullName>
        <field>Next_Birthday__c</field>
        <formula>IF(TODAY()&gt;DATE(YEAR(TODAY()),MONTH( Birthday__c ),DAY(Birthday__c)),DATE(YEAR(TODAY())+1,MONTH(Birthday__c),DAY(Birthday__c)),DATE(YEAR(TODAY()),MONTH(Birthday__c),DAY(Birthday__c)))</formula>
        <name>Next Birthday Evaluate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Birthday Change</fullName>
        <actions>
            <name>Next_Birthday_Evaluate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Birthday__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Birthday Reminder</fullName>
        <active>true</active>
        <formula>Next_Birthday__c &gt; TODAY()</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Birthday_Reminder_Email</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Mechanic__c.Next_Birthday__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Next_Birthday_Evaluate</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Mechanic__c.Next_Birthday__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
