public with sharing class EmailTemplateService {
    public static String fields = '';
    public static List<EmailTemplate> fetchEmailTemplates(){
        fields = 'Name,IsActive';
        FieldLevelSecurity.checkFieldAccessByCriteria(fields, 'view', 'EmailTemplate');
        List<Folder> folderList = [Select Id, Name From Folder Where Type = 'Email' AND DeveloperName = 'ExAM_Distribution_Templates' LIMIT 1];
        List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
        if(folderList != null && folderList.size() > 0) {
            emailTemplates = [SELECT Id, Name, IsActive 
                              FROM EmailTemplate 
                              WHERE IsActive = true AND
                              Folder.Id = :folderList[0].Id AND DeveloperName != 'ExAM_Email_Limits_Notification'];
        }
        return emailTemplates;
    }
}