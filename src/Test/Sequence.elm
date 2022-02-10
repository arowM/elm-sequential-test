module Test.Sequence exposing
    ( Sequence
    , run
    , describe
    , map
    , andThen
    , assert
    )

{-| Sequencial testing.

@docs Sequence
@docs run
@docs describe
@docs map
@docs andThen
@docs assert

-}

import Expect exposing (Expectation)
import Test exposing (Test)


{-| -}
type Sequence a
    = Sequence String (List Test) (Maybe a)


{-| -}
describe : String -> Sequence ()
describe str =
    Sequence str [] (Just ())


{-| -}
run : Sequence a -> Test
run (Sequence str tests _) =
    Test.describe str (List.reverse tests)


{-| -}
andThen : String -> (a -> Maybe b) -> Sequence a -> Sequence b
andThen description f (Sequence str tests ma) =
    case ma of
        Nothing ->
            Sequence str tests Nothing

        Just a ->
            let
                mb =
                    f a
            in
            Sequence str
                (Test.test
                    description
                    (\_ -> Expect.true "Expected the `andThen` to be passed." (mb /= Nothing))
                    :: tests
                )
                mb


{-| -}
map : (a -> b) -> Sequence a -> Sequence b
map f (Sequence str tests ma) =
    Sequence str tests (Maybe.map f ma)


{-| -}
assert : String -> (a -> Expectation) -> Sequence a -> Sequence a
assert description f (Sequence str tests ma) =
    case ma of
        Just a ->
            Sequence str
                (Test.test description (\_ -> f a) :: tests)
                ma

        Nothing ->
            Sequence str tests ma
