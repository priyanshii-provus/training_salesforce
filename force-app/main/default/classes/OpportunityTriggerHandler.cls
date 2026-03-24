public with sharing class OpportunityTriggerHandler {
    
    public static void createAutoQuote(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        List<Quote> quotesToInsert = new List<Quote>();
        
        for (Opportunity opp : newList) {
            Boolean isStageChanged = false;
            
            // Insert ke time check karo
            if (oldMap == null && opp.StageName == 'Proposal/Price Quote') {
                isStageChanged = true;
            } 
            // Update ke time check karo (ki purana stage kuch aur tha aur naya ye hua hai)
            else if (oldMap != null) {
                Opportunity oldOpp = oldMap.get(opp.Id);
                if (opp.StageName == 'Proposal/Price Quote' && oldOpp.StageName != 'Proposal/Price Quote') {
                    isStageChanged = true;
                }
            }
            
            // Agar stage match hota hai, toh naya Quote banao
            if (isStageChanged) {
                Quote newQuote = new Quote();
                newQuote.Name = opp.Name + ' - Auto Quote'; // Quote ka default naam
                newQuote.OpportunityId = opp.Id; // Opp se link kar diya
                // newQuote.Pricebook2Id = ... (Agar specific pricebook set karni ho toh yahan kar sakte hain)
                
                quotesToInsert.add(newQuote);
            }
        }
        
        // Agar list mein quotes hain, toh ek saath insert kar do (Bulkified!)
        if (!quotesToInsert.isEmpty()) {
            insert quotesToInsert;
            System.debug('Auto Quotes Created: ' + quotesToInsert.size());
        }
    }
}