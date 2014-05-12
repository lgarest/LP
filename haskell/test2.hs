fact :: Integer -> Integer
fact 0 = 1
fact n = n * fact(n-1)

main = do
    putStr "Input a number\n"
    linea <- getLine
    let x = (read linea) :: Integer
    if x /= 0 then do
        putStr "The factorial is: "
        print (fact x)
        main
    else
        return()
