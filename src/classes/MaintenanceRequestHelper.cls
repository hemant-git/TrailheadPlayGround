public class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(Set<Id> requestIdSet){
        List<Case> closedRequests = getAllClosedRequests(requestIdSet);
        if(closedRequests != null && closedRequests.size() > 0){
            List<Case> futureRequestList = createNewRequests(closedRequests);
            if(futureRequestList != null && futureRequestList.size() > 0){
                insert futureRequestList;
            } 
        }

    }    

    private static List<Case> getAllClosedRequests(Set<Id> requestIdSet){
        List<Case> closedRequestList = [SELECT Vehicle__c, Equipment__c, Product__c, Type, Date_Reported__c,
                                        (SELECT Equipment__r.Maintenance_Cycle__c FROM Work_Parts__r ORDER BY 
										Equipment__r.Maintenance_Cycle__c ASC) 
                                        FROM Case
                                        WHERE Id IN :requestIdSet AND Status='Closed' AND Type IN ('Routine Maintenance', 'Repair')];
        return closedRequestList;
    }
    
    private static List<Case> createNewRequests(List<Case> closedRequestList){
        List<Case> newRequestList = new List<Case>();
        for(Case request : closedRequestList){
            Case futureRequest = new Case();
            futureRequest.Vehicle__c = 	request.Vehicle__c;
            futureRequest.Equipment__c = request.Equipment__c;
            futureRequest.Product__c = request.Product__c;
            futureRequest.Type = 'Routine Maintenance';
            futureRequest.Subject = 'Routine Maintenance';
            futureRequest.Date_Reported__c = System.today();
            List<Work_Part__c> workPartList = request.Work_Parts__r;
            if(workPartList != null && workPartList.size() > 0){
                Integer additionalDays = Integer.valueOf(workPartList.get(0).Equipment__r.Maintenance_Cycle__c);
                futureRequest.Date_Due__c = System.today().addDays(additionalDays);
            }
            newRequestList.add(futureRequest);
        }
        return newRequestList;
    }
    
}