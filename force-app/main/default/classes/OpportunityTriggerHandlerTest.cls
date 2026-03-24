@isTest
private class OpportunityTriggerHandlerTest {
    
    // Setup method taaki har test ke liye common data ban sake
    @testSetup
    static void setupData() {
        // Ek Account bana lete hain (Kyunki real orgs mein Opp ke liye Account zaroori hota hai)
        Account acc = new Account(Name = 'Test Auto-Quote Account');
        insert acc;
    }

    // SCENARIO 1: Direct nayi Opportunity banayi jiska Stage pehle se hi 'Proposal/Price Quote' hai
    @isTest
    static void testAutoQuoteOnInsert() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Opportunity opp = new Opportunity(
            Name = 'Direct Insert Opp',
            AccountId = acc.Id,
            StageName = 'Proposal/Price Quote', // Direct trigger wala stage
            CloseDate = Date.today().addDays(30)
        );
        
        Test.startTest();
        insert opp; // Yahan trigger fire hoga
        Test.stopTest();
        
        // Assert: Check karte hain ki kya Quote sach mein bana?
        List<Quote> createdQuotes = [SELECT Id, Name FROM Quote WHERE OpportunityId = :opp.Id];
        System.assertEquals(1, createdQuotes.size(), 'Insert par 1 Quote automatically banna chahiye tha.');
        System.assertEquals('Direct Insert Opp - Auto Quote', createdQuotes[0].Name, 'Quote ka naam format sahi nahi hai.');
    }

    // SCENARIO 2: Pehle kisi aur Stage mein Opp banayi, fir update karke 'Proposal/Price Quote' kiya
    @isTest
    static void testAutoQuoteOnUpdate() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        // Pehle 'Prospecting' stage mein insert karte hain (Yahan quote nahi banna chahiye)
        Opportunity opp = new Opportunity(
            Name = 'Update Stage Opp',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
        
        // Verify ki insert par koi Quote nahi bana
        List<Quote> initialQuotes = [SELECT Id FROM Quote WHERE OpportunityId = :opp.Id];
        System.assertEquals(0, initialQuotes.size(), 'Prospecting stage par Quote nahi banna chahiye.');
        
        // Ab Stage update karte hain
        opp.StageName = 'Proposal/Price Quote';
        
        Test.startTest();
        update opp; // Yahan update wala trigger fire hoga
        Test.stopTest();
        
        // Assert: Check karte hain ki kya update ke baad Quote bana?
        List<Quote> updatedQuotes = [SELECT Id FROM Quote WHERE OpportunityId = :opp.Id];
        System.assertEquals(1, updatedQuotes.size(), 'Stage update hone par 1 Quote banna chahiye tha.');
    }
}