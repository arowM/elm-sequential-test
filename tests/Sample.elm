module Sample exposing (suite)

import Expect
import Test exposing (Test)
import Test.Sequence as SeqTest


suite : Test
suite =
    Test.describe "Sequential tests"
        [ SeqTest.pass "34"
            |> SeqTest.andThen
                (\str ->
                    case String.toInt str of
                        Nothing ->
                            SeqTest.fail str <|
                                \_ ->
                                    Expect.fail "should have been an integer."

                        Just n ->
                            SeqTest.pass n
                )
            |> SeqTest.assert "Current value is 34" (Expect.equal 34)
            |> SeqTest.map (\n -> n * 10)
            |> SeqTest.assert "Current value is 340" (Expect.equal 340)
            |> SeqTest.namedCases
                (\n ->
                    [ ( "Sequence1", sequence1 n )
                    , ( "Sequence2", sequence2 n )
                    ]
                )
            |> SeqTest.run "Sequential test"
        ]


sequence1 : Int -> SeqTest.Sequence ()
sequence1 n =
    SeqTest.pass 34
        |> SeqTest.assert ("Current value is less than " ++ String.fromInt n)
            (Expect.lessThan n)
        |> SeqTest.map (\_ -> ())


sequence2 : Int -> SeqTest.Sequence ()
sequence2 n =
    SeqTest.pass 350
        |> SeqTest.assert ("Current value is greater than " ++ String.fromInt n)
            (Expect.greaterThan n)
        |> SeqTest.map (\_ -> ())
