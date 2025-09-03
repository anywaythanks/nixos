import Control.Monad.Identity (Identity)
import Control.Monad.Reader (ReaderT)
import qualified Data.Map as M
import Graphics.X11.ExtraTypes.XF86
  ( xF86XK_AudioLowerVolume,
    xF86XK_AudioMute,
    xF86XK_AudioRaiseVolume,
  )
import System.Posix.Process (forkProcess)
import System.Process (spawnCommand, waitForProcess)
import System.Taffybar.Support.PagerHints (pagerHints)
import XMonad
import XMonad.Actions.SpawnOn (spawnAndDo)
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Hooks.InsertPosition (Focus (Newer), Position (Above, End), insertPosition)
import XMonad.Hooks.ManageDocks (AvoidStruts, avoidStruts, docks, manageDocks)
import XMonad.Hooks.ManageHelpers (doFullFloat)
import XMonad.Hooks.RefocusLast
import XMonad.Layout.Accordion (Accordion (Accordion))
import XMonad.Layout.Gaps
  ( Direction2D (D, L, R, U),
    GapMessage (ModifyGaps, ToggleGaps),
    GapSpec,
    Gaps,
    gaps,
  )
import XMonad.Layout.Grid (Grid (Grid, GridRatio))
import XMonad.Layout.LayoutModifier (ModifiedLayout (ModifiedLayout))
import XMonad.Layout.MultiToggle
  ( EOT,
    HCons,
    MultiToggle,
    Toggle (Toggle),
    mkToggle,
    single,
  )
import XMonad.Layout.MultiToggle.Instances (StdTransformers (FULL))
import XMonad.Layout.NoBorders
  ( Ambiguity (OnlyScreenFloat),
    ConfigurableBorder,
    lessBorders,
    noBorders,
  )
import XMonad.Layout.PerScreen (PerScreen, ifWider)
import XMonad.Layout.Spacing
  ( Border (Border),
    Spacing (Spacing),
    bottom,
    decWindowSpacing,
    incWindowSpacing,
    left,
    right,
    screenBorder,
    screenBorderEnabled,
    smartBorder,
    toggleWindowSpacingEnabled,
    top,
    windowBorder,
    windowBorderEnabled,
  )
import XMonad.Layout.ThreeColumns (ThreeCol (ThreeCol, threeColDelta, threeColFrac, threeColNMaster))
import XMonad.Layout.TwoPanePersistent (TwoPanePersistent (TwoPanePersistent, dFrac, mFrac, slaveWin))
import XMonad.StackSet
  ( RationalRect (RationalRect),
    current,
    focusMaster,
    greedyView,
    layout,
    shift,
    workspace,
  )
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Util.NamedScratchpad
  ( NamedScratchpad (NS),
    cmd,
    customFloating,
    hook,
    name,
    namedScratchpadAction,
    namedScratchpadManageHook,
    query,
  )
import XMonad.Util.Run (eval, execute, (>&&>))

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

myPred :: Query Bool
myPred = refocusingIsActive <||> isFloat

myModMask :: KeyMask
myModMask = mod4Mask

myTerminal :: String
myTerminal = "alacritty"

openWidgetsPanel :: String
openWidgetsPanel =
  unwords
    [ "eww",
      "open-many",
      "--toggle",
      "full-bg",
      "full-profile",
      "full-system",
      "full-clock",
      "full-uptime",
      "full-music",
      "full-github",
      "full-reddit",
      -- "full-twitter",
      "full-youtube",
      "full-weather",
      "full-apps",
      "full-mail",
      "full-nix_search",
      "full-goodreads",
      "full-logout",
      "full-sleep",
      "full-reboot",
      "full-poweroff",
      "full-folders"
    ]

openPowerMenu :: String
openPowerMenu =
  unwords
    [ "eww",
      "open-many",
      "--toggle",
      "powermenu-bg",
      "powermenu-logout",
      "powermenu-sleep",
      "powermenu-reboot",
      "powermenu-poweroff"
    ]

toggleFloat :: Window -> X ()
toggleFloat w =
  windows
    ( \s ->
        if M.member w (W.floating s)
          then W.sink w s
          else W.float w (XMonad.StackSet.RationalRect (1 / 3) (1 / 4) (1 / 2) (4 / 5)) s
    )

keysToAdd :: [((KeyMask, KeySym), X ())]
keysToAdd = launchers ++ multimediaKeys ++ layoutRelated
  where
    launchers =
      [ ( (myModMask, xK_d),
          spawn "rofi -show drun -theme grid"
        ),
        ( (myModMask, xK_c),
          namedScratchpadAction myScratchPads "terminal"
        ),
        ( (myModMask .|. shiftMask, xK_p),
          spawn openPowerMenu
        ),
        ( (myModMask .|. shiftMask, xK_l),
          spawn "betterlockscreen --wall -blur -l"
        ),
        ( (myModMask, xK_Return),
          spawn $ myTerminal ++ " --class=Terminal"
        ),
        ( (myModMask .|. shiftMask, xK_n),
          spawn "kill -s USR1 $(pidof deadd-notification-center)"
        ),
        ( (myModMask .|. controlMask, xK_w),
          spawn openWidgetsPanel
        ),
        ( (myModMask, xK_s),
          spawn "flameshot-gui"
        ),
        ( (myModMask .|. shiftMask, xK_s),
          spawn "~/less/actual/JS/screen.sh"
        ),
        ( (myModMask, xK_p),
          spawn ""
        ),
        ( (myModMask .|. shiftMask, xK_c),
          spawn ""
        ),
        ( (myModMask .|. shiftMask, xK_q),
          kill
        ),
        ( (myModMask .|. shiftMask, xK_space),
          withFocused toggleFloat
        ),
        ( (myModMask, xK_f),
          sendMessage $ JumpToLayout "Full"
        ),
        ( (myModMask, xK_g),
          toggleFocus
        )
      ]

    multimediaKeys =
      [ ((0, xF86XK_AudioLowerVolume), spawn "amixer sset Master 5%-"),
        ((0, xF86XK_AudioRaiseVolume), spawn "amixer sset Master 5%+"),
        ((0, xF86XK_AudioMute), spawn "amixer sset Master toggle")
      ]
    layoutRelated =
      [ ((myModMask, xK_n), sendMessage NextLayout),
        ((myModMask, xK_m), sendMessage $ Toggle FULL),
        ((myModMask .|. shiftMask, xK_m), windows XMonad.StackSet.focusMaster),
        ((myModMask .|. controlMask, xK_g), sendMessage ToggleGaps),
        ((myModMask .|. controlMask, xK_h), sendMessage $ ModifyGaps incGap),
        ((myModMask .|. controlMask, xK_f), sendMessage $ ModifyGaps decGap),
        ((myModMask .|. controlMask, xK_s), toggleWindowSpacingEnabled),
        ((myModMask .|. controlMask, xK_d), incWindowSpacing 5),
        ((myModMask .|. controlMask, xK_a), decWindowSpacing 5)
      ]
      where
        decGap :: GapSpec -> GapSpec
        decGap = fmap (fmap (subtract 5))

        incGap :: GapSpec -> GapSpec
        incGap = fmap (fmap (+ 5))

type MyLayouts = PerScreen HorizontalMonitorLayouts VerticalMonitorLayouts

type HorizontalMonitorLayouts = (Choose Tall (Choose TwoPanePersistent (Choose ThreeCol Grid)))

type VerticalMonitorLayouts = (Choose (Mirror Tall) (Choose Accordion Grid))

myLayouts :: MyLayouts Window
myLayouts = ifWider minHorizontalWidth horizontalMonitorLayouts verticalMonitorLayouts
  where
    horizontalMonitorLayouts = tall ||| twoPane ||| threeCol ||| Grid
    verticalMonitorLayouts = Mirror tall ||| Accordion ||| invertedGrid
    -- we are using the `ifWider` layoutModifier to have two different sets of
    -- layout modifiers for monitors in horizontal or vertical configuration
    minHorizontalWidth = 2560
    -- full = renamed [Replace "Full"] $ noBorders (Full)
    tall = Tall {tallNMaster = 1, tallRatioIncrement = 3 / 100, tallRatio = 3 / 5}
    twoPane = TwoPanePersistent {slaveWin = Nothing, dFrac = 3 / 100, mFrac = 3 / 5}
    threeCol = ThreeCol {threeColNMaster = 1, threeColDelta = 3 / 100, threeColFrac = 1 / 2}
    invertedGrid = GridRatio (9 / 16)

type MyTogglableLayouts = MultiToggle (HCons StdTransformers EOT) MyLayouts

myTogglableLayouts :: MyTogglableLayouts Window
myTogglableLayouts = mkToggle (single FULL) myLayouts

type MyLayoutModifiers a =
  ModifiedLayout
    (ConfigurableBorder Ambiguity)
    (ModifiedLayout AvoidStruts (ModifiedLayout Spacing (ModifiedLayout Gaps a)))

myLayoutModifiers ::
  MyTogglableLayouts Window ->
  (MyLayoutModifiers MyTogglableLayouts) Window
myLayoutModifiers =
  lessBorders OnlyScreenFloat . avoidStruts . spacingLayoutSetup . gapLayoutSetup
  where
    spacingLayoutSetup :: l a -> ModifiedLayout Spacing l a
    spacingLayoutSetup =
      ModifiedLayout $
        Spacing
          { smartBorder = False,
            screenBorder = screenBorder,
            screenBorderEnabled = False,
            windowBorder = windowBorder,
            windowBorderEnabled = True
          }

    gapLayoutSetup :: l a -> ModifiedLayout Gaps l a
    gapLayoutSetup =
      gaps [(U, edgeGap), (R, edgeGap), (D, edgeGap), (L, edgeGap)]

    screenBorder = Border {top = 5, bottom = 5, right = 5, left = 5}
    windowBorder = Border {top = 5, bottom = 5, right = 5, left = 5}
    edgeGap = 4

myScratchPads :: [NamedScratchpad]
myScratchPads = [scTerminal]
  where
    scTerminal =
      NS
        { name = "terminal",
          cmd = myTerminal ++ " --class=scratchpad",
          query = className =? "scratchpad",
          hook = customFloating largeRect
        }
    largeRect = XMonad.StackSet.RationalRect locationLeft locationTop width height
      where
        height = 2 / 3
        width = 2 / 3
        locationTop = 1 / 6
        locationLeft = 1 / 6

myManageHook :: ManageHook
myManageHook =
  composeAll
    [ manageDocks,
      className =? "TelegramDesktop" --> doFloat,
      namedScratchpadManageHook myScratchPads,
      insertPosition Above Newer
    ]

myStartupHook :: X ()
myStartupHook = spawn "custom-panel-launch"