# Complex Arithmetic
## Problem

Your task is to compute $ a^b $ $mod$ $1337$, where `a` is a positive integer and `b` is an extremely large positive integer represented as an array.

## Constraints

- ```1 <= a <= 2^31 - 1```
- ```1 <= length(b) <= 2000```
- ```0 <= b[i] <= 9```
- `b` does not contain leading zeros.

## Examples
1. 
   - Input: `a` = 2, `b` = [3]
   - Output: 8
   
2. 
   - Input: `a` = 2, `b` = [1,0]
   - Output: 1024

3. 
   - Input: `a` = 1, `b` = [4,3,3,8,5,2]
   - Output: 1

4. 
   - Input: `a` = 3, `b` = [2,0]
   - Output: 2187

5. 
   - Input: `a` = 7, `b` = [1,0,0]
   - Output: 343

6. 
   - Input: `a` = 5, `b` = [2,5]
   - Output: 3125

7. 
   - Input: `a` = 10, `b` = [3,3,3]
   - Output: 819

8. 
   - Input: `a` = 4, `b` = [0]
   - Output: 1

9. 
   - Input: `a` = 6, `b` = [2,2]
   - Output: 729

10. 
    - Input: `a` = 8, `b` = [1,1,1]
    - Output: 56