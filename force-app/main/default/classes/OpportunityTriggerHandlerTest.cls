@isTest
private class OpportunityTriggerHandlerTest {
    
    // Setup method 
    @testSetup
    static void setupData() {
  
        Account acc = new Account(Name = 'Test Auto-Quote Account');
        insert acc;
    }

    // SCENARIO 1:  creating  new Opportunity whose  Stage is 'Proposal/Price Quote' 
    @isTest
    static void testAutoQuoteOnInsert() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Opportunity opp = new Opportunity(
            Name = 'Direct Insert Opp',
            AccountId = acc.Id,
            StageName = 'Proposal/Price Quote', // Direct trigger 
            CloseDate = Date.today().addDays(30)
        );
        
        Test.startTest();
        insert opp; //  trigger fire 
        Test.stopTest();
        
        // Assert
        List<Quote> createdQuotes = [SELECT Id, Name FROM Quote WHERE OpportunityId = :opp.Id];
        System.assertEquals(1, createdQuotes.size(), 'On Insert  1 Quote should automatically generate .');
        System.assertEquals('Direct Insert Opp - Auto Quote', createdQuotes[0].Name, 'Quote name and format is correct.');
    }

    // SCENARIO 2:  update opportunity to  'Proposal/Price Quote' 
    @isTest
    static void testAutoQuoteOnUpdate() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        // inserting at  'Prospecting' stage - no quote generation
        Opportunity opp = new Opportunity(
            Name = 'Update Stage Opp',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
        
        // no quote should generate
        List<Quote> initialQuotes = [SELECT Id FROM Quote WHERE OpportunityId = :opp.Id];
        System.assertEquals(0, initialQuotes.size(), 'No Quote should generate at Prospecting stage .');
        
        // stage update 
        opp.StageName = 'Proposal/Price Quote';
        
        Test.startTest();
        update opp; // update trigger fires 
        Test.stopTest();
        
        // Assertgit add force-app/main/default/classes/OpportunityTriggerHandlerTest.cls
        List<Quote> updatedQuotes = [SELECT Id FROM Quote WHERE OpportunityId = :opp.Id];
        System.assertEquals(1, updatedQuotes.size(), 'When Stage updates 1 Quote should generate .');
    }
}
