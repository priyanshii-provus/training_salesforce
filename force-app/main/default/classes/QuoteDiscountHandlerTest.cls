@isTest
public class QuoteDiscountHandlerTest {
    
    @testSetup
    static void setupData() {
        // Issue 4 Fixed: Added Tier_2_Qty__c and Tier_2_Discount__c to setup
        Product_Category__c cat = new Product_Category__c(
            Name='Hardware', 
            Base_Discount__c=5, 
            Max_Discount__c=30, 
            Tier_1_Qty__c=10, 
            Tier_1_Discount__c=10,
            Tier_2_Qty__c=50, 
            Tier_2_Discount__c=15, 
            Active__c=true
        );
        insert cat;
        
        // Setup Product & Pricebook
        Product2 prod = new Product2(Name='Test Laptop', IsActive=true, Product_Category__c=cat.Id);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod.Id, 
            UnitPrice = 1000, 
            IsActive = true
        );
        insert pbe;
        
        // Setup Opportunity & Quote
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', CloseDate=Date.today());
        insert opp;
        
        Quote q = new Quote(Name='Test Quote', OpportunityId=opp.Id, Pricebook2Id=pricebookId);
        insert q;
    }
    
    @isTest 
    static void testTier1Discount() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = q.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 15, // Quantity > 10 (Tier 1)
            UnitPrice = 1000
        );
        
        Test.startTest();
        insert qli;
        Test.stopTest();
        
        QuoteLineItem insertedQli = [SELECT Discount FROM QuoteLineItem WHERE Id = :qli.Id];
        System.assertEquals(10, insertedQli.Discount, 'Tier 1 Discount should be 10%');
    }
    
    // Issue 3 Fixed: Added Tier 2 Test Method
    @isTest 
    static void testTier2Discount() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = q.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 60, // Quantity > 50 (Tier 2)
            UnitPrice = 1000
        );
        
        Test.startTest();
        insert qli;
        Test.stopTest();
        
        QuoteLineItem insertedQli = [SELECT Discount FROM QuoteLineItem WHERE Id = :qli.Id];
        System.assertEquals(15, insertedQli.Discount, 'Tier 2 Discount should be 15%');
    }
}