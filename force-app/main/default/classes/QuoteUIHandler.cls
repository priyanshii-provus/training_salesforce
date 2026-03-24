public class QuoteUIHandler {
    public static void handleLayoutLocking(List<Quote> newList) {
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName();
        for (Quote q : newList) {
            if (q.Status == 'Approved' || q.Status == 'Accepted') {
                if(rtMap.containsKey('Approved')) q.RecordTypeId = rtMap.get('Approved').getRecordTypeId();
            } else if (q.Status == 'In Review') {
                if(rtMap.containsKey('In_Review')) q.RecordTypeId = rtMap.get('In_Review').getRecordTypeId();
            } else {
                if(rtMap.containsKey('Draft')) q.RecordTypeId = rtMap.get('Draft').getRecordTypeId();
            }
        }
    }
}