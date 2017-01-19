;; EthnoCulturalTagWorld-v1 ECT-v1 (public)
;; dave@davidhales.com, Oct. 2015
;; SCID ESRC Project, Centre for Policy Modelling, Manchester Met. http://cfpm.org

;; user interface supplies following globals:
;; cost, benefit, number-of-agents, number-of-tags, tag-mutate-prob, strategy-mutate-prob,
;; GIGB (game in-group bias) probability to game interact with in-group rather than randomly selected agent
;; LIGB (learning in-group bias) probability to imitate from in-group rather than randomly selected agent

;; global variables
globals [donate         ;; constant meaning agent donates
         cheat          ;; constant meaning agent shirks
         ;; bookkeeping variables:
         donations      ;; number of donation made in a cycle
         inter-eth-don  ;; number of each type of donation made
         sln  ;; proportions of the 4 different in-group selector types
         slc
         sle
         slb
         stSS ;; proportions of the 4 different strategy types
         stDS
         stSD
         stDD
         ]

breed [agents agent]  ;; create a breed of turtles called agents

;; agent level variables
agents-own [
            etag         ;; ethnic marker (fixed)
            ctag         ;; cultural tag (can evolve)
            selector     ;; in-group selector method: 0=none, 1=cultural tag only, 2=ethnic marker only, 3=both
            in-strategy  ;; strategy to use for in-group partners (donate or cheat)
            out-strategy ;; strategy to use for out-group partners (donate or cheat)
            payoff       ;; stores accumulated payoff over interaction phase
            newCopy      ;; flag that indicates if agent has already imitated within current imitation phase         
            new-ctag     ;; new- variables store new traits obtained from an imitation to be used in next interaction phase
            new-selector
            new-in-strategy
            new-out-strategy
            ]

;; === SETUP button function

to setup
  clear-all     ;; wipe population
  set donate 1  ;; constant for donate strategy
  set cheat 0   ;; constant for cheat (dont donate) strategy
    
  ;; initialise agents
  create-agents number-of-agents [
    ;; default both strategies to shirk (i.e. cheat or defect) and random selector
    set selector random 4       ;; random in-group selector
    set in-strategy random 2    ;; random in-group strategy
    set out-strategy random 2   ;; random out-group strategy
    set ctag (random number-of-tags) ;; random cultural tag

    ;; do an equal split of ethnic tags over agents
    let e-group-size int (number-of-agents / number-of-eth)  ;; size of an ethnic group
    set etag int (who / e-group-size) ;; who is unique agent ID from 0..number-of-agents-1

    if etag > (number-of-eth - 1) [set etag (random number-of-eth)]  ;; leftover agents get random etag 

    set payoff 0        ;; cumulative payoff from playing donation games
    set newCopy false   ;; flag indicating if new traits have been imitated
    setposCircleStack   ;; visualisation
  ]
  reset-ticks
end

;; GO button function

to go
 set donations 0                  ;; zero bookkeeping variables
 set inter-eth-don 0
 set sln 0          ;; proportions of each in-group selector type
 set slc 0
 set sle 0
 set slb 0
 set stSS 0         ;; proportions of each strategy type
 set stDS 0
 set stSD 0
 set stDD 0
 
 
 collect-statistics               ;; collect population statsitics
 
 ;; --- interact - locate partners and play donation game updating payoffs
 interaction-phase
  
 ;; --- imitate - agents decide if to copy another agent using payoffs and tournament rule
 imitation-phase
 
 ;; --- innovate - mutate traits of agents by relevant probabilities   
 innovation-phase
 
 ;; finish cycle
 ask agents [setposCircleStack]   ;; visualisation
 tick
end

;; === collect population stats - counts of selector and strategy types in population
to collect-statistics
 ask agents [
   colour-agent-by-strategy-type   
   count-selector-types
   count-strategy-types
 ]
 calc-proportions  ;; change counts to proprtions
end

;; === innovation-phase - mutation
to innovation-phase
   ask agents [
    if prob strategy-mutate-prob [ set in-strategy flip-strat in-strategy ]     ;; mutate in-group strategy
    if prob strategy-mutate-prob [ set out-strategy flip-strat out-strategy ]   ;; mutate out-group strategy
    if prob strategy-mutate-prob [ set selector random 4 ]                      ;; mutate in-group selector
    if prob tag-mutate-prob [ set ctag random number-of-tags ]                  ;; mutate ctag
  ]
end

;; === interaction-phase play donation games
to interaction-phase
  ask agents [ interaction ]    ;; each agent plays donation game
end

;; === imitation-phase - reproduction of traits
to imitation-phase
 ask agents [imitation]   ;; do imitation for each agent
 ask agents [             ;; copy over any imitated traits and zero all agent payoffs
   if newCopy [                             
       set ctag new-ctag
       set in-strategy new-in-strategy
       set out-strategy new-out-strategy
       set selector new-selector
       set newCopy false
   ]
   set payoff 0
 ]
end

;; === do an imitation - agent copies others to temp variables so they continue to be allowed to be copied by other agents
to imitation
   let partner nobody
   if prob LIGB [set partner one-of other agents with [in-their-group? myself]]              ;; with prob LIGB select a tag match parter
   if partner = nobody [set partner one-of other agents]          ;; get rnd partner if no partner currently found   
   if payoff < [payoff] of partner [imitate partner]         ;; if partner doing better copy it        
end

;; === imitate copyable traits from partner-agent to temp variables
to imitate [partner-agent]
   if partner-agent != nobody [          ;; only imitate if partner-agent exists
     set new-ctag [ctag] of partner-agent
     set new-in-strategy [in-strategy] of partner-agent
     set new-out-strategy [out-strategy] of partner-agent
     set new-selector [selector] of partner-agent
     set newCopy true                    ;; flag a newCopy (imitation) has been made for this agent
     ]                                         
end

;; === game interact with game-in-group-bias. Select an in-group partner with prob. GIGSB in one exists
to interaction
  let partner nobody
  if prob GIGB [set partner one-of other agents with [in-their-group? myself]]   ;; with GIGB get in-group partner
  if partner = nobody [set partner one-of other agents] 
  play-game partner 
end

;; === game interact with partner-agent - based on selector, tags and strategies of partner decide if to donate or not to other agent
;; if partner is determined to be in my in-group then enact in-group strategy otherwise out-group strategy
to play-game [partner-agent]
  ifelse in-my-group? partner-agent
    [if in-strategy = donate [donate-to partner-agent]]   ;; if tags match use in-strategy
    [if out-strategy = donate [donate-to partner-agent]]  ;; else use out-strategy
end

;; === make a donation from this agent to partner-agent
to donate-to [partner-agent]
  ask partner-agent [set payoff payoff + benefit]
  set payoff payoff - cost
  ;; update bookkeeping globals 
  set donations donations + 1
  if etag != [etag] of partner-agent [set inter-eth-don inter-eth-don + 1]    ;; an inter-ethnic donation?
end

;; === use in-group selector of partner, etag and ctag to determine if partner-agent thinks I am in THEIR in-group
;; note: this does not necessarily mean I think they are in my in-group. This reporter is useful for using with the
;; "one-of other agents with" queries. Essentially we ask the queried agent to determine if I think they are in my in-group
;; based on my group selector
to-report in-their-group? [partner-agent]
  let result true
  ifelse [selector] of partner-agent = 1 [if ctag != [ctag] of partner-agent [set result false]]        ;; culuralist (only match ctag)
    [ ifelse [selector] of partner-agent = 2 [if etag != [etag] of partner-agent [set result false]]    ;; ethnoist (only match etag)
       [ if [selector] of partner-agent = 3 [if (etag != [etag] of partner-agent) or
           (ctag != [ctag] of partner-agent) [set result false]]                     ;; exclusivist (both)
       ]
    ]
    report result
end

;; === use my in-group selector, etag and ctag to determine if I think partner-agent is in MY in-group
to-report in-my-group? [partner-agent]
  let result true
  ifelse selector = 1 [if ctag != [ctag] of partner-agent [set result false]]        ;; culuralist (only match ctag)
    [ ifelse selector = 2 [if etag != [etag] of partner-agent [set result false]]    ;; ethnoist (only match etag)
       [ if selector = 3 [if (etag != [etag] of partner-agent) or
           (ctag != [ctag] of partner-agent) [set result false]]                     ;; exclusivist (both)
       ]
    ]
    report result
end

;; === flip donate / cheat strategy
to-report flip-strat [strat]
  ifelse strat = donate [report cheat] [report donate]
end

;; === prob - returns value "TRUE" with probability determined by input
to-report prob [nm]
  report (random-float 1 < nm)
end

;; === report proportion of game interactions that produced donation
to-report donation-rate
  report donations / (number-of-agents)  
end

;; === report proportion of donations that were inter-ethnic
to-report inter-ethnic-donation-rate
  ifelse donations > 0 [report inter-eth-don / donations] [report 0]  ;; proportion of donations
end

;; === count in-group selector types - sln = none, slc = cultural, sle = ethnic, slb = both
to count-selector-types
  if selector = 0 [set sln sln + 1]
  if selector = 1 [set slc slc + 1]
  if selector = 2 [set sle sle + 1]
  if selector = 3 [set slb slb + 1]
end

;; === count strategy types: stSD = in-group shirk, out-group donate, stDS = in-group donate, out-group shirk
;; stSS = shirk on all, stDD = donate to all
to count-strategy-types
  colour-agent-by-strategy-type
  if color = blue [set stSS stSS + 1]
  if color = red [set stDS stDS + 1]
  if color = green [set stSD stSD + 1]
  if color = yellow [set stDD stDD + 1]
end

;; === normalise the stratety and selector type counts to proportions of the population
to calc-proportions
  set sln sln / number-of-agents    ;; selector counts
  set slc slc / number-of-agents
  set sle sle / number-of-agents
  set slb slb / number-of-agents
  set stSS stSS / number-of-agents  ;; strategy counts
  set stDS stDS / number-of-agents
  set stSD stSD / number-of-agents
  set stDD stDD / number-of-agents
end

;; === visualise agents around a ring where wich position on the ring is a unique ctag
;; agents sharing shame ctag are stacked outward on top of each other
;; hence straight lines of agents represent those sharing a ctag
;; colour each agent based on in-group / out-group strategy
to setposCircleStack
  set size 1
  set shape "circle"
  colour-agent-by-strategy-type
  setxy 0 0
  facexy 0 1
  right ctag * (360 / number-of-tags)
  forward 5
  let move-count 0
  ;; move forward until there is space or max number of moves - stops turtle going over edge of world grid
  while [ (any? other agents-here) and move-count < 45] ;; 45 assumes world grid is square of size (50,50,-50,-50)
     [forward 1
      set move-count move-count + 1]
end

;; === set colour of agent based on current strategy type blue = SS, green = SD, red = DS, yellow = DD
;; where DS = donate to in-group, shirk on out-group. SD = shirk on in-group, donate to out-group.
;; DD = donate to everyone, SS = shirk on everyone.
to colour-agent-by-strategy-type
  set color blue
  if out-strategy = donate [set color green]
  if in-strategy = donate [set color red]
  if (in-strategy = donate) and (out-strategy = donate) [set color yellow] 
end
@#$#@#$#@
GRAPHICS-WINDOW
752
10
1166
445
50
50
4.0
1
10
1
1
1
0
1
1
1
-50
50
-50
50
1
1
1
ticks
30.0

BUTTON
18
15
73
48
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
141
15
196
48
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
220
11
740
165
donation rates
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"DR" 1.0 0 -2674135 true "" "plot donation-rate"
"IE" 1.0 0 -13345367 true "" "plot inter-ethnic-donation-rate"

BUTTON
79
15
134
48
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
17
184
171
217
number-of-agents
number-of-agents
0
1000
100
1
1
NIL
HORIZONTAL

SLIDER
14
307
169
340
tag-mutate-prob
tag-mutate-prob
0
0.1
0.01
0.001
1
NIL
HORIZONTAL

SLIDER
14
343
169
376
strategy-mutate-prob
strategy-mutate-prob
0
0.1
0.0010
0.001
1
NIL
HORIZONTAL

SLIDER
16
221
170
254
number-of-tags
number-of-tags
1
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
13
391
105
424
cost
cost
0
1
0.1
0.1
1
NIL
HORIZONTAL

SLIDER
111
391
203
424
benefit
benefit
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
12
431
104
464
GIGB
GIGB
0
1
1
0.1
1
NIL
HORIZONTAL

PLOT
220
168
741
318
strategy types
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"DS" 1.0 0 -2674135 true "" "plot stDS"
"SS" 1.0 0 -13345367 true "" "plot stSS"
"DD" 1.0 0 -1184463 true "" "plot stDD"
"SD" 1.0 0 -10899396 true "" "plot stSD"

SLIDER
111
431
203
464
LIGB
LIGB
0
1
0
0.1
1
NIL
HORIZONTAL

SLIDER
17
258
169
291
number-of-eth
number-of-eth
1
10
2
1
1
NIL
HORIZONTAL

PLOT
220
322
741
472
in-group selectors
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"SN" 1.0 0 -16777216 true "" "plot sln"
"SC" 1.0 0 -2674135 true "" "plot slc"
"SE" 1.0 0 -13345367 true "" "plot sle"
"SB" 1.0 0 -10899396 true "" "plot slb"

TEXTBOX
20
58
215
179
Key to plots =>\nDR = donation rate\nIE = inter-ethnic donation rate\nDS = donate to in-group only\nSS = donate to nobody\nDD = donate to everybody\nSD = donate to out-group only\nSN = none in-group (no tag)\nSC = cultural in-group (only cultural tag)\nSE = ethnic in-group (only ethnic tag)\nSB = both in-group (both tags)
9
0.0
1

TEXTBOX
17
470
198
502
GIGB = game interaction bias\nLIGB = learning interaction bias
11
0.0
1

TEXTBOX
758
449
1163
581
Agents are stacked by tag around a ring. A line indicates all agents sharing a given tag. Colours show strategy types: DS=red, SS=blue, DD=yellow, SD=green. Note: in-group selectors and ethnicities not shown
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

The Ethno-Cultural Tag artificial society model (ECT) is a variation of cooperation producing tag models.

Full details can be found at: http://cfpm.org/discussionpapers/152
(by Nov. 2015)

Ethnocentrism denotes behaviour and beliefs that are positive towards those who share the same ethnicity and negative towards others. The model considers short-term cultural evolution, where agents may interact in a population and do not die or give birth but imitate and innovate their behaviours. While agents retain a fixed ethnicity they have the ability to form and join cultural groups and to change how they define their in-group based on both ethnic and cultural markers (or tags).

Over a range of parameters cultural identity rather than ethnocentrism becomes the dominant way that agents identify their in-group producing high levels of positive interaction both within and between ethnicities.

However, in some circumstances, cultural markers of group preference are supplemented by ethnic markers. In other words, whilst pure ethnocentrism (based only on ethnic identity) is not sustained, groups that discriminate in terms of a combination of cultural and ethnic identities do occur.

In these less common cases, high levels of ethnocentric behaviours evolve and persist – even though the ethnic markers are arbitrary and fixed. Furthermore, cooperative ethnocentric groups do not emerge in the absence of cultural processes. The latter suggests the hypothesis that observed ethnocentrism in observed societies need not be the result of long-term historical processes based upon ethnic markers but could be more dependent upon short run cultural ones.


## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

Agents play a donation game - in which they decide if to unconditionally help another agent (donate) or not (shirk). Donation incurs a cost (parameter) and produces a benefit (parameter) to the receiver. From this agents accumulate a payoff.

The donation rate (dr) is the proportion of games that result in such help. The inter-ethnic donation rate (ie) is the proportion of donations made that are made between agents with different ethnicities.

Agents store a cultural tag, an ethnic marker, a strategy and an in-group selector.
The tag, strategy and selector are culturally learned (evolve) through imitation (replication) and innovation (mutation). Agents imitate those who perform better than themselves in terms of payoff. The ethnic marker is fixed and never changes.

The selector takes one of four values defining the in-group as either: 1) shared ethnic marker (se); 2) shared cultural tag (sc); 3) both (sb) or 4) none (sn). The strategy takes one of four values either: 1) shirk on all (ss); 2) donate to all (dd); 3) donate to in-group, shirk on out-group (ds); 4) shirk on in-group, donate to out-group (sd). Tags take one of number-of-tags (parameter) values.

Agents select game partners within their in-group (with probability GIGB). They select others to imitate (learn from) within their in-group (with probability LIGB). When GIGB = LIGB = 0 then agents interact with the entire population. When GIGB = LIGB = 1 then agents only play games or learn from agents within their in-group (as defined by their current selector).

The model iterates through:

Interaction phase (agents play games with each other)
Imitation phase (agents imitate from those who got higher payoffs than themselves)
Innovation phase (agents probabilistically randomly mutate their tag, strategy and selector)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

Press SETUP to initialise the population. Press "GO" to start the model interations. Press GO again to stop the model.

Statistics are displayed showing the proportion of: donations (dr), inter-ethnic donations (ie) and each of the strategy (ss, sd, ds, dd) and selector (sn, sc, se, sn) types in the population. You can see how they evolve over time.

The grid visualises the agents by putting them on a ring stacked. The position on the ring indicates the agent tag value. The hight of the stack indicates how many agents share the tag (i.e. the size of the cultural group). The colours indicate the strategy type of the agent.

## THINGS TO NOTICE

Either sc or sb selector tend dominate often competing and changing places as dominant in-group selector. Strategy ds tends to dominate meaning agents learn to only donate to their in-group. Tag groups constantly form and decay producing a cooperative ecology of cultural groups.

Notice that pure ethnic in-group selectors (se) rarely gain any signficant hold in the population meaning that agents do not define their in-groups solely with reference to the ethnic marker.

## THINGS TO TRY

Try increasing and reducing the number of agents. How does this effect the dynamics of groups and donation rate (dr)?

Changing the GIGB and LIGB values often produces radically different behaviour. Donation (dr) is highest when GIGB = 1 and LIGB = 0 (meaning play games only with in-group but learn from everyone).

What happens when the number-of-tags is reduced so it's less than the number of agents? Why? Note: you can increase and decrease the number-of-tags while the simulation is running - you don't need to restart the simulation.

Notice also that mutation rates on the tag have to be >> mutation on the strategy to create high cooperation. This is because it allows for cooperative new cultural groups (containing DS agents) to be created more quickly than they are dissolved (due to being invaded by shirkers through innovation of agent strategies).

## EXTENDING THE MODEL

The model could be extended by:

- Changing the game so agents could chose to punish as well as donate or shirk. Punishment would incur both a cost to the punisher and the punished. Would agents learn to punish their out-groups?

- Placing agents in space or network and modify interaction rules to bias interaction towards neighbours

- Incorporating movement / network rewiring to create a dynamic social structure

- Dynamically changing to number of ethnicities in the population through introduction of new agents into the population over time

## RELATED MODELS

Hales, D. (1998) Stereotyping, Groups and Cultural Evolution: A Case of "Second Order Emergence"? In Sichman, J., Conte, R., & Gilbert, N. (Eds.) Multi-Agent Systems and Agent-Based Simulation. Lecture Notes in Artificial Intelligence 1534. Berlin: Springer-Verlag

Hales, D. (2001) Cooperation without memory or space: Tags, groups and the prisoner's dilemma. In S. Moss & P. Davidsson (Eds.), Multi-Agent-Based Simulation, 1979, 157-166.

Hammond, R. & Axelrod, R. (2006). The Evolution of Ethnocentrism. Journal of Conflict Resolution, December 2006, 50: 926-936, doi:10.1177/0022002706293470

See built-in netlogo model library: sample models/social science/ethnocentrism

## CREDITS AND REFERENCES

Full details of the model and results can be found in:

Hales, D. & Edmonds, B. (2015) Culture trumps ethnicity! – Intra-generational cultural evolution and ethnocentrism in an artificial society. Centre for Policy Modelling Discussion Paper CPM 15-226, Manchester, UK. http://cfpm.org/discussionpapers/152
(by Nov. 2015)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
