trigger OpportunityTrigger on Opportunity (before update, before delete) {
    if (Trigger.isUpdate) {
        // Validate that the amount is greater than 5000
        for (Opportunity opp : Trigger.new) {
            if (opp.Amount < 5000) {
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }

        // Set the primary contact to the contact with the title 'CEO'
        Map<Id, Contact> ceoContacts = new Map<Id, Contact>();
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : Trigger.new) {
            accountIds.add(opp.AccountId);
        }
        if (!accountIds.isEmpty()) {
            for (Contact con : [SELECT Id, AccountId FROM Contact WHERE Title = 'CEO' AND AccountId IN :accountIds]) {
                ceoContacts.put(con.AccountId, con);
            }
        }
        for (Opportunity opp : Trigger.new) {
            if (ceoContacts.containsKey(opp.AccountId)) {
                opp.Primary_Contact__c = ceoContacts.get(opp.AccountId).Id;
            }
        }
    }

    if (Trigger.isDelete) {
        // Gather all Account IDs referenced in Trigger.old
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : Trigger.old) {
            accountIds.add(opp.AccountId);
        }
    
        // Query Accounts in bulk
        Map<Id, Account> accountsMap = new Map<Id, Account>(
            [SELECT Id, Industry FROM Account WHERE Id IN :accountIds]
        );
    
        // Prevent deletion of a closed-won opportunity for a banking account
        for (Opportunity opp : Trigger.old) {
            Account acc = accountsMap.get(opp.AccountId);
            if (acc != null && opp.StageName == 'Closed Won' && acc.Industry == 'Banking') {
                opp.addError('Cannot delete closed opportunity for a banking account that is won');
            }
        }
    }
}    