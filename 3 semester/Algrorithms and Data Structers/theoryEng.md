### Fast Exponentiation

To compute large powers efficiently, the fast exponentiation algorithm (or exponentiation by squaring) is used. This method reduces the number of multiplications required for the calculation.

#### Algorithm:

Function `fast_exp(a, b, mod)`:

1. If `b` == 0, return 1.
2. If `b` is even:
   - $$ temp = fast_exp(a, b // 2, mod) $$
   - return $$ (temp \cdot temp) \% mod $$.
3. If `b` is odd:
   - return $$ (a \cdot fast_exp(a, b - 1, mod)) \% mod $$.

### Euler's Theorem

Euler's theorem allows for quick and efficient computation of powers modulo `n`. According to the theorem, if `a` and `n` are coprime, then:
$$ a^{\phi(n)} \equiv 1 \ (\text{mod} \ n) $$

where $\phi(n)$ is Euler's totient function, which counts the number of integers from 1 to `n` that are coprime with `n`.

For the modulus 1337, 
$$ \phi(1337) = \phi(7) \cdot \phi(191) = 6 \cdot 190 = 1140 $$

### Reduction of Large Numbers

When `b` is represented as an array of digits, we can utilize the property of modular exponentiation:
$$ a^b \equiv a^{b \% \phi(n)} \ (\text{mod} \ n) $$

This means we can reduce the number `b` using \( \phi(n) \) before calculating the result.

### Solution

1. Convert the array `b` into a single number.
2. Apply reduction modulo $\phi(1337)$.
3. Use the fast exponentiation algorithm with the reduced `b`.

### Example:
1.  `b` = [1,0] -> number 10.
2. 10 \% 1140 = 10 (since 10 < 1140).
3. Calculate $2^{10} \% 1337 = 1024$.

### Conclusion

By using Euler's theorem and the fast exponentiation algorithm, we can efficiently compute large powers modulo even for very large values of `b` represented as an array.