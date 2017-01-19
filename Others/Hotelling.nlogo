globals
[
  new-node  ;; the last node we created
  time
  time-stop
  previous-time-stop
  tflag
  mouse-clicked       ;; keeps track of click-and-hold
  mouse-double-click  ;; set to true if two mouse clicks are registered in a quarter second
  clicked-turtle      ;; who was clicked on...
  dist
  angle
  x1 x2 y1 y2
  number-rewired
  overlap-max
  iterations
  ;delta-t
  buyer-overlap
  buyer-node
  target-node
  utility
  max-buyer-overlap
  global-patience-max
  stop-flag
  overlap-neighbor
  fascia-neighbor
  buyer-overlap-old
  global-max-n-degree
  global-patience
  g-patience
  awareness
  global-patience-min
  patience-decay
]

breed [nodes node]
breed [buyers buyer]
breed [targets target]

nodes-own [degree n-degree overlap fascia advert-level hub?]
links-own [rewired?]
patches-own [p-overlap p-fascia]
;buyers-own [ global-patience ]


;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;global-patience = numero massimo di goods complessivi che un buyer � disposto a valutare prima dell'acquisto
;local-patience = numero di goods primi vicini di cui, ad ogni step, il buyer � disposto a valutare l'overlap-goods per scegliere il migliore

;1) trasformare l'actual-vector del buyer in un vettore 2-dim aventi per features solo le due coordinate x e y
;2) la dinamica prevede ad ogni step una variazione delta-x o delta-y dell'actual-vector del buyer nella direzione del target
;3) ad ogni step ci si sposta sul bene che ha, nell'ordine, una x o una y pi� vicine all'actual-vector oppure un degree maggiore
;4) ad ogni step si tiene in memoria l'overlap (cio� la [sqrt(2) - distanza]) dei beni visitati
;5) allo scadere della pazienza si sceglie il bene con l'overlap pi� elevato per il calcolo della utility function

to SETUP-DYNAMICS

clear-plot

set iterations 0

set stop-flag false

ask buyers [die]
ask targets [die]

set global-patience-min 100
set patience-decay 0.15

set global-patience-max 100;30;(ln(total_number_of_goods) / patience-decay)

;set delta-t (1 / total_number_of_goods)

ask nodes [ set shape "circle 2" set size nodes-size set color green ]

create-targets 1
[
  let xx 0
  let yy 0
  ask one-of nodes [ set target-node self set xx xcor set yy ycor]
  set shape "target"
  set size 3
  set color red
  setxy xx yy
]

create-buyers 1
[
  let xx 0
  let yy 0
  ask one-of nodes [ set buyer-node self set xx xcor set yy ycor]
  set shape "person"
  set size 4
  setxy xx yy
  set awareness random-float 1
]

ask buyers
[

  set global-patience (global-patience-min + random (global-patience-max - global-patience-min) + 1)
  set g-patience global-patience

  let ttarget one-of targets
  set buyer-overlap calcola-overlap ttarget
  set color red ;scale-color red buyer-overlap 1 int(1 / epsilon)
]

ask nodes [set size nodes-size set hub? false]
ask links [set color yellow]

ask nodes
[
  let ttarget one-of targets
  set overlap calcola-overlap ttarget
  set fascia (int(1 / epsilon) - int(overlap / epsilon)) ;assegno a ciascun nodo la propria fascia
  set degree (count link-neighbors)
  set n-degree degree
  let node1 who
  if (degree > hubs-min-links)
  [
    set size size + 2
    set hub? true
    ask link-neighbors
    [
      if (degree > hubs-min-links)
      [
        let node2 who
        ask link node1 node2 [set color red]
      ]
    ]
  ]
  if (degree > hubs-min-links)
  [
    let calling-node self
    ask nodes with [hub? = true and self != myself]
    [
      if (not link-neighbor? calling-node)  [ create-link-with calling-node [set color red] ]
    ]
  ]
]

ask links with [color = red] [ if (random-float 1 > awareness) [ set color gray ]]

ask patches
[
  let ttarget one-of targets
  set p-overlap calcola-overlap ttarget
  set p-fascia (int(1 / epsilon) - int(p-overlap / epsilon)) ;assegno a ciascuna patch la propria fascia
  set pcolor scale-color gray p-fascia 1 int(1 / epsilon)
]


set global-max-n-degree max [n-degree] of nodes

ask buyer-node [set max-buyer-overlap overlap]  ;set color (green - 3)
set utility calcola-utility

set-current-plot  "Utility Plot"
set-current-plot-pen "buyer-utility"
plotxy iterations utility
set-current-plot-pen "buyer-overlap"
plotxy iterations buyer-overlap


end

to START-DYNAMICS

wait waiting-time

set iterations iterations + 1

let target-neighbor 0
set overlap-neighbor 0
set fascia-neighbor 0
set buyer-overlap-old buyer-overlap
let neighbors-set 0
let ccolor red

ask buyer-node
[
  let calling-node self
  set neighbors-set link-neighbors with [color = green and [color] of link-with calling-node != gray]
  ifelse (not any? neighbors-set)
  [
    set size 6 set color green beep set stop-flag true
  ]
  [
    ifelse (count neighbors-set = 1)
    [
       ask buyers
       [
         set target-neighbor one-of neighbors-set
         set ccolor yellow
       ]
    ]
    [
       let min-n-fascia min [fascia] of neighbors-set
       let neighbors-with-min-fascia neighbors-set with [fascia = min-n-fascia]
       ifelse (count neighbors-with-min-fascia = 1)
       [
         set target-neighbor one-of neighbors-with-min-fascia
         set ccolor orange
       ]
       [
         ifelse (g-patience < (2 * count neighbors-with-min-fascia))
         [
           set target-neighbor one-of neighbors-with-min-fascia
           set ccolor green
         ]
         [
           let norm-fascia (min-n-fascia / int(1 / epsilon))
           let norm-patience (g-patience / global-patience)
           let norm-prob ((norm-fascia + norm-patience) / 2)
           ifelse (random-float 1 < norm-prob)
           [
             let max-n-degree max [n-degree] of neighbors-with-min-fascia
             let neighbors-with-max-n-degree neighbors-with-min-fascia with [n-degree = max-n-degree]
             set target-neighbor one-of neighbors-with-max-n-degree
             set g-patience (g-patience - count neighbors-with-min-fascia)
             set ccolor magenta
           ]
           [
             set target-neighbor one-of neighbors-with-min-fascia
             set ccolor cyan
           ]
         ]
       ]
    ]
   let xx 0
   let yy 0
   ask target-neighbor [set overlap-neighbor overlap set fascia-neighbor fascia]
   set buyer-node target-neighbor
   ask buyer-node [set xx xcor set yy ycor]
   ask buyers [set color ccolor setxy xx yy]
   ask target-neighbor
   [
     set n-degree n-degree - 1
     if (n-degree = 0) [set color (green - 3)]
   ]
   set buyer-overlap overlap-neighbor
   ;set color scale-color red buyer-overlap 1 int(1 / epsilon)
   if (buyer-overlap > max-buyer-overlap) [set max-buyer-overlap buyer-overlap]
   set utility calcola-utility
   if (utility < 0) [set utility 0]
  ]

]

ask buyers [if (any? targets in-radius 1)
[set size 10 set color green beep set stop-flag true]]

set-current-plot-pen "buyer-utility"
plotxy iterations utility
set-current-plot-pen "buyer-overlap"
plotxy iterations buyer-overlap

set g-patience (g-patience - 1)
if (g-patience = 0)
[ask buyers [set size 6 set color green beep set stop-flag true]]

if stop-flag [stop]

end

to-report calcola-utility

;report max-buyer-overlap / (patience-decay * (iterations + 1))
;report max-buyer-overlap / exp(patience-decay * iterations)
;report max-buyer-overlap * ((total_number_of_goods - patience-decay * (iterations ^ 2)) / total_number_of_goods)
;report max-buyer-overlap * ((total_number_of_goods - exp(patience-decay * iterations)) / total_number_of_goods)
;ifelse (iterations > 10) [report max-buyer-overlap / (log iterations 10)][report max-buyer-overlap]
report max-buyer-overlap


end

to-report calcola-overlap [ agent2 ]

let distanza 0
set distanza distance agent2
report (1 - (distanza / (sqrt(2) * 100)))

end

to setup

  ca

  set mouse-clicked false
  set mouse-double-click false
  set clicked-turtle nobody

  if (Select-Network = "Random") [ random-network]
  if (Select-Network = "Scale Free with Loops") [scale-free-loops-network]
  if (Select-Network = "Scale Free Tree")  [scale-free-tree-network ]
  if (Select-Network = "Small World Circle") [small-world-network]

  set mouse-clicked false
  set clicked-turtle nobody

end

to random-network

  make-node ;; first node
  let first-node new-node
  loop
  [
;  no-display
  ;; new edge is green, old edges are gray
  ask links [ set color yellow ]
  let partner one-of nodes       ;; find a partner for the new node
  make-node
  make-edge1 new-node partner    ;; connect it to the partner we picked before
  if (count nodes = total_number_of_goods) [stop]
  ]
end

to scale-free-loops-network

  make-node ;; first node
  let first-node new-node
  make-node ;; second node
  let second-node new-node
  ask second-node [
  setxy ([xcor] of first-node) ([ycor] of first-node)
  rt random 360
  fd 10 ]
  make-node ;; third node
  make-edge new-node first-node second-node;; make the edge
  loop
  [
;  no-display
  ;; new edge is green, old edges are gray
  ask links [ set color yellow ]
  let partner1 find-partner       ;; find a partner for the new node
  let partner2 find-partner
  if (partner2 != partner1) [  make-node make-edge new-node partner1 partner2]    ;; connect it to the partner we picked before
  if (count nodes = total_number_of_goods) [stop]
  ]
end

to scale-free-tree-network

  make-node ;; first node
  let first-node new-node
  make-node ;; second node
  make-edge1 new-node first-node ;; make the edge
  loop
  [
  no-display
  ;; new edge is green, old edges are gray
  ask links [ set color yellow ]
  let partner find-partner       ;; find a partner for the new node
  make-node                      ;; add the new node
  make-edge1 new-node partner     ;; connect it to the partner we picked before
  layout
  display
  if (count nodes = total_number_of_goods) [stop]
  ]
end

to small-world-network
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks

  create-ordered-nodes total_number_of_goods
  [
    setxy 50 50
    set color yellow
    set size nodes-size
    ;; they will form a circle
    fd 40
  ]

    ;; we need to find initial values for lattice
  let n 0
  while [n < count nodes]
  [
    ;; make edges with the next two neighbors
    ;; this makes a lattice with average degree of 4
    make-edge2 node n
              node ((n + 1) mod count nodes)
    make-edge2 node n
              node ((n + 2) mod count nodes)
    set n n + 1
  ]

    set number-rewired 0
    ask links
   [
      set rewired? true
      without-interruption [
        ;; whether to rewire it or not?
        if (random-float 1) < SW-rewiring-probability ;rewiring-probability
        [
          ;; "a" remains the same
          let node1 end1
          ;; if "a" is not connected to everybody
          if [ count link-neighbors ] of end1 < (count nodes - 1)
          [
            ;; find a node distinct from node1 and not already a neighbor of node1
            let node2 one-of nodes with[ (self != node1) and (not link-neighbor? node1) ]
            ;; rewire the edge
            rewire node2
          ]
        ]
      ]
    ]

end

;; connects the two nodes
to make-edge2 [node1 node2]
  ask node1 [ create-link-with node2  [
    set rewired? false
  ] ]
end


to rewire [new-b]
  ;; remove "a" from "b"'s neighbor list and vice versa
  let a end1
  let b end2
  ask a [ create-link-with new-b [ set color yellow  set rewired? true ] ]
  ask a [ ask link-with b [die]]
end


to move-node
    ;; detects a single mouse click
    if not mouse-clicked and mouse-down?
    [
       ;; detects if this single mouse click is soon after another
       ifelse timer <= .25
       [  set mouse-double-click true ]
       [  set mouse-double-click false]

       ;; everytime the mouse is clicked, the timer starts
       reset-timer

       set mouse-clicked true

       ;; if there are turtles at the current mouse location, then pick one
       ;; this if statement keeps the program from having problems if
       ;; you click on an empty patch
       ask patch round mouse-xcor round mouse-ycor
       [  if any? nodes-on (patches in-radius round(nodes-size / 2))
          [set clicked-turtle one-of nodes-on (patches in-radius round(nodes-size / 2))]
       ]
    ]

    ;; if a turtle is only clicked, then it moves to match the mouse
    if is-agent? clicked-turtle and not mouse-double-click
    [  ask clicked-turtle
       [ setxy mouse-xcor mouse-ycor ]
    ]


    ;; if a turtle has been double clicked
    if is-agent? clicked-turtle and mouse-double-click
    [ ; wait .15
       ;; this is to give time for mouse-down? to reset
       ;; this is important because user-message can interrupt mouse-down?
       ;; and cause it to not reset to false
       ask clicked-turtle [user-message (word "degree:" (count link-neighbors))]
       reset-timer
       set mouse-double-click false
       set clicked-turtle nobody
    ]


    ;; detects raising the mouse button
    if mouse-clicked and not mouse-down?
    [  set mouse-clicked false
       if is-agent? clicked-turtle
       [ set clicked-turtle nobody]
    ]
end

to shift-all
 ;; detects a single mouse click
    if not mouse-clicked and mouse-down?
    [
       reset-timer ; everytime the mouse is clicked, the timer starts
       set mouse-clicked true
       set x1 mouse-xcor
       set y1 mouse-ycor
       ask nodes [set heading 0]
    ]

    ;; detects raising the mouse button
    if mouse-clicked and not mouse-down?
    [  set mouse-clicked false
       set x2 mouse-xcor
       set y2 mouse-ycor
       set dist sqrt((x2 - x1) ^ 2  + (y2 - y1) ^ 2 )
       set angle atan (x2 - x1) (y2 - y1)
       ask nodes [ set heading angle fd dist ]
       ask buyers
       [
         set heading towards buyer-node
         let dd distance buyer-node
         fd dd
       ]
       ask targets
       [
         set heading towards target-node
         let dd distance target-node
         fd dd
       ]
    ]
end


;; used for creating a new node
to make-node
  create-nodes 1
  [
    setxy 50 50
    set color yellow
    set size nodes-size
    set new-node self ;; set the new-node global
  ]
end


;; This code is borrowed from Lottery Example, from the Code Examples
;; section of the Models Library.
;; The idea behind the code is a bit tricky to understand.
;; Basically we take the sum of the degrees (number of connections)
;; of the nodes, and that's how many "tickets" we have in our lottery.
;; Then we pick a random "ticket" (a random number).  Then we step
;; through the nodes to figure out which node holds the winning ticket.
to-report find-partner
  let total random-float sum [count link-neighbors] of nodes
  let partner nobody
  ;; reporter procedures always run without interruption,
  ;; so we don't need "without-interruption" in order to
  ;; make the turtles go one at a time
  ask nodes
  [
    let nc count link-neighbors
    ;; if there's no winner yet...
    if partner = nobody
    [
      ifelse nc > total
        [ set partner self ]
        [ set total total - nc ]
    ]
  ]
  report partner
end

;;;;;;;;;;;;;;;;;;;;;;;
;;; Edge Operations ;;;
;;;;;;;;;;;;;;;;;;;;;;;

;; connects the two nodes
to make-edge [node1 node2 node3]
  ask node1 [
    create-link-with node2 [ set color yellow ]
    ;; position the new node near its partner
;    setxy (xcor-of node2) (ycor-of node2)
;    rt random 360
;    fd 8
    create-link-with node3 [ set color yellow ]
    setxy ([xcor] of node3) ([ycor] of node3)
    rt random 360
    fd 20
  ]
end

to make-edge1 [node1 node2]
  ask node1 [
    create-link-with node2 [ set color yellow ]
    ;; position the new node near its partner
    setxy ([xcor] of node2) ([ycor] of node2)
    rt random 360
    fd 8
  ]
end

to layout
  ;; the number 3 here is arbitrary; more repetitions slows down the
  ;; model, but too few gives poor layouts
  repeat 5 [
    layout-spring nodes links 0.1 0.1 1
    display  ;; so we get smooth animation
  ]
  ask buyers
  [
    set heading towards buyer-node
    let dd distance buyer-node
    fd dd
  ]
  ask targets
  [
    set heading towards target-node
    let dd distance target-node
    fd dd
  ]
end



;; resize-nodes, change back and forth from size based on degree to a size of 1
to resize-nodes
  ifelse not any? nodes with [size > nodes-size]
  [
    ;; a node is a circle with diameter determined by
    ;; the SIZE variable; using SQRT makes the circle's
    ;; area proportional to its degree
    ask nodes [ set size ((sqrt count link-neighbors) + (nodes-size - 1))]
  ]
  [
    ask nodes [ set size nodes-size ]
  ]
end



to move-nodes
  ask nodes [ set heading random 360 fd 1]
end






to setup-plotting
  set-current-plot "Epidemic expansion"
  set-current-plot-pen "red"
  plot-pen-reset
  set-current-plot-pen "green"
  plot-pen-reset
  set-plot-x-range 0 10
  set-plot-y-range 0 0.1
;  set-plot-y-range  (- screen-edge-y) screen-edge-y
end








@#$#@#$#@
GRAPHICS-WINDOW
486
11
1372
918
-1
-1
8.6733
1
10
1
1
1
0
0
0
1
0
100
0
100
0
0
1
ticks
30.0

MONITOR
369
44
483
89
Number of nodes
count nodes
3
1
11

BUTTON
265
90
408
138
DEGREE RESIZE
resize-nodes
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
6
316
479
576
Utility Plot
iterations
utility
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"buyer-utility" 1.0 0 -16777216 true "" ""
"buyer-overlap" 1.0 0 -2674135 true "" ""

SLIDER
159
10
338
43
total_number_of_goods
total_number_of_goods
0
300
200
10
1
NIL
HORIZONTAL

MONITOR
413
91
480
136
iterations
iterations
0
1
11

SLIDER
265
51
363
84
nodes-size
nodes-size
1
5
1
1
1
NIL
HORIZONTAL

BUTTON
70
104
260
137
1 NODE degree (double-click)
move-node
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
337
10
409
43
LAYOUT
layout
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
25
143
353
161
-------------------------------------------------------------------------------------------------
11
0.0
0

BUTTON
411
10
485
44
MOVE NET
shift-all
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
3
10
156
55
Select-Network
Select-Network
"Random" "Scale Free with Loops" "Scale Free Tree" "Small World Circle"
2

BUTTON
3
57
68
137
SETUP
SETUP\n\n
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
70
64
260
97
SW-rewiring-probability
SW-rewiring-probability
0
0.5
0.14
0.01
1
NIL
HORIZONTAL

BUTTON
3
160
164
258
SETUP DYNAMICS
SETUP-DYNAMICS\n
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
167
160
329
257
START DYNAMICS
START-DYNAMICS
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
361
209
479
254
global-patience
g-patience
0
1
11

MONITOR
365
268
479
313
buyer-utility
utility
3
1
11

MONITOR
6
268
137
313
NIL
buyer-overlap
3
1
11

MONITOR
184
268
315
313
NIL
max-buyer-overlap
3
1
11

MONITOR
337
158
464
203
NIL
global-patience-max
0
1
11

SLIDER
6
587
326
620
epsilon
epsilon
0
0.5
0.04
0.01
1
NIL
HORIZONTAL

MONITOR
365
580
478
625
numero di fasce
int(1 / epsilon)
1
1
11

SLIDER
7
636
326
669
hubs-min-links
hubs-min-links
0
10
9
1
1
NIL
HORIZONTAL

MONITOR
365
630
478
675
NIL
awareness
2
1
11

SLIDER
305
685
478
718
waiting-time
waiting-time
0
1
0.6
0.1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

In some networks, a few "hubs" have lots of connections, while everybody else only has a few.  This model shows one way such networks can arise.

Such networks can be found in a surprisingly large range of real world situations, ranging from the connections between websites to the collaborations between actors.

This model generates these networks by a process of "preferential attachment", in which new network members prefer to make a connection to the more popular existing members.

## HOW IT WORKS

The model starts with two nodes connected by an edge.

At each step, a new node is added.  A new node picks an existing node to connect to randomly, but with some bias.  More specifically, a node's chance of being selected is directly proportional to the number of connections it already has, or its "degree." This is the mechanism which is called "preferential attachment."

## HOW TO USE IT

Pressing the GO ONCE button adds one new node.  To continuously add nodes, press GO.

The LAYOUT? switch controls whether or not the layout procedure is run.  This procedure attempts to move the nodes around to make the structure of the network easier to see.

The PLOT? switch turns off the plots which speeds up the model.

The RESIZE-NODES button will make all of the nodes take on a size representative of their degree distribution.  If you press it again the nodes will return to equal size.

If you want the model to run faster, you can turn off the LAYOUT? and PLOT? switches and/or freeze the view (using the on/off button in the control strip over the view). The LAYOUT? switch has the greatest effect on the speed of the model.

If you have LAYOUT? switched off, and then want the network to have a more appealing layout, press the REDO-LAYOUT button which will run the layout-step procedure until you press the button again. You can press REDO-LAYOUT at any time even if you had LAYOUT? switched on and it will try to make the network easier to see.

## THINGS TO NOTICE

The networks that result from running this model are often called "scale-free" or "power law" networks. These are networks in which the distribution of the number of connections of each node is not a normal distribution -- instead it follows what is a called a power law distribution.  Power law distributions are different from normal distributions in that they do not have a peak at the average, and they are more likely to contain extreme values (see Barabasi 2002 for a further description of the frequency and significance of scale-free networks).  Barabasi originally described this mechanism for creating networks, but there are other mechanisms of creating scale-free networks and so the networks created by the mechanism implemented in this model are referred to as Barabasi scale-free networks.

You can see the degree distribution of the network in this model by looking at the plots. The top plot is a histogram of the degree of each node.  The bottom plot shows the same data, but both axes are on a logarithmic scale.  When degree distribution follows a power law, it appears as a straight line on the log-log plot.  One simple way to think about power laws is that if there is one node with a degree distribution of 1000, then there will be ten nodes with a degree distribution of 100, and 100 nodes with a degree distribution of 10.

## THINGS TO TRY

Let the model run a little while.  How many nodes are "hubs", that is, have many connections?  How many have only a few?  Does some low degree node ever become a hub?  How often?

Turn off the LAYOUT? switch and freeze the view to speed up the model, then allow a large network to form.  What is the shape of the histogram in the top plot?  What do you see in log-log plot? Notice that the log-log plot is only a straight line for a limited range of values.  Why is this?  Does the degree to which the log-log plot resembles a straight line grow as you add more node to the network?

## EXTENDING THE MODEL

Assign an additional attribute to each node.  Make the probability of attachment depend on this new attribute as well as on degree.  (A bias slider could control how much the attribute influences the decision.)

Can the layout algorithm be improved?  Perhaps nodes from different hubs could repel each other more strongly than nodes from the same hub, in order to encourage the hubs to be physically separate in the layout.

## NETWORK CONCEPTS

There are many ways to graphically display networks.  This model uses a common "spring" method where the movement of a node at each time step is the net result of "spring" forces that pulls connected nodes together and repulsion forces that push all the nodes away from each other.  This code is in the layout-step procedure. You can force this code to execute any time by pressing the REDO LAYOUT button, and pressing it again when you are happy with the layout.

## NETLOGO FEATURES

Both nodes and edges are turtles.  Edge turtles have the "line" shape.  The edge turtle's SIZE variable is used to make the edge be the right length.

Lists are used heavily in this model.  Each node maintains a list of its neighboring nodes.

## RELATED MODELS

See other models in the Networks section of the Models Library, such as Giant Component.

See also Network Example, in the Code Examples section.

## CREDITS AND REFERENCES

This model is based on:
Albert-Laszlo Barabasi. Linked: The New Science of Networks, Perseus Publishing, Cambridge, Massachusetts, pages 79-92.

For a more technical treatment, see:
Albert-Laszlo Barabasi & Reka Albert. Emergence of Scaling in Random Networks, Science, Vol 286, Issue 5439, 15 October 1999, pages 509-512.

Barabasi's webpage has additional information at: http://www.nd.edu/~alb/

The layout algorithm is based on the Fruchterman-Reingold layout algorithm.  More information about this algorithm can be obtained at: http://citeseer.ist.psu.edu/fruchterman91graph.html.

For a model similar to the one described in the first extension, please consult:
W. Brian Arthur, "Urban Systems and Historical Path-Dependence", Chapt. 4 in Urban systems and Infrastructure, J. Ausubel and R. Herman (eds.), National Academy of Sciences, Washington, D.C., 1988.

To refer to this model in academic publications, please use:  Wilensky, U. (2005).  NetLogo Preferential Attachment model.  http://ccl.northwestern.edu/netlogo/models/PreferentialAttachment.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

In other publications, please use:  Copyright 2005 Uri Wilensky.  All rights reserved.  See http://ccl.northwestern.edu/netlogo/models/PreferentialAttachment for terms of use.
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
Circle -16777216 true false 0 0 300
Circle -7500403 true true 30 30 240

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

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

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
NetLogo 5.2.1
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
