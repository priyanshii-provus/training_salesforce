@isTest
public class QuoteApprovalHandlerTest {
    
    @testSetup
    static void setup() {
        // setup
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', CloseDate=Date.today());
        insert opp;
        
        Product2 prod = new Product2(Name='Test Product', IsActive=true);
        insert prod;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 1000,
            IsActive = true
        );
        insert pbe;
        
        Quote q = new Quote(Name='Test Quote', OpportunityId=opp.Id, Pricebook2Id=Test.getStandardPricebookId());
        insert q;
    }

    @isTest
    static void testWatchdogAlert() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        
        // extra discount to alert trigger
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = q.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 1000,
            Discount = 25 
        );
        
        Test.startTest();
        insert qli;
        Test.stopTest();
        
        // Assert check
        List<FeedItem> feeds = [SELECT Id, Body FROM FeedItem WHERE ParentId = :q.Id];
        
    //feed should not be empty to pass test
        System.assertEquals(false, feeds.isEmpty(), 'Chatter feed post should be created for >20% discount.');
    }
}
