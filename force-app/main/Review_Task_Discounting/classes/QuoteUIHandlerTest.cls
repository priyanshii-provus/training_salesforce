@isTest
public class QuoteUIHandlerTest {
    @TestSetup
    static void setup() {
        Account acc = new Account(Name='UI Test'); insert acc;
        Opportunity opp = new Opportunity(Name='Opp', AccountId=acc.Id, StageName='Prospecting', CloseDate=Date.today());
        insert opp;
        insert new Quote(Name='UI Quote', OpportunityId=opp.Id, Status='Draft');
    }

    @isTest static void testLayoutSwitching() {
        Quote q = [SELECT Id, Status FROM Quote LIMIT 1];
        
        // Approved Status Test
        q.Status = 'Approved';
        update q;
        Id appId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Approved').getRecordTypeId();
        System.assertEquals(appId, [SELECT RecordTypeId FROM Quote].RecordTypeId);

        // In Review Status Test
        q.Status = 'In Review';
        update q;
        Id revId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('In_Review').getRecordTypeId();
        System.assertEquals(revId, [SELECT RecordTypeId FROM Quote].RecordTypeId);
    }
}