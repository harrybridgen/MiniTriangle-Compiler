module State where

import Control.Applicative
import Control.Monad
import Data.Char
import Data.List

newtype State state a = State {runState :: state -> (a, state)}

instance Functor (State st) where
  fmap f (State run) = State $ \s ->
    let (a, newState) = run s
     in (f a, newState)

instance Applicative (State st) where
  pure x = State $ \s -> (x, s)
  (State runF) <*> (State runX) = State $ \s ->
    let (f, s1) = runF s
        (x, s2) = runX s1
     in (f x, s2)

instance Monad (State st) where
  return = pure
  (State run) >>= f = State $ \s ->
    let (a, newState) = run s
        (State run') = f a
     in run' newState

get :: State st st
get = State $ \s -> (s, s)

put :: st -> State st ()
put newState = State $ const ((), newState)

gets :: (st -> a) -> State st a
gets f = State $ \s -> (f s, s)

evalState :: State st a -> st -> a
evalState (State run) s = fst (run s)
