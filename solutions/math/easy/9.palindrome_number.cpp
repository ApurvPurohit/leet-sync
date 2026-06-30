/*
 * @lc app=leetcode id=9 lang=cpp
 *
 * [9] Palindrome Number
 */

// @lc code=start
class Solution {
public:
    bool isPalindrome(int x) {
        if(x<0) return false;
        long long rev = 0;
        int temp = x;
        while(temp){
            rev = rev*10 + (temp%10);
            temp/=10;
        }
        return x==rev;
    }
};
// @lc code=end

