public class QuoteDiscountHandler {
    
    // ── METHOD: APPLY DISCOUNT & MAX CHECK ──
    public static void applyDiscountLogic(List<QuoteLineItem> newList, Map<Id, QuoteLineItem> oldMap) {
        // 1. Auto-Populate Category from Product
        Set<Id> pbeIds = new Set<Id>();
        for (QuoteLineItem qli : newList) {
            if (qli.Product_Category__c == null && qli.PricebookEntryId != null) pbeIds.add(qli.PricebookEntryId);
        }

        if (!pbeIds.isEmpty()) {
            Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>([
                SELECT Id, Product2.Product_Category__c FROM PricebookEntry WHERE Id IN :pbeIds
            ]);
            for (QuoteLineItem qli : newList) {
                if (qli.Product_Category__c == null && qli.PricebookEntryId != null && pbeMap.containsKey(qli.PricebookEntryId)) {
                    qli.Product_Category__c = pbeMap.get(qli.PricebookEntryId).Product2.Product_Category__c;
                }
            }
        }

        // 2. Fetch Rules and Calculate
        Set<Id> catIds = new Set<Id>();
        for (QuoteLineItem qli : newList) if (qli.Product_Category__c != null) catIds.add(qli.Product_Category__c);
        
        if (catIds.isEmpty()) return;

        Map<Id, Product_Category__c> catMap = new Map<Id, Product_Category__c>([
            SELECT Id, Name, Base_Discount__c, Max_Discount__c, Tier_1_Qty__c, 
                   Tier_1_Discount__c, Tier_2_Qty__c, Tier_2_Discount__c
            FROM Product_Category__c WHERE Id IN :catIds AND Active__c = true
        ]);

        for (QuoteLineItem qli : newList) {
            Product_Category__c cat = catMap.get(qli.Product_Category__c);
            if (cat == null) continue;

            // Manual Override Check
            Boolean isManual = false;
            if (oldMap != null && oldMap.containsKey(qli.Id)) {
                if (qli.Discount != oldMap.get(qli.Id).Discount) isManual = true;
            } else if (oldMap == null && qli.Discount != null) {
                isManual = true;
            }

            if (!isManual && qli.Quantity != null) {
                if (qli.Quantity > cat.Tier_2_Qty__c) qli.Discount = cat.Tier_2_Discount__c;
                else if (qli.Quantity > cat.Tier_1_Qty__c) qli.Discount = cat.Tier_1_Discount__c;
                else qli.Discount = cat.Base_Discount__c;
            }

            // Max Discount Validation
            if (qli.Discount > cat.Max_Discount__c) {
                qli.addError('Error: Discount exceeds ' + cat.Max_Discount__c + '% for ' + cat.Name);
            }
        }
    }
}