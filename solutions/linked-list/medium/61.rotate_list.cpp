/*
 * @lc app=leetcode id=61 lang=cpp
 *
 * [61] Rotate List
 */

// @lc code=start
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode() : val(0), next(nullptr) {}
 *     ListNode(int x) : val(x), next(nullptr) {}
 *     ListNode(int x, ListNode *next) : val(x), next(next) {}
 * };
 */
class Solution {
public:
    ListNode* rotateRight(ListNode* head, int k) {
        
        ListNode* temp = head;
        int n=0;
        while(temp){
            n++;
            temp=temp->next;
        }
        if(n==0 || k==0)return head;
        // n = number of nodes in the list
        // k can be greater than n
        k%=n;
        // now k is in the range[0,n)
        // if we rotate k elements
        // it is effectively = keep the first n-k intact
        // rotate the last k nodes and attach to the head
        // 1 2 3 4 5 
        // 5. 1 2 3 4
        // 4 5  1 2 3
        // 3 4 5.  1 2
        if(k==0)return head;

        temp = head;
        int countToRetain = n-k;
        ListNode* prev;
        while(countToRetain--){
            prev=temp;
            temp=temp->next;
        }
        prev->next=NULL;
        ListNode* newHead = temp;

        ListNode* temp2 = newHead;
        while(temp2 && temp2->next){
            temp2=temp2->next;
        }
        if(temp2)temp2->next = head;
        return newHead;
    }
};
// @lc code=end
