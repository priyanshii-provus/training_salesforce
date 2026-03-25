trigger OpportunityTrigger on Opportunity (after insert, after update) {
    
    // Trigger is connected to  handler 
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            OpportunityTriggerHandler.createAutoQuote(Trigger.new, Trigger.oldMap);
        }
    }
    
}
