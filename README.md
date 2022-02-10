# elm-sequential-test

[![Build Status](https://app.travis-ci.com/arowM/elm-sequential-test.svg?branch=main)](https://app.travis-ci.com/arowM/elm-sequential-test)  
[Document](https://package.elm-lang.org/packages/arowM/elm-sequential-test/latest/)  

# A Quick Example

```elm
suite : Test
suite =
    Sequence.describe "sequential testing"
        |> Sequence.map (\_ -> 4)
        |> Sequence.andThen "The result should be even."
            (\n ->
                if modBy 2 n == 0 then
                    Just (n // 2)
                else
                    Nothing
            )
        |> Sequence.assert "Check if it is greater than 10."
            (\n ->
                n
                    |> Expect.greaterThan 10
            )
        |> Sequence.run
```
