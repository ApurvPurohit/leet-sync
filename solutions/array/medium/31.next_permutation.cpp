/*
 * @lc app=leetcode id=31 lang=cpp
 *
 * [31] Next Permutation
 */

// @lc code=start
class Solution {
public:
    void nextPermutation(vector<int>& nums) {
        
        int pivot=-1;
        int n = nums.size();
        if(n==1) return;
        for(int i=n-1;i>=1;--i){
            if(nums[i-1]<nums[i]){
                pivot = i;
                break;
            }
        }
        if(pivot==-1){
            reverse(nums.begin(), nums.end());
            return;
        }
        int pivot2=-1;
        for(int i=pivot;i<n;++i){
            if(nums[i]>nums[pivot-1]){
                pivot2 = i;
            }
        }
        if(pivot!=-1 && pivot2!=-1){
            swap(nums[pivot-1], nums[pivot2]);
            sort(nums.begin()+pivot, nums.end());
        } else {
            sort(nums.begin(), nums.end());
        }
    }
};
// @lc code=end
