public class QuoteApprovalHandler {
    public static void runDiscountWatchdog(List<QuoteLineItem> newList, Map<Id, QuoteLineItem> oldMap) {
        Set<Id> quoteIdsToFlag = new Set<Id>();
        List<FeedItem> chatterPosts = new List<FeedItem>();

        for (QuoteLineItem qli : newList) {
            if (qli.Discount > 20.00 && (oldMap == null || oldMap.get(qli.Id).Discount <= 20.00)) {
                quoteIdsToFlag.add(qli.QuoteId);
                FeedItem post = new FeedItem();
                post.ParentId = qli.QuoteId;
                post.Body = '🚨 ALERT: High Discount (>20%) detected. Manager Approval Required.';
                chatterPosts.add(post);
            }
        }

        if (!quoteIdsToFlag.isEmpty()) {
            List<Quote> toUpdate = new List<Quote>();
            for (Id qId : quoteIdsToFlag) toUpdate.add(new Quote(Id = qId, Approval_Required__c = true));
            update toUpdate;
        }
        if (!chatterPosts.isEmpty()) insert chatterPosts;
    }
}