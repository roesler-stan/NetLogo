;; write Info

globals
[
  MAX-NOISE
  BASE-SIZE
  MAX-COMPANIES
  TURTLE-SPACE
  current-company
  current-company-size
  company-xcor
  company-ycor
  company-x-coords
  company-y-coords
  total-women
  total-men
  percent-women
  womens-links
  mens-links
  mean-womens-links
  mean-mens-links
  max-rank
  min-rank
  max-friends
  min-friends
]

turtles-own
[
  woman?          ;; true if an agent is woman
  my-company      ;; company the turtle belongs to
  random-x        ;; random noise to add to turtle's x coordinate, ranging from -10 to 10
  random-y        ;; random noise to add to turtle's y coordinate, ranging from -10 to 10
  rank            ;; for the page-rank diffusion approach
  new-rank        ;; to calculate page rank
  scaled-page-rank ;; page rank scaled to be between 0 and 1
  scaled-friends  ;; number of friends scaled to be between 0 and 1
  companies-worked ;; number of companies turtle has been a part of
  failed-attempts ;; current number of failed friendship attempts
]


;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;


to make-turtle
  create-turtles 1
  [
    set size BASE-SIZE
    set companies-worked 1
    let this-is-woman random 100 < percent-new-women
    set woman? this-is-woman
    set color ifelse-value this-is-woman [red] [blue]
    set my-company current-company
    set random-x ((random-float (2 * MAX-NOISE)) - MAX-NOISE)
    set random-y ((random-float (2 * MAX-NOISE)) - MAX-NOISE)
    set xcor company-xcor + random-x
    set ycor company-ycor + random-y
    set failed-attempts 0
    set scaled-page-rank 1
    set scaled-friends 1
  ]
end


to update-friends-counts
  set min-friends (min [count my-links] of turtles)
  set max-friends (max [count my-links] of turtles)

  ask turtles [
    ifelse (max-friends - min-friends = 0) [
      set scaled-friends 1
    ] [
    set scaled-friends (((count my-links - min-friends) / (max-friends - min-friends)))
    ]
  ]
end



to make-links
  ask turtles [
    let this-company my-company
    let this-is-woman woman?

    ;; Randomly choose one turtle in same company to be friends
    let made-friend false
    let potential-friend one-of other turtles with [not link-neighbor? myself and (my-company = this-company) ]
    if potential-friend != nobody [
      ask potential-friend [
        if (woman? = this-is-woman and random-float 1 < accept-same) [
          create-link-with myself [ set color ifelse-value (this-is-woman = true) [red] [blue] ]
          set made-friend true
        ]
        if (woman? != this-is-woman and random-float 1 < accept-other) [
          create-link-with myself [set color violet]
          set made-friend true
        ]
      ]
    ]
    if (made-friend = false) [
      set failed-attempts (failed-attempts + 1)
    ]
  ]
end


to make-company
  ;; check that x- and y-coordinates do not overlap with another company's
  let bad-coordinates true
  while [bad-coordinates] [
    set bad-coordinates false
    set company-xcor random-xcor
    set company-ycor random-ycor
    ;; check that the company coordinates + noise will always be within the screen
    while [company-xcor >= (max-pxcor - MAX-NOISE - TURTLE-SPACE) or company-xcor <= (min-pxcor + MAX-NOISE + TURTLE-SPACE) or
        company-ycor >= (max-pycor - MAX-NOISE - TURTLE-SPACE) or company-ycor <= (min-pycor + MAX-NOISE + TURTLE-SPACE)] [
        set company-xcor random-xcor
        set company-ycor random-ycor
    ]
    let index 0
    while [index < length company-x-coords] [
      let other-x (item index company-x-coords)
      let other-y (item index company-y-coords)
      ;; check that the company coordinates do not overlap with any other company's (need 2 *, but giving extra space)
      if (other-x <= company-xcor + (3 * MAX-NOISE) and other-x >= company-xcor - (3 * MAX-NOISE) and
        other-y <= company-ycor + (3 * MAX-NOISE) and other-y >= company-ycor - (3 * MAX-NOISE)) [
        set bad-coordinates true
      ]
      set index (index + 1)
    ]
  ]
  set company-x-coords lput company-xcor company-x-coords
  set company-y-coords lput company-ycor company-y-coords
  repeat company-size [ make-turtle ]
end


to update-page-rank
  let damping-factor 0.85
  ;; Calculate page rank 10 times to reach near-equilibrium
  repeat 10 [
    ask turtles [
      set rank 1 / count turtles
      set new-rank 0
      
      ifelse any? link-neighbors [
        ;; if a node has any links divide current rank equally among them.
        let rank-increment rank / count link-neighbors
        ask link-neighbors [
          set new-rank (new-rank + rank-increment)
        ]
      ]
      [
        ;; if a node has no links divide current rank equally among all the nodes
        let rank-increment rank / (count turtles - 1)
        ask other turtles with [not link-neighbor? myself] [
          set new-rank new-rank + rank-increment
        ]
      ]
    ]
    
    ask turtles [
      ;; set current rank to the new-rank and take the damping-factor into account
      set rank (1 - damping-factor) / count turtles + damping-factor * new-rank
    ]
    
  ]

  set max-rank (max [rank] of turtles)
  set min-rank (min [rank] of turtles)
  ask turtles [
    set scaled-page-rank (((rank - min-rank) / (max-rank - min-rank)))
  ]
end


to calculate-outcomes
  update-friends-counts
  update-page-rank

  set total-women (count turtles with [woman? = true])
  set total-men (count turtles with [woman? = false])
  ifelse count turtles = 0 [set percent-women 0] [set percent-women ((total-women / (count turtles)) * 100)]
  
  set womens-links 0
  ask turtles with [woman? = true] [
    set womens-links (womens-links + count my-links)
  ]
  ifelse total-women = 0 [set mean-womens-links 0] [set mean-womens-links (womens-links / total-women)]

  set mens-links 0
  ask turtles with [woman? = false] [
    set mens-links (mens-links + count my-links)
  ]
  ifelse total-men = 0 [set mean-mens-links 0] [set mean-mens-links (mens-links / total-men)]
end


to replace-turtle
  let this-is-woman random 100 < percent-new-women
  set woman? this-is-woman
  set color ifelse-value this-is-woman [red] [blue]
  ask my-links [ die ]
  set failed-attempts 0
end


;;;;;;;;;;;;;;;;;;;;;;;
;;; Main Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;


to go
  make-links

  ask turtles [
    ;; Replace old turtles by assigning them new gender and dropping links
    ;; If you keep failing to find friends, find another company or leave the industry and be replaced
    if (failed-attempts = max-failed-attempts) [
      ifelse (companies-worked = MAX-COMPANIES) [ replace-turtle ] [
        ;; drop existing links
        ask my-links [die]
        ;; find new company
        let new-company (random companies)
        while [my-company = new-company] [
          set new-company (random companies)
        ]
        set my-company new-company
        set company-xcor (item new-company company-x-coords)
        set company-ycor (item new-company company-y-coords)
        set random-x ((random-float (2 * MAX-NOISE)) - MAX-NOISE)
        set random-y ((random-float (2 * MAX-NOISE)) - MAX-NOISE)
        set xcor company-xcor + random-x
        set ycor company-ycor + random-y
        set size BASE-SIZE
        set failed-attempts 0
        set companies-worked (companies-worked + 1)
      ]
    ]

    ;; Update turtle size
    if (size-by = "none") [
      set size BASE-SIZE
    ]
    if (size-by = "friends") [
      ;;set size BASE-SIZE * scaled-friends
      set size BASE-SIZE * 0.5 * sqrt (count my-links)
    ]
    if (size-by = "page rank") [
      set size BASE-SIZE * sqrt scaled-page-rank
    ]
  ]
  
  if (count turtles < 2) [
    clear-all
    stop
  ]
  calculate-outcomes
  tick
end


to setup
  clear-all
  set-default-shape turtles "person"
  set MAX-COMPANIES 3
  set MAX-NOISE 25
  if (size-by = "none") [ set BASE-SIZE 10 ]
  if (size-by = "friends") [ set BASE-SIZE 10 ]
  if (size-by = "page rank") [ set BASE-SIZE 20 ]
  ;; space to leave around edges of board in case turtles get big
  set TURTLE-SPACE 20

  ;; Create the companies
  set company-x-coords (list)
  set company-y-coords (list)
  set current-company 0
  repeat companies [
    make-company
    set current-company (current-company + 1)
  ]
  set min-friends 0
  set max-friends 0
  set percent-women percent-new-women
  
  reset-ticks
end

;; Adapted from Uri Wilensky (2007).
@#$#@#$#@
GRAPHICS-WINDOW
337
12
888
584
200
200
1.35
1
10
1
1
1
0
1
1
1
-200
200
-200
200
1
1
1
ticks
30.0

BUTTON
8
20
113
53
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
231
20
329
53
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

BUTTON
120
20
225
53
go once
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
11
82
270
115
percent-new-women
percent-new-women
0.0
100.0
30
1.0
1
%
HORIZONTAL

TEXTBOX
13
64
285
82
Percent of incoming employees who are women
11
0.0
1

PLOT
899
10
1239
197
% Industry Female
Time
% Employees
0.0
10.0
0.0
100.0
true
true
"" ""
PENS
"Women" 1.0 0 -2674135 true "" "plotxy ticks (percent-women)"
"Incoming Women" 1.0 0 -7500403 true "" "plotxy ticks percent-new-women"

SLIDER
11
126
210
159
companies
companies
0
10
5
1
1
NIL
HORIZONTAL

SLIDER
12
171
210
204
company-size
company-size
1
60
30
1
1
NIL
HORIZONTAL

SLIDER
13
310
274
343
accept-other
accept-other
0
1
0.2
0.01
1
NIL
HORIZONTAL

TEXTBOX
15
290
325
308
Probability different-gender friendship succeeds
11
0.0
1

TEXTBOX
14
222
320
240
Probability same-gender friendship succeeds
11
0.0
1

SLIDER
12
241
272
274
accept-same
accept-same
0
1
0.7
0.01
1
NIL
HORIZONTAL

PLOT
898
201
1238
409
Total Friendships
Time
Links
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Woman-Woman" 1.0 0 -2674135 true "" "plotxy ticks (count links with [color = red])"
"Man-Man" 1.0 0 -13345367 true "" "plotxy ticks (count links with [color = blue])"
"Woman-Man" 1.0 0 -10141563 true "" "plotxy ticks (count links with [color = violet])"
"Total" 1.0 0 -16777216 true "" "plotxy ticks (count links)"

SLIDER
14
398
272
431
max-failed-attempts
max-failed-attempts
0
20
5
1
1
NIL
HORIZONTAL

TEXTBOX
16
365
329
393
Consecutive unsuccessful friendship attempts before leave company
11
0.0
1

PLOT
897
412
1238
599
Average Friendships
Time
Mean Links
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Women" 1.0 0 -2674135 true "" "plotxy ticks mean-womens-links"
"Men" 1.0 0 -13345367 true "" "plotxy ticks mean-mens-links"

CHOOSER
14
452
106
497
size-by
size-by
"none" "friends" "page rank"
1

@#$#@#$#@
## WHAT IS IT?
This is an abstract model of workplace friendships and satisfaction.  The central questions it addresses is how initial imbalances combine with homophily to shape company dynamics and inequality.

## HOW IT WORKS

At each time step, each person tries to make one friend.  They randomly select a co-worker and ask them to be friends.  Depending on their genders, the friendship succeeds with the probability for same-gender friendships (accept-same) or with that for different-gender friendships (accept-other).

People who fail to make friends with anyone else for max-failed-attemps consecutive attempts switch companies.  If they have already worked at 3 companies, they leave the industry and are replaced by a new employee.

## HOW TO USE IT

First, choose the number and size of companies.  Men and women are distributed randomly across companies, with percent-new-women of them being women, and the rest being men.

Click the SETUP button to build the world.  Click GO ONCE to go one time step.  Click GO to indefinitely observe employee behavior.

### Parameters
**percent-new-women**: the proportion of incoming employees who are women.  Every time a new employee joins, they are this percent likely to be a woman.
**companies**: the number of companies.
**company-size**: the number of people in each company.
**accept-same** probability that an attempted same-gender friendship succeeds.
**accept-other** probability that an attempted different-gender friendship succeeds.
**max-failed-attemps** consecutive failed friendship attempts before a person switches companies. If they have already worked at 3 companies, they leave the industry and are replaced by a new employee.

### Visualization Controls
**size-by**: size nodes by their page rank, number of friends, or neither.

### Plots
- % Industry Female: the percentage of employees in the industry who are women over time.

- Total Friendships: counts of different types of friendships.

- Average friendships: men and women's average number of friends over time.

## THINGS TO TRY

Vary the parameters and observe how many and what types of links form.  See how employee turnover changes.  Do you ever observe gender segregation across companies?

I am particularly struck by how few woman-woman links there are when women are not in the majority.

Also notice how the percentage of industry employees who are women is continually replenished by incoming employees, dipping down and then returning to about percent-new-women.  Imagine how quickly this would fall if the percentage of new employees that are female was impacted by the percentage of current employees who are female (e.g., because people look up to role models).

## POSSIBLE EXTENSIONS
You could have employees switch companies if they have many fewer friends than their co-workers, or if their moving average number of failures dips below a certain threshold.


## CREDITS AND REFERENCES

The code is loosely adapted from the team assembly model developed by Guimera et al. (2005) and Bashky and Wilensky (2007).

Bakshy, E. and Wilensky, U. 2007.  NetLogo Team Assembly model.  http://ccl.northwestern.edu/netlogo/models/TeamAssembly.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Guimera, R., Uzzi B., Spiro, J., Amaral, L. 2005. Team Assembly Mechanisms Determine Collaboration Network Structure and Team Performance. Science V308, N5722, p697-702  
http://amaral.northwestern.edu/Publications/Papers/Guimera-2005-Science-308-697.pdf


## HOW TO CITE

If you mention this model in a publication, we ask that you include these citations for the model itself and for the NetLogo software:

* Roesler, K. 2017. Industry Gender Dynamics. http://netlogoweb.org/web?https://raw.githubusercontent.com/roesler-stan/NetLogo/master/gender_industry.nlogo.

* Wilensky, U. 1999. NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2017 Katharina Roesler.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Katharina Roesler at katroesler@gmail.com.
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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
set layout? false
setup repeat 175 [ go ]
repeat 35 [ layout ]
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
