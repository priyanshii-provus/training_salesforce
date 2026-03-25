trigger QuoteLineItemTrigger on QuoteLineItem (before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        QuoteDiscountHandler.applyDiscountLogic(Trigger.new, Trigger.oldMap);
    }
    if (Trigger.isAfter) {
        QuoteApprovalHandler.runDiscountWatchdog(Trigger.new, Trigger.oldMap);
    }
}