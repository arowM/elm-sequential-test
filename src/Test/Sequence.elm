module Test.Sequence exposing
    ( Sequence
    , run
    , test
    , pass
    , fail
    , map
    , andThen
    , assert
    , cases
    , namedCases
    )

{-| Sequencial testing.

@docs Sequence
@docs run
@docs test
@docs pass
@docs fail
@docs map
@docs andThen
@docs assert
@docs cases
@docs namedCases

-}

import Expect exposing (Expectation)
import Test exposing (Test)


{-| -}
type Sequence a
    = Sequence (Sequence_ a)


{-| -}
type alias Sequence_ a =
    { value : Maybe a
    , tests : List Test
    }


{-| -}
pass : a -> Sequence a
pass a =
    Sequence
        { value = Just a
        , tests = []
        }


{-| -}
fail : String -> (() -> Expectation) -> Sequence a
fail description exp =
    Sequence
        { value = Nothing
        , tests = [ Test.test description exp ]
        }


{-| -}
test : String -> (() -> Expectation) -> Sequence ()
test description exp =
    Sequence
        { value = Just ()
        , tests = [ Test.test description exp ]
        }


{-| -}
map : (a -> b) -> Sequence a -> Sequence b
map f (Sequence seq) =
    Sequence
        { value = Maybe.map f seq.value
        , tests = seq.tests
        }


{-| -}
andThen : (a -> Sequence b) -> Sequence a -> Sequence b
andThen f (Sequence seqA) =
    case seqA.value of
        Nothing ->
            Sequence
                { value = Nothing
                , tests = seqA.tests
                }

        Just a ->
            let
                (Sequence seqB) =
                    f a
            in
            Sequence
                { value = seqB.value
                , tests = seqA.tests ++ seqB.tests
                }


{-| -}
assert : String -> (a -> Expectation) -> Sequence a -> Sequence a
assert description f (Sequence seq) =
    case seq.value of
        Just a ->
            Sequence
                { value = seq.value
                , tests = seq.tests ++ [ Test.test description <| \_ -> f a ]
                }

        Nothing ->
            Sequence seq


{-| -}
run : String -> Sequence a -> Test
run description (Sequence seq) =
    Test.describe description seq.tests


{-| -}
cases : (a -> List (Sequence ())) -> Sequence a -> Sequence ()
cases f (Sequence seqA) =
    case seqA.value of
        Nothing ->
            Sequence
                { value = Nothing
                , tests = seqA.tests
                }

        Just a ->
            List.foldl
                (\(Sequence seq) (Sequence acc) ->
                    Sequence
                        { value = Just ()
                        , tests = acc.tests ++ seq.tests
                        }
                )
                (Sequence
                    { value = Just ()
                    , tests = seqA.tests
                    }
                )
                (f a)


{-| -}
namedCases : (a -> List ( String, Sequence () )) -> Sequence a -> Sequence ()
namedCases f (Sequence seqA) =
    case seqA.value of
        Nothing ->
            Sequence
                { value = Nothing
                , tests = seqA.tests
                }

        Just a ->
            Sequence
                { value = Just ()
                , tests =
                    seqA.tests
                        ++ (f a
                                |> List.map
                                    (\( str, seq ) -> run str seq)
                           )
                }
