fact :: Integer -> Integer
--fact n = if n == 0 then 1 else n*fact (n-1)
fact 0 = 1
fact n = n*fact (n-1)

fib :: Integer -> Integer
{-fib n =
    if n<=1 then
        n
    else
        fib (n-1) + fib (n-2)-}
    
fib n
    | n <= 1 = n
    {-| n >= 2 = fib (n-1) + fib (n-2)-}
    | otherwise = fib (n-1) + fib (n-2)

test12 = fib 12
test5 = fib 5
testLlista = [1,2,7,81]

llargada :: [Int] -> Int
llargada [] = 0
llargada (cap:cua) = 1 + llargada cua

list1 = 1:(2:(3:[]))
-- [1,2,3]

list2 = list1 ++ [4,5,6]
-- [1,2,3,4,5,6]

-- from Integral: convierte integer a real
