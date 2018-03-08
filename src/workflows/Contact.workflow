<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Contact_information_submitted_Contact</fullName>
        <ccEmails>request@exam4schools.com</ccEmails>
        <description>Contact information is submitted Please authorize the Contact and send the link for survey.</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>CustomTemplate/School_Ready_For_Survey_on_Contact</template>
    </alerts>
    <rules>
        <fullName>School Ready For Survey on Contact</fullName>
        <actions>
            <name>Contact_information_submitted_Contact</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
