absValue :: Integer -> Integer
absValue n
    | n < 0 = (-1)*n
    | otherwise = n
{- 4^5 == 4*4^4 -}
power :: Integer -> Integer -> Integer
power b e
    | e == 0 = 1
    | e == 1 = b
    | otherwise = b * (power b (e - 1))

isPrime :: Integer -> Bool
isPrime 0 = False
isPrime 1 = False
isPrime n = not (teFactor n (n-1))

teFactor :: Integer -> Integer -> Bool
teFactor n c
    | c == 1 = False
    | n `mod` c == 0 = True
    | otherwise = teFactor n (c-1)

slowFib :: Integer -> Integer
slowFib n
    | n <= 1 = n
    | otherwise = slowFib (n-1) + slowFib (n-2)

quickFib :: Integer -> Integer
quickFib 0 = 0
quickFib 1 = 1
quickFib n = fst(fib(n))

fib :: Integer -> (Integer, Integer)
fib 0 = (0,0)
fib 1 = (1,0)
-- fib retorna (f(n), f(n-1))
fib n = (a+b, a)
    where (a,b) = fib (n-1)
