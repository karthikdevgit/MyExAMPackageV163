<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Support_Team_Member</fullName>
        <description>Notify Support Team Member</description>
        <protected>false</protected>
        <recipients>
            <field>Responder__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CustomTemplate/Notify_Field_Team_Member</template>
    </alerts>
    <alerts>
        <fullName>Notify_Team_Member</fullName>
        <description>Notify Team Member</description>
        <protected>false</protected>
        <recipients>
            <field>Assessor_Resource__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CustomTemplate/Notify_Field_Team_Member</template>
    </alerts>
    <alerts>
        <fullName>management_assessment_is_completed</fullName>
        <ccEmails>salesforce@mbaoutcome.com</ccEmails>
        <description>Notify Management on Assessment Completion</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CustomTemplate/Notify_Management_Assessment_Complete</template>
    </alerts>
    <rules>
        <fullName>Assignment Event Rule</fullName>
        <actions>
            <name>Assignment_Event</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>IssueRequest_Life_Cycle__c.Assessment_Date_Time__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify Manager when Assessment Complete</fullName>
        <actions>
            <name>management_assessment_is_completed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>IssueRequest_Life_Cycle__c.Assessment_Form_Completion__c</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <description>This notifies the management team when an assessment is completed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify Support Team Member</fullName>
        <actions>
            <name>Notify_Support_Team_Member</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>IssueRequest_Life_Cycle__c.Responder__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify Team Member</fullName>
        <actions>
            <name>Notify_Team_Member</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>IssueRequest_Life_Cycle__c.Assessor_Resource__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Assignment_Event</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>IssueRequest_Life_Cycle__c.Assessment_Date_Time__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Assignment Event</subject>
    </tasks>
</Workflow>
