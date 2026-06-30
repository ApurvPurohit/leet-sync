/*
 * @lc app=leetcode id=205 lang=cpp
 *
 * [205] Isomorphic Strings
 */

// @lc code=start
class Solution {
public:
    bool isIsomorphic(string s, string t) {
        
        if(s.size()!=t.size()) return false;

        int n = s.size();
        vector<int> used(500,0);
        unordered_map<char, char> charMap;

        for(int i=0;i<n;++i){

            if(charMap.find(s[i])!=charMap.end()){
                if(charMap[s[i]]!=t[i]) return false;
                continue;
            }
            if(used[t[i]]) return false;
            charMap[s[i]] = t[i];
            used[t[i]] = 1;
        }

        return true;
    }
};
// @lc code=end
