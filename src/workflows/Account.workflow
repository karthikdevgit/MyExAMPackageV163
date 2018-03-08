<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Contact_information_submitted</fullName>
        <ccEmails>request@exam4schools.com</ccEmails>
        <description>Contact information is submitted Please authorize the Contact and send the link for survey.</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CustomTemplate/Account</template>
    </alerts>
    <alerts>
        <fullName>Survey_Completed_Workflow</fullName>
        <ccEmails>request@exam4schools.com</ccEmails>
        <description>Survey is Completed and waiting for the reviewer to approve.</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CustomTemplate/Survey_submitted_for_approval</template>
    </alerts>
    <alerts>
        <fullName>Survey_Rejected</fullName>
        <ccEmails>request@exam4schools.com</ccEmails>
        <description>Survey is Rejected please review it again</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CustomTemplate/Survey_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Survey_is_submitted_for_approval</fullName>
        <ccEmails>request@exam4schools.com</ccEmails>
        <description>Survey is submitted for approval</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CustomTemplate/Survey_submitted_for_approval</template>
    </alerts>
    <alerts>
        <fullName>Survey_submitted</fullName>
        <ccEmails>request@exam4schools.com</ccEmails>
        <description>Survey is submitted for approval</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CustomTemplate/Survey_submitted_for_approval</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Initial_Approval_status</fullName>
        <field>Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Set Initial Approval status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Survey Completed</fullName>
        <actions>
            <name>Survey_Completed_Workflow</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Survey_Completed__c</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <description>The survey is completed so send for approval</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
