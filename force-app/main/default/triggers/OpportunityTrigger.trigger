trigger OpportunityTrigger on Opportunity (after insert, after update) {
    
    // Trigger ko hamesha handler se connect karo
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            OpportunityTriggerHandler.createAutoQuote(Trigger.new, Trigger.oldMap);
        }
    }
    
}