import XMonad
import XMonad.Hooks.ManageDocks (AvoidStruts, avoidStruts, docks, manageDocks)

myConfig :: String -> String -> XConfig (MyLayoutModifiers MyTogglableLayouts)
myConfig myFocusedBorderColor myNormalBorderColor =
  docks
    . ewmh
    . ewmhFullscreen
    . pagerHints
    $ def
      { terminal = myTerminal ++ " --class=Terminal",
        startupHook = myStartupHook,
        manageHook = myManageHook,
        logHook = refocusLastLogHook <+> logHook def,
        layoutHook = myLayoutModifiers myTogglableLayouts,
        handleEventHook = refocusLastWhen myPred <+> handleEventHook def,
        -- NOTE: Injected using nix strings.
        -- Think about parsing colorscheme.nix file in some way
        focusedBorderColor = myFocusedBorderColor,
        normalBorderColor = myNormalBorderColor,
        modMask = myModMask,
        borderWidth = 0
      }
      -- NOTE: Ordering matters here
      `additionalKeys` keysToAdd

