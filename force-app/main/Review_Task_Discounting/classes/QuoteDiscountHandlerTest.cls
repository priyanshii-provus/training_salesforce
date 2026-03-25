@isTest
public class QuoteDiscountHandlerTest {
    
    @testSetup
    static void setupData() {
        Product_Category__c cat = new Product_Category__c(
            Name = 'Hardware', 
            Base_Discount__c = 5, 
            Max_Discount__c = 30, 
            Tier_1_Qty__c = 10, 
            Tier_1_Discount__c = 10,
            Tier_2_Qty__c = 50, 
            Tier_2_Discount__c = 15, 
            Active__c = true
        );
        insert cat;
        
        Product2 prod = new Product2(
            Name = 'Test Laptop', 
            IsActive = true, 
            Product_Category__c = cat.Id
        );
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod.Id, 
            UnitPrice = 1000, 
            IsActive = true
        );
        insert pbe;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp', 
            StageName = 'Prospecting', 
            CloseDate = Date.today()
        );
        insert opp;
        
        Quote q = new Quote(
            Name = 'Test Quote', 
            OpportunityId = opp.Id, 
            Pricebook2Id = pricebookId
        );
        insert q;
    }
    
    @isTest 
    static void testTier1Discount() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, PricebookEntryId = pbe.Id, Quantity = 15, UnitPrice = 1000);
        insert qli;
        
        System.assertEquals(10, [SELECT Discount FROM QuoteLineItem WHERE Id = :qli.Id].Discount, 'Tier 1 Discount should be 10%');
    }
    
    @isTest 
    static void testTier2Discount() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, PricebookEntryId = pbe.Id, Quantity = 60, UnitPrice = 1000);
        insert qli;
        
        System.assertEquals(15, [SELECT Discount FROM QuoteLineItem WHERE Id = :qli.Id].Discount, 'Tier 2 Discount should be 15%');
    }

    @isTest 
    static void testBaseDiscount() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, PricebookEntryId = pbe.Id, Quantity = 5, UnitPrice = 1000);
        insert qli;
        
        System.assertEquals(5, [SELECT Discount FROM QuoteLineItem WHERE Id = :qli.Id].Discount, 'Base Discount should be 5%');
    }

    @isTest 
    static void testManualDiscountInsert() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, PricebookEntryId = pbe.Id, Quantity = 5, UnitPrice = 1000, Discount = 12);
        insert qli;
        
        System.assertEquals(12, [SELECT Discount FROM QuoteLineItem WHERE Id = :qli.Id].Discount, 'Manual discount should override auto logic');
    }

    @isTest 
    static void testManualDiscountUpdate() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, PricebookEntryId = pbe.Id, Quantity = 5, UnitPrice = 1000);
        insert qli; 
        
        qli.Discount = 18; 
        update qli;
        
        System.assertEquals(18, [SELECT Discount FROM QuoteLineItem WHERE Id = :qli.Id].Discount, 'Manual update should be respected');
    }

    @isTest 
    static void testMaxDiscountValidationError() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, PricebookEntryId = pbe.Id, Quantity = 1, UnitPrice = 1000, Discount = 40);
        
        try {
            insert qli;
            System.assert(false, 'Expected an error because discount > max discount');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Discount exceeds'), 'The error message should mention discount limits');
        }
    }
}