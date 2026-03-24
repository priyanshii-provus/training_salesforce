@isTest
public class QuoteApprovalHandlerTest {
    @TestSetup
    static void setup() {
        Account acc = new Account(Name='Watchdog Test'); insert acc;
        Opportunity opp = new Opportunity(Name='Opp', AccountId=acc.Id, StageName='Prospecting', CloseDate=Date.today(), Pricebook2Id=Test.getStandardPricebookId());
        insert opp;
        Product2 p = new Product2(Name='Service', IsActive=true); insert p;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=p.Id, UnitPrice=100, IsActive=true);
        insert pbe;
        insert new Quote(Name='Watchdog Quote', OpportunityId=opp.Id, Status='Draft', Pricebook2Id=Test.getStandardPricebookId());
    }

    @isTest static void testWatchdogAlert() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId=q.Id, PricebookEntryId=pbe.Id, Quantity=1, UnitPrice=100);
        insert qli;

        // Discount > 20% trigger watchdog
        Test.startTest();
        qli.Discount = 25;
        update qli;
        Test.stopTest();

        System.assertEquals(true, [SELECT Approval_Required__c FROM Quote].Approval_Required__c);
        System.assert([SELECT Id FROM FeedItem WHERE ParentId = :q.Id].size() > 0);
    }
}