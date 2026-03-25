trigger QuoteTrigger on Quote (before insert, before update) {
    if (Trigger.isBefore) {
        QuoteUIHandler.handleLayoutLocking(Trigger.new);
    }
}