d1 $ jux (hurry $ smooth "1.1 2 20 10.1 30.3 -1.1") $ "sergeXY" <| n ((run $ "<20 30 7 170 2 9 40 10>") * "<-1 -100 2 30 13 1 -39>") #pan (sine + rand) #rate ("<0.3 1 3 2>" +"0.01 0.3 0.1 0.2" * sine) #lfo 0.01 #freq 0.2 #hpf "<8000 4000 <20 10000> 100> 1000" #hpq(sine * "0.1 0.06 <0.4 <0.03 0.02>>") #delayt (fast 300 $ "100 20 100 20 30 4000 400" * sine) #delay "0.5 0.4" #room 0.1 #octersub 0.6 #att "<0.1 0.01 0.9>" #hold 0.8 #rel 0.1

d1 $ "techno" <| n (run "<23 10>") #speed "11.2 9 1.2 20 30 <[0.1 10] 50>"

d1 $ jux(hurry "<10 11> 1 .90")  $ "auto" <| n (run "<.11 1.2 .9 0.1>")

d1 $ jux(hurry "3.2 <10.2 1.0> 3.04 0.9") $ "auto drum 808" <| n (run "<7.2 1? [4 3.2?] 3 10>")

:{
d1 $ jux (hurry 2.1)$ s "superfork" <| note (run "<30 32 12>" |/ "10 20 <120 5 23>")
# octer 1
# freeze 1
# leslie 1
# delay 0.5
# squiz 1
:}

xfade 2 $ jux (hurry 2.1) $ "hh!32" #gain (fast "<20 1> <31 10 33 34 50>" $ sine) #cps "<2 1.3 3.5 0.1 10 0.3>" #distort 0.5

d10 $ jux (hurry $ smooth "1.1 3.1 2.3 0.5 10") $ "sergeXY!10" <|n (run "10 <340 10> 30 40 20") #rate (fast 10 $ (sine+ (log "2 0.4 0.1 40 2"))) #cps "0.5 1 2.3 0.1 3" #pan saw

d2 $ "supergrind supersnare sostoms sossnare" <| n (run 10 |- 1200 |/ 50)


d1 $ "808bd" <| n (run 10)
d2 $ "808ht" <| n (run 7)
d3 $ slow "2 0.1 2.3 0.9" $ "808lt" <| n (run 12 |% "<3 1 2 3 14 12>")
d4 $ jux(hurry 2) $ "east" <| n (run "<11 10 <23 10> 30 . 0.9>")
d5 $ "bd" #cps "<0.9 10 20 0.1 <40 100> 1> 2"
d6 $ "hh!32"
d7 $ jux (hurry "<[10 2] [20 0.1] 30 100 200>") $ "cp!16 sn!23" #speed "10 20 0.1 2" #pan rand
d8 $ "bd!10" #gain 2
d9 $ "trump" <| n (run "10 2 3 4 5 1")


d8 $ "breath ~ ~ ~ ~ breath*10 ~ breath!12" #octersub 1 #gain 2 #ringf 200 #ring 1 #leslie 1 #real (smooth "1 0.3 4.4 10.1 2.3") #imag (smooth "1 0.2 0.3 0.4 1") #cps "<10 1 0.5 20 32>"


d1 $ jux(hurry 2)$ "bd sn cp sn" <| n (run 201) #gain rand #pan rand
d2 $ "cp!16 sn!23" #cps "10 20 0.1 2"
d3 $ "f f:2" <| n (run 120) #octer saw



d4 $ jux(hurry $ smooth "2 10 2.01 3.1 <22.3 31 30 30.1>") $ "east" <| n (run $ smooth "<11 10 <23 10> 30 . 0.9>") #pan (fast "3 0.3 0.3 10 1.2 0.3" $ saw) #cps "<<0.3 <0.4 0.5>> <0.1 0.3? 0.3>>"



d1 $ "<[sn!200] [sn!400] [sn!200] [sn!4051][sn!1300]>" #cps ("<2 0.4 0.3 10.02> 2 <1.0 03.1 0.4> 3.0" * smooth "0.3 0.4 0.4 0.5 0.3 0.1 0.4 9 0.32 0.12 30 340 ") #pan (fast "30 30 10 0.5 200 10 30 4040 30 20 10" $ tri)

















./config-util/ghci-color -ghci-script 'config-util/BootTidal.hs'ilia_viazov@MacBookPro tcii % ./config-util/ghci-color -ghci-script 'config-util/BootTidal.hs'Loaded package environment from /Users/ilia_viazov/.ghc/aarch64-darwin-9.6.7/environments/defaultGHCi, version 9.6.7: https://www.haskell.org/ghc/  :? for help[TidalCycles version 1.10.1]Installed in /Users/ilia_viazov/.local/state/cabal/store/ghc-9.6.7/tdl-1.10.1-3f7ff30f/shareListening for external controls on 127.0.0.1:6010Loaded GHCi configuration from config-util/BootTidal.hstcii> Waiting for SuperDirt (v.1.7.2 or higher)..Connected to SuperDirt.d1 $ "bd!256" #pan (fast 50 $ sine)tcii> d1 $ "bd!256" #pan (fast 100 $ sine)tcii> d1 $ "bd!256" #pan (fast 10 $ sine)tcii> d1 $ "bd!256" #pan (fast 20 $ sine)tcii> d1 $ "bd!256" #pan (fast 1000 $ sine)tcii> d1 $ "bd!256" #pan (fast 1000 $ sine) #cps 4tcii> d1 $ "bd!256" #pan (fast 100 $ sine) #cps 4tcii> d1 $ "bd!256" #pan (fast 120 $ sine) #cps 4tcii> d1 $ "bd!256" #pan (fast . smooth 400 300 200 $ sine) #cps 4<interactive>:9:21: error: [GHC-83865]    • Couldn't match type: Pattern a0 -> Pattern a0                     with: Pattern Double      Expected: Pattern Time -> Pattern Double        Actual: Pattern Time -> Pattern a0 -> Pattern a0    • Probable cause: ‘fast’ is applied to too few arguments      In the first argument of ‘(.)’, namely ‘fast’      In the first argument of ‘($)’, namely ‘fast . smooth 400 300 200’      In the first argument of ‘pan’, namely        ‘(fast . smooth 400 300 200 $ sine)’<interactive>:9:28: error: [GHC-83865]    • Couldn't match expected type: t0                                    -> t1 -> Pattern a2 -> Pattern Time                  with actual type: Pattern a1    • The function ‘smooth’ is applied to three value arguments,        but its type ‘Pattern a1 -> Pattern a1’ has only one      In the second argument of ‘(.)’, namely ‘smooth 400 300 200’      In the first argument of ‘($)’, namely ‘fast . smooth 400 300 200’tcii> d1 $ "bd!256" #pan (fast (smooth 400 300 200) $ sine) #cps 4<interactive>:10:27: error: [GHC-83865]    • Couldn't match expected type: t0 -> t1 -> Pattern Time                  with actual type: Pattern a0    • The function ‘smooth’ is applied to three value arguments,        but its type ‘Pattern a0 -> Pattern a0’ has only one      In the first argument of ‘fast’, namely ‘(smooth 400 300 200)’      In the first argument of ‘($)’, namely ‘fast (smooth 400 300 200)’tcii> d1 $ "bd!256" #pan (fast . (smooth 400 300 200) $ sine) #cps 4<interactive>:11:21: error: [GHC-83865]    • Couldn't match type: Pattern a0 -> Pattern a0                     with: Pattern Double      Expected: Pattern Time -> Pattern Double        Actual: Pattern Time -> Pattern a0 -> Pattern a0    • Probable cause: ‘fast’ is applied to too few arguments      In the first argument of ‘(.)’, namely ‘fast’      In the first argument of ‘($)’, namely        ‘fast . (smooth 400 300 200)’      In the first argument of ‘pan’, namely        ‘(fast . (smooth 400 300 200) $ sine)’<interactive>:11:29: error: [GHC-83865]    • Couldn't match expected type: t0                                    -> t1 -> Pattern a2 -> Pattern Time                  with actual type: Pattern a1    • The function ‘smooth’ is applied to three value arguments,        but its type ‘Pattern a1 -> Pattern a1’ has only one      In the second argument of ‘(.)’, namely ‘(smooth 400 300 200)’      In the first argument of ‘($)’, namely        ‘fast . (smooth 400 300 200)’tcii> d1 $ "bd!256" #pan (fast $ (smooth 400 300 200) $ sine) #cps 4<interactive>:12:21: error: [GHC-83865]    • Couldn't match expected type: Pattern Double                  with actual type: Pattern a0 -> Pattern a0    • Probable cause: ‘($)’ is applied to too few arguments      In the first argument of ‘pan’, namely        ‘(fast $ (smooth 400 300 200) $ sine)’      In the second argument of ‘(#), namely        ‘pan (fast $ (smooth 400 300 200) $ sine)’      In the first argument of ‘(#)’, namely        ‘"bd!256" # pan (fast $ (smooth 400 300 200) $ sine)’<interactive>:12:28: error: [GHC-83865]    • Couldn't match expected type: t0                                    -> t1 -> Pattern a2 -> Pattern Time                  with actual type: Pattern a1    • The function ‘smooth’ is applied to three value arguments,        but its type ‘Pattern a1 -> Pattern a1’ has only one      In the first argument of ‘($)’, namely ‘(smooth 400 300 200)’      In the second argument of ‘($)’, namely        ‘(smooth 400 300 200) $ sine’tcii> d1 $ "bd!256" #pan (toList(smooth 400 300 200) $ sine) #cps 4<interactive>:13:21: error: [GHC-88464]    Variable not in scope: toList :: t2 -> Pattern a1 -> Pattern Double    Suggested fix:      Perhaps use data constructor ‘VList’ (imported from Sound.Tidal.Boot)tcii> toto               toData           toScale          tomdecayCountTotoArg            toDatum          toScale'         tomdecayTaketoArgTake        toEnum           toTake           tomdecaybustoArgbus         toEvent          toTime           tomdecayrecvtoArgrecv        toInteger        toValue          torecvtoClockConfig    toOSC            tobustoCount          toPat            tomdecaytoCountTo        toRational       tomdecayCounttcii> PatPatId    Patterntcii> PaParseable  PatId      PatternDisplay all 5444 possibilities? (y or n)!!#$$!%%|&&*****|*>*|+++++|+|--|.//=/|<<$<$><*<*><<*<=<><|<~=<<==>>=>>----More----tcii> d1 $ "bd!256" #pan (toList(smooth 400 300 200) $ sine) #cps 4^[[A^[b^Ctcii> d1 $ "bd!256" #pan (fast 40 $ sine) #cps 4tcii> d1 $ "bd!256" #pan (fast 40 $ sine) #cps 4tcii> d1 $ "bd!256" #pan (toList(smooth 400 300 200) $ sine) #cps 4^Ctcii>tcii>tcii>tcii>tcii>tcii>tcii>tcii>tcii>tcii>tcii>tcii>tcii>tcii> d1 $ "bd!256" #pan (fast 40 $ sine) #cps 4tcii> d1 $ "bd!256" #pan (toList(smooth 400 300 200) $ sine) #cps 4^[[A^[[A^Ctcii> :r^[[A^Ctcii> :RRR^Ctcii> :l^Ctcii>tcii>tcii>tcii>tcii> :qilia_viazov@MacBookPro tcii % ./config-util/ghci-color -ghci-script 'config-util/BootTidal.hs'Loaded package environment from /Users/ilia_viazov/.ghc/aarch64-darwin-9.6.7/environments/defaultGHCi, version 9.6.7: https://www.haskell.org/ghc/  :? for help[TidalCycles version 1.10.1]Installed in /Users/ilia_viazov/.local/state/cabal/store/ghc-9.6.7/tdl-1.10.1-3f7ff30f/shareListening for external controls on 127.0.0.1:6010Connected to SupeLroDaidretd.GHCi configuration from config-util/BootTidal.hstcii> d1 $ "bd!256" #pan (toList(smooth 400 300 200) $ sine) #cps 4<interactive>:1:21: error: [GHC-88464]    Variable not in scope: toList :: t2 -> Pattern a1 -> Pattern Double    Suggested fix:      Perhaps use data constructor ‘VList’ (imported from Sound.Tidal.Boot)tcii> d1 $ "bd!256" #pan (fast 40 $ sine) #cps 4tcii> d1 $ "h!256" #pan (fast 40 $ sine) #cps 4tcii> d1 $ "hh!256" #pan (fast 40 $ sine) #cps 4tcii> d1 $ "h!256" #pan (fast 40 $ sine) #cps 4tcii> d1 $ "h!256" #pan (fast 40 $ sine) #cps 2tcii> d1 $ "h!256" #pan (fast 40 $ sine) #cps 1tcii> d1 $ "h!256" #pan (fast 40 $ sine) #cps 0tcii> d1 $ "h!256" #pan (fast 40 $ sine) #cps 1tcii> d1 $ "h!256" #pan (fast 40 $ sine) #cps 0tcii> d1 $ "h!256" #pan (fast 40 $ sine) #cps (smooth "0 0.1 0.2 0.3 0"<interactive>:11:66: error: [GHC-58481]    parse error (possibly incorrect indentation or mismatched brackets)tcii> d1 $ "h!256" #pan (fast 40 $ sine) #cps (smooth "0 0.1 0.2 0.3 0")tcii> d1 $ "h!256" #pan (fast 40 $ sine) #cps (smooth "0.1 0.2 0.3 0")tcii> d1 $ "h!256" #pan (fast 40 $ smooth "0.1 0.2 0.3 0.1 0.5 0.1 0.9") #cps (smooth "0.1 0.2 0.3 0")tcii> d1 $ "h!256" #pan (fast 40 $ smooth "0.1 0.2 0.3 0.1 0.5 0.1 0.9" * 500) #cps (smooth "0.1 0.2 0.3 0")tcii> d1 $ "h!256" #pan (fast 40 $ smooth "0.1 0.2 0.3 0.1 0.5 0.1 0.9") #cps (smooth "0.1 0.2 0.3 0")tcii> d1 $ "h!256" #pan (fast 400 $ smooth "0.1 0.2 0.3 0.1 0.5 0.1 0.9") #cps (smooth "0.1 0.2 0.3 0")tcii> d1 $ "h!256" #pan (fast 400 $ sine) #cps (smooth "0.1 0.2 0.3 0")tcii> d1 $ "h!256" #pan (fast "40030 40 10" $ sine) #cps (smooth "0.1 0.2 0.3 0")tcii> d1 $ "h!256" #pan (fast "40030 40 10 20 30" $ sine) #cps (smooth "0.1 0.2 0.3 0")tcii> d1 $ "h!256" #pan (fast "400 40 10 20 30" $ sine) #cps (smooth "0.1 0.2 0.3 0")tcii> d1 $ "h!256" #pan (fast "400 40 10 20 30" $ sine) #cps (smooth "0.1 0.2 0.3 4 0")tcii> d1 $ "h!256" #pan (fast "400 40 10 20 30" $ sine) #cps (smooth "0.1 0.2 0.2 0.3 4 0")tcii> d1 $ "h!256" #pan (fast "400 40 10 20 30" $ sine) #cps (smooth "0.1 0.3 0.4 05 0.2 0.2 0.3 4 0")tcii> d1 $ "h!256" #pan (fast "400 40 10 20 30" $ sine) #cps (smooth "0.1 0.3 0.4 05 0.2 0.2 0.3 4 0")tcii> d2 $ "bd!10"tcii> d2 $ "bd!10" #pan randtcii> d2 $ "bd!10" #pan rand #gain 2tcii> d2 $ "bd!12" #pan rand #gain 2tcii> d2 $ "<808bd!12>" <|n (run 10) #pan rand #gain 2tcii> d2 $ "<808bd!12>" <|n (run "10 20 300 10") #pan rand #gain 2tcii> d2 $ "<[808bd!12] [808bd!203]>" <|n (run "10 20 300 10") #pan rand #gain 2tcii> d2 $ "<[808bd!12] [808bd!23]>" <|n (run "10 20 300 10") #pan rand #gain 2tcii> d2 $ "<[808bd!12] [808bd!23]>" <|n (run "10 20 200 300 10") #pan rand #gain 2tcii> d2 $ "<[808bd!12] [808bd!23 sn]>" <|n (run "10 20 200 300 10") #pan rand #gain 2tcii> d2 $ "<[808bd!12 sn hh] [808bd!23 sn]>" <|n (run "10 20 200 300 10") #pan rand #gain 2tcii> d2 $ jux (hurry $ smooth "0.9 1.1") $ "<[808bd!12 sn hh] [808bd!23 sn]>" <|n (run "10 20 200 300 10") #pan rand #gain 2tcii> d2 $ jux (hurry $ smooth "0.9 1.1 0.1 0.4 9") $ "<[808bd!12 sn hh] [808bd!23 sn]>" <|n (run "10 20 200 300 10") #pan rand #gain 2tcii> d2 $ jux (hurry $ smooth "0.9 1.1 0.1 0.4 8") $ "<[808bd!12 sn hh] [808bd!23 sn]>" <|n (run "10 20 200 300 10") #pan rand #gain 2tcii> d2 $ jux (hurry $ smooth "0.9 1.1 0.1 0.4 900") $ "<[808bd!12 sn hh] [808bd!23 sn]>" <|n (run "10 20 200 300 10") #pan rand #gain 2tcii> d2 $ jux (hurry $ smooth "0.9 1.1 0.1 0.4 9jux (hurry $ smooth "0.9 1.1 0.1 0.4 900") $ "<[808bd!12 sn hh] [808bd!23 sn]>" <|n (run "10 20 200 300 10") #pan rand #gain 2<interactive>:41:4: warning: [GHC-47082] [-Woperator-whitespace-ext-conflict]    The prefix use of a ‘$’ would denote an untyped splice      were the TemplateHaskell extension enabled.    Suggested fix: Add whitespace after the ‘$’.tcii> d2 $jux (hurry $ smooth "0.9 1.1 0.1 0.4 900") $ "<[808bd!12 sn hh] [808bd!23 sn]>" <|n jux (hurry $ smooth "0.9 1.1 0.1 0.4 900") $ "<[808bd!12 sn hh] [808bd!23 sn]>" <|n (run "10 20 200 300 10") #pan rand #gain 2 skip: 43]<interactive>:42:133: error: [GHC-58481] parse error on input ‘]’tcii> d2 $ jux (hurry $ smooth "0.9 1.1 0.1 0.4 900") $ "<[808bd!12 sn hh] [808bd!23 sn]>" <|n (run "10 20 200 300 10") #pan rand #gain 2 ]skip: 40<interactive>:43:133: error: [GHC-58481] parse error on input ‘]’tcii>tcii> d2 $ jux (hurry $ smooth "0.9 1.1 0.1 0.4 90") $ "<[808bd!12 sn hh] [808bd!23 sn]>" <|n (run "10 20 200 300 10") #pan rand #gain 2 ]^[[A^[[B^Ctcii> hushtcii> hushtcii> panictcii> :finish
