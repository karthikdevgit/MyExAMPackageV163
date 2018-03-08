<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Vistor_Authentication</fullName>
        <ccEmails>request@exam4schools.com</ccEmails>
        <description>Vistor information is submitted Please authenticate the visitor.</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CustomTemplate/VisitorAuthentication</template>
    </alerts>
    <rules>
        <fullName>VisitorArrived</fullName>
        <actions>
            <name>Vistor_Authentication</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Visitor_Task</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <description>Vistor submitted the information for authenticating official to react</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>Visitor_Task</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>5</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Visitor has registered please authenticateTask</subject>
    </tasks>
</Workflow>
