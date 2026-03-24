public with sharing class OpportunityTriggerHandler {
    
    public static void createAutoQuote(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        List<Quote> quotesToInsert = new List<Quote>();
        
        for (Opportunity opp : newList) {
            Boolean isStageChanged = false;
            
            //checked at time of  Insertion
            if (oldMap == null && opp.StageName == 'Proposal/Price Quote') {
                isStageChanged = true;
            } 
            // check at update
            else if (oldMap != null) {
                Opportunity oldOpp = oldMap.get(opp.Id);
                if (opp.StageName == 'Proposal/Price Quote' && oldOpp.StageName != 'Proposal/Price Quote') {
                    isStageChanged = true;
                }
            }
            
            // if stage matches generate new quote
            if (isStageChanged) {
                Quote newQuote = new Quote();
                newQuote.Name = opp.Name + ' - Auto Quote'; // Quote ka default naam
                newQuote.OpportunityId = opp.Id; // Opp se link kar diya
                // newQuote.Pricebook2Id = ... (Agar specific pricebook set karni ho toh yahan kar sakte hain)
                
                quotesToInsert.add(newQuote);
            }
        }
        
        // if list have quote insert all together 
        if (!quotesToInsert.isEmpty()) {
            insert quotesToInsert;
            System.debug('Auto Quotes Created: ' + quotesToInsert.size());
        }
    }
}
