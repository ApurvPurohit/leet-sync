/*
 * @lc app=leetcode id=14 lang=cpp
 *
 * [14] Longest Common Prefix
 */

// @lc code=start
class Solution {
public:
    string longestCommonPrefix(vector<string>& strs) {
        int idx=0;

        while(idx<200){

            if(idx>=strs[0].size())break;
            char ch = strs[0][idx];

            for(int i=0;i<strs.size();++i){
                if(idx<strs[i].size() && strs[i][idx]!=ch){
                    return idx==0 ? "" : strs[0].substr(0,idx);
                }
                if(idx>=strs[i].size()) {
                    return strs[0].substr(0,idx);;
                }
            }

            idx++;
        }

        return strs[0].substr(0,idx+1);
    }
};
// @lc code=end
