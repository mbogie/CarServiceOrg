<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Assign_External_Id</fullName>
        <field>External_Id__c</field>
        <formula>Id</formula>
        <name>Assign External Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_value_From_Custom_Name_To_Name</fullName>
        <field>Name</field>
        <formula>IF( Name &lt;&gt;  Custom_Name__c ,  Custom_Name__c ,  Name )</formula>
        <name>Copy value From Custom Name To Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Copy Custom Name to Name</fullName>
        <actions>
            <name>Copy_value_From_Custom_Name_To_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Custom_Name__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Create External Id</fullName>
        <actions>
            <name>Assign_External_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Workshop__c.External_Id__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
