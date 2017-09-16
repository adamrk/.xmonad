import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run ( spawnPipe )
import XMonad.Util.EZConfig ( additionalKeys )
import XMonad.Layout.NoBorders ( smartBorders )
import Graphics.X11.ExtraTypes.XF86
import System.IO

muteCommand :: X ()
muteCommand  = spawn "amixer -q -D pulse set Master toggle"
volDownCommand :: X ()
volDownCommand = spawn "amixer -q set Master 2-"
volUpCommand :: X ()
volUpCommand = spawn "amixer -q set Master 2+"

volumeKeys = [ ((0, xF86XK_AudioMute ), muteCommand)
             , ((0, xF86XK_AudioRaiseVolume ), volUpCommand )
             , ((0, xF86XK_AudioLowerVolume ), volDownCommand )
             ]

--hacky way to change the screen brightness????
backlightDevice = "/sys/class/backlight/intel_backlight/brightness"

--max brightness is 189 so adjust by multiples of 9
brightUpCommand :: X ()
brightUpCommand = spawn $ "echo $(((`cat " ++ backlightDevice ++"` / 9 + 1) * 9)) >> " ++ backlightDevice
brightDownCommand :: X ()
brightDownCommand = spawn $ "echo $(((`cat " ++ backlightDevice ++"` / 9 - 1) * 9)) >> " ++ backlightDevice

brightnessKeys = [ ((0, xF86XK_MonBrightnessUp ), brightUpCommand)
                 , ((0, xF86XK_MonBrightnessDown ), brightDownCommand)
                 ]
 
main = do
  xmproc <- spawnPipe "xmobar"
  
  xmonad $  defaultConfig
    { manageHook = manageDocks <+> manageHook defaultConfig
    , layoutHook = avoidStruts $ smartBorders $ layoutHook defaultConfig
    , logHook = dynamicLogWithPP xmobarPP
                  { ppOutput = hPutStrLn xmproc
                  , ppTitle = xmobarColor "green" "" . shorten 50
                  }
    , modMask = mod4Mask -- Rebind Mod to the Windows Key
    } `additionalKeys`
    (
      [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock; xset dpms force off")
      , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
      , ((0, xK_Print), spawn "scrot")
      
      -- as recommended in the version 0.12 doc for XMonad.Hooks.ManageDocks on Hackage
      , ((mod4Mask, xK_b ), sendMessage ToggleStruts)
      ] ++
      volumeKeys ++
      brightnessKeys
    )
