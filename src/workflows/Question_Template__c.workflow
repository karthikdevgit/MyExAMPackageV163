<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Restricted_Length_Question_field</fullName>
        <description>This has first 255 characters of main question label. Long text area cant be used in formula field</description>
        <field>Question_Restricted_Length__c</field>
        <formula>LEFT(Question_Label__c, 255)</formula>
        <name>Update Restricted Length Question field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Restricted length question</fullName>
        <actions>
            <name>Update_Restricted_Length_Question_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This has first 255 characters of main question label. Long text area cant be used in formula field</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
