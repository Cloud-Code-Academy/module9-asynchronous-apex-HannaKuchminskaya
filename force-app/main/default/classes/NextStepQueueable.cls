/*
 * NextStepQueueable Class Description:
 * 
 * Implement the Queueable interface to process records asynchronously.
 * This example processes up to 10 accounts at a time.
 * It removes the Next Step from the accounts and related opportunities.
 *  
 * 
 * Note: The class below contains placeholders for implementing a queueable job to update accounts and opportunities.
 */
public with sharing class NextStepQueueable implements Queueable{

    private static final Integer MAX_JOBS = 5;

    // Member variable to store the accounts
    private Map<Id,Account> accounts;

    // Constructor to accept the accounts
    public NextStepQueueable(Map<Id,Account> accounts) {
        // Store the accounts in a member variable
        this.accounts = accounts;
    }

    // Method to queue the job
    public static void enqueueJob() {
        // Get 10 accounts with Next Step populated
        Map<Id,Account> accounts = new Map <Id,Account> ([SELECT id, Next_Step__c FROM Account WHERE Next_Step__c!=null LIMIT 10]);

        // If there are any accounts, queue the job using System.enqueueJob
        if (!accounts.isEmpty()){
            System.enqueueJob(new NextStepQueueable(accounts));
        }
    }

    /*
     * Update/Uncomment the template code to create a method
     * Method to execute the queueable job
     */
    //[public | private ] [static] data_type execute (input parameters) 
    public void execute (QueueableContext context) {
        // Get the accounts from the member variable

            // Remove the Next Step using the helper method
            if (!accounts.isEmpty()){
                removeNextStepAccounts(accounts);
                // Get the opportunities related to the accounts
        List<Opportunity> opportunities = [SELECT Id, NextStep, AccountId FROM Opportunity WHERE AccountId IN: accounts.keySet()];

            // Remove the Next Step using the helper method
            if (!opportunities.isEmpty()){
                removeNextStepOpportunities(opportunities);
            }

            }
            
        
            

        Boolean reachedMaxDepth = AsyncInfo.getCurrentQueueableStackDepth()== MAX_JOBS;
        if (!reachedMaxDepth){
            NextStepQueueable.enqueueJob();
        }

        }

    // Helper method to remove the Next Step
    // Overloaded method to accept an opportunity
    private static void removeNextStepOpportunities(List<Opportunity> opportunities) {
        for (Opportunity opp : opportunities){
                opp.NextStep = null;
        }
        update opportunities;
        
    }

    // Helper method to remove the Next Step
    // Overloaded method to accept an account
    private static void removeNextStepAccounts(Map<Id,Account> accounts) {
        for (Account acc : accounts.values()){
            acc.Next_Step__c = null;
        }
        update accounts.values();
        
    }
}