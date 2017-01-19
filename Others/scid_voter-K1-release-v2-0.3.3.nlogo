extensions [table array]

;; the active agents
breed [people person]

;; passive placeholders no active rules for links etc.
breed [schools school]
breed [workplaces workplace]
breed [activity1-places activity1-place]
breed [activity2-places activity2-place]
;; unused at moment
breed [party-hqs party-hq]

;; NEW link types introduced 
undirected-link-breed [school-friendships school-friendship]
undirected-link-breed [workplace-friendships workplace-friendship]
undirected-link-breed [activity1-friendships activity1-friendship]
undirected-link-breed [activity2-friendships activity2-friendship]
undirected-link-breed [neighbour-friendships neighbour-friendship]
undirected-link-breed [family-relationships family-relationship]

undirected-link-breed [school-memberships school-membership]
undirected-link-breed [workplace-memberships workplace-membership]
undirected-link-breed [activity1-memberships activity1-membership]
undirected-link-breed [activity2-memberships activity2-membership]

;; unused at moment
undirected-link-breed [party-memberships party-membership]

links-own [usage]

globals [
  colour-list colour-list-kinds num-colours lightness time-per-tick sub-year-tick
  endorsements plotted-ends parties party-labels election-dates election-data election-results election-result-list election-result election? prob-time-less
  year month week month-name months electorate last-election-year last-election-month last-election-week first-vote? plot-int election-freq election-local? end-tick
  long-campaign? short-campaign? start-short-campaign? campaign? election-tick-num ticks-to-year-end num-mb-influenced num-cascade-influenced
  num-intention-influenced-mb-all sum-intention-increased-mb-all num-intention-influenced-p2p-all sum-intention-increased-p2p-all 
  num-intention-influenced-mb-grey sum-intention-increased-mb-grey num-intention-influenced-p2p-grey sum-intention-increased-p2p-grey
  num-short-campaign-messages num-long-campaign-messages
  ethnicities ethnicity-shapes 
  greynum popnum
  patch-types patch-proportions patch-colours num-patch-types
  sample-households sample-immigrant-households sample-nonimmigrant-households sample-majority-households sample-minority-households
  op classes show-FOF? watch-list dhl shhl
  grid-size pop-size num-voting num-would-vote turnout av-age sd-age av-hsize sd-hsize av-adfriends sd-adfriends prop-maj prop-adult prop-1stgen prop-2ndgen
  prop-vis-min prop-inv-min prop-nonempty-n prop-sim-n prop-sim-fr turnout-maj turnout-min turnout-imm turnout-nonimm
  av-clust-coeff link-dens num-isolates av-clust av-fr-samevote av-hh-samevote av-fr-whvoted av-hh-whvoted num-watched
  red-voters blue-voters yellow-voters no-voters drift-ip drift-nip opposition-parties after-setup? discussion-stat-list
  num-adult-involved num-adult-interested num-adult-view-taking num-adult-noticing num-adult-not-noticing 
  num-voting-for-civic-duty num-voting-for-generalised-habit num-voting-for-involved num-voting-for-satisfied-and-interested num-voting-for-satisfied-and-party-habit 
  num-voting-for-party-mobilisation first-election-after-mobilisation-start? first-election-after-100-finished? num-available-for-mobilisation
  num-dragged-to-vote-by-partner num-dragged-to-vote-by-interested-family num-dragged-to-vote-by-friend num-dragged-to-vote-by-civic-dutiful-or-involved-family 
  num-voting-for-dragging num-voting-for-rational-considerations num-voting-for-generalised-habit-main num-voting-for-party-mobilisation-main 
  num-voting-for-dragging-main num-voting-for-rational-considerations-main num-voting-for-civic-duty-main
  stats-filename sn-filename run-id num-mobilised-voting num-mobilised-not-voting
  turnout-18-21 turnout-22-30 turnout-31-45 turnout-46-65 turnout-66-75 turnout-76+ 
  num-with-0-friends num-with-1-5-friends num-with-6-10-friends num-with-11+friends 
  move-reasons occuring-move-reasons num-discussions num-talked av-num-disc-disp
  cum-num-mob-withgrey cum-num-mob-withoutgrey cum-num-mob-voted-withgrey cum-num-mob-voted-withoutgrey num-voting-withgrey num-voting-withoutgrey
  pop-adults pop-just-imm num-cd num-cd-base num-cd-imm imm-1stgen-size imm-2ndgen-size
  ]

people-own [bhid id age ethnicity partner my-talking-endorsements my-satisfaction-endorsements my-other-endorsements politics last-household 
            last-moved last-action children older-relations parents init-data employed? last-lost-job intention-prob voted? voted-last-time? voted-for init-activity-list 
            year-last-child immigrant-gen just-imm class moved-out? ill? num-my-children post-18-edu? switched-ever? switched-this-year? last-politics 
            dom-parent-class last-civic-duty? civic-duty? interest-level party-habit? gen-habit? last-voted-for num-conseq-voted num-conseq-voted-same 
            num-conseq-not-voted last-voting-reasons main-voting-reason confounding-factors dragged-by mobilised? move-reason mob-num num-disc
            num-disc-to num-disc-from was-confounded? aquired-cd lost-cd origin
            ]
patches-own [patch-type history contacted?]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Initialisation procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to a-a-INITIALISATION-PROCS end

  ;; Initialise the simulation, making initial households, patches and agents from BHPS file

to setup 
  set-patch-size 480 / world-size
  resize-world 0 (world-size - 1) 0 (world-size - 1)
  clear-all
  file-close-all
  set run-id random 99999999
  set after-setup? false
  show (word "Start at: "numeric-date-and-time)
  
  ;;  set trace? true
  tv "trace" trace?
  
  set-default-shape people "circle" 
  set-default-shape schools "flower"
  set-default-shape workplaces "truck"
  set-default-shape activity1-places "x"
  set-default-shape activity2-places "target"
  
;;  set colour-list [red green orange sky brown magenta blue yellow violet lime pink turquoise cyan]
  set colour-list remove grey remove black base-colors
;;  set colour-list shuffle append append colour-list (map [? + 3] colour-list) (map [? - 3] colour-list)
  set num-colours length colour-list
  set lightness -3
  
  ;; fundamental meaning of constants
  set endorsements ["talk-about-politics-with" "voted" "satisfied-by-not-voting" "dissatisfied-by-not-voting" "satisfied-by-voting"  
    "dissatisfied-by-voting"  "got-post-18-edu" "starts-noticing-politics" "some-discussion-in-home" "lots-discussion-in-home" 
    "someone-talking-about-politics"]
  set plotted-ends endorsements
  set parties [red blue yellow grey]
  set party-labels ["red" "blue" "yellow" "grey"]
  set ethnicities ["majority" "visible-minority" "invisible-minority"]
  set ethnicity-shapes ["circle" "triangle" "circle 2" "pentagon"]
  set months ["jan" "feb" "mar" "apr" "may" "jun" "jul" "aug" "sep" "oct" "nov" "dec"]
  set move-reasons ["" "immigration" "from uk" "it being born" "due to being orphaned and moved to an older relation" 
    "moving with adults" "moving with adult" "moving with partner" "moving to an empty home" "moving back to last household after separation" 
    "moving to an new place with other adults after seperation" "moving to a new empty place after seperation"]
  set occuring-move-reasons []
  
  ;; patch types, colours and proportions
  set patch-types ["school" "workplace" "activity1" "activity2" "household"]
  set num-patch-types length patch-types
  set patch-proportions map [? * 2.26 * density] [.005 .015 0.0075 0.005 .4]
  set patch-colours (list (green + lightness) (brown + lightness) (magenta + lightness) (violet + lightness) (grey + lightness))
  
  ;; internal headings of information read in from BHPS data, these are mapped onto BHPS headings and content
  set shhl ["id" "hid" "age" "partnered?" "num-my-children" "num-children-in-household" "list-of-child-ages" 
            "sex" "race" "raw-party" "party-mem" "party-tend" "voted-in-last?" "int-pol" "religous-act?" "sports-act?" "mem-civic-org?" "employed?"
            "imm-gen" "class-num" "par-class-num" "degree?" "interest-level" "preference-strength" "init-party-habit" "init-gen-habit"]
  
  ;; elections are each: year, month-number, turnout, and a list of % votes for each party, plus closeness of election?
  ;; only used when election results are NOT determined by endogenous voting
  set election-data [[1945 0 red] [1950 0 red] [1951 0 blue] [1955 0 blue] [1964 0 red] [1966 0 red] [1970 0 blue] 
    [1974 0 red] [1974 6 red] [1979 0 blue] [1983 0 blue] [1987 0 blue] [1992 0 blue] [1997 0 red] [2001 0 red] [2005 0 red] [2010 0 blue]]
  set election? false
  set election-freq 5
  set campaign? false
  set prob-time-less 0
  set election-local? true
  set end-tick ticks-per-year - 1
;;  ifelse election-local?
;;    [set election-dates map [(list ? ((12 / ticks-per-year) * (random ticks-per-year)))] 
;;        make-election-dates election-freq prob-time-less start-date end-date] 
;;    [set election-dates map [(list first ? second ?)] election-data]
  set election-dates map [list ? 0] make-election-dates 1 0 0 201
  tv "election-dates" election-dates
  set election-results map [third ?] election-data
  set first-vote? true
  set drift-ip 0
  set drift-nip 0
  set discussion-stat-list []
  set opposition-parties []
  set first-election-after-mobilisation-start? false
  set first-election-after-100-finished? false
  clear-usage
 
  ;; stuff affecting the display
  set show-FOF? true
  set watch-list []
  set num-watched 1
  set num-available-for-mobilisation no-turtles
  
  read-data
  
  ;; initialise patchesinitialise-patch-to this-patch-type
  initialise-patches
    
  ;; initialise people and links including setting up some initial network links
  ask people [init-person-at-start]
  ;;  ask patches [initialise-links]
  
  repeat init-network-loop [ask people [network-changes-init]]
  

  
  calc-output-variables  
  if checking-on? [checking-stuff]
      
  ;; initialise and do initial plots
;;  init-voting-plot
  plot-friendship-dist
  plot-household-dist
  plot-age-dist
  if show-FOF? [plot-fof-dist]
  set watch-list sort min-n-of num-watched people [age]

  set after-setup? true
  
  if to-file? [
    set stats-filename (word "Voter model stats - " output-filename ".csv")
    init-stats-file
  ]

  reset-ticks
end

to check-no-class
 let no-class people with [class = 0]
 if any? no-class [error (word one-of no-class " has class 0")]
end

to initialise-patches
 ;; make a list of all patches then initialise each in turn to work place, household etc.
  let patch-list shuffle sort patches
  foreach seq 0 (num-patch-types - 1) 1 [
    let this-patch-type item ? patch-types
    let num-this-patch-type max list 1 round ((max-pxcor + 1) * (max-pycor + 1) * (item ? patch-proportions))
    repeat num-this-patch-type [
      if empty? patch-list [stop]
      ask first patch-list [initialise-patch-to this-patch-type true  majority-prop "initialisation"]
      set patch-list but-first patch-list
    ]
  ]  
  ;; initialise patches that are left to empty households
  foreach patch-list [
    ask ? [initialise-patch-to "empty" true majority-prop "empty"]
  ] 
  ;; move households around so as to cluster them more like-with-like
  let prob-move init-move-prob
  while [prob-move > 1] [
    ask households [move-patch-init]
    set prob-move prob-move - 1
  ]
  ask households [if prob prob-move [move-patch-init]]
  ask households [
    if not prob (move-prob-mult * 0.5 * (immigration-rate + uk-inflow-rate)) [ask people-here [set last-moved (start-date - 3)]]
  ]
  ask households [update-household]
end

to move-patch-init
  ;; used only in initialise-patches
  let oph max-one-of people-here [age]
  let new-patch nobody
  if oph != nobody [
    set new-patch min-one-of empty-households [disimilarity-around-to oph self]
    if new-patch != nobody [ask people-here [do-move new-patch ""]]
  ]
end

to init-agent
  ;; initialise an agent in a null state before rules import stuff from parents etc.
  ;; null values for a new agent, just introduced into the simulation
  ;;
  ;; age ethnicity partner my-endorsements politics last-household last-
  ;;moved last-action children older-relations parents init-data employed? 
  ;;interest voted? voted-for init-activity-list year-last-child immigrant-gen 
  ;;class moved-out? ill? num-my-children post-18-edu? civic-duty? interest-
  ;;level party-habit? gen-habit?
  set age 0
  set ethnicity "majority"
  set partner nobody
  init-ends
  set politics grey
  set last-politics politics
  set last-household nobody
  set last-moved 0
  set-move-reason ""
  rec-last-action "only initiated"
  set children no-turtles
  set older-relations no-turtles
  set parents no-turtles
  set init-data []
  set employed? false
  set intention-prob 0
  set voted? false
  set voted-last-time? false
  set voted-for grey
  set init-activity-list []
  set year-last-child 0
  set immigrant-gen 999
;;  set just-imm false
  set class 0
  set moved-out? false
  set ill? false
  set num-my-children 0
  set post-18-edu? false
  set civic-duty? false
  set last-civic-duty? false
  set interest-level 0
  set party-habit? false
  set gen-habit? false
  set last-voted-for grey
  set num-conseq-voted 0
  set num-conseq-voted-same 0
  set num-conseq-not-voted 0
  set switched-ever? false
  set switched-this-year? false
  set last-voting-reasons []
  set confounding-factors []
  set dragged-by ""
  set mobilised? false
  set mob-num 0
  set aquired-cd false
  set lost-cd false

  show-turtle
end

to-report make-election-dates [freq prless srt en]
  ;; makes a list of elections dates from st to en at with max period freq and prob its less than this prless
  if en <= srt [report []]
  let dec freq
  if prob prless [set dec dec - random freq]
  report fput srt (make-election-dates freq prless (srt + dec) en)
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Simulation Output  ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to a-a-SIMULATION-OUTPUT end

  ;; graphs and output data procedures

to calc-output-variables
  ;; the calculation of some statistics about the simulation that might be output to a file
  set grid-size (max-pxcor + 1) * (max-pycor + 1)
  set pop-size count people
  set num-voting (count people with [age >= 18 and voted?])
  set num-would-vote sum [intention-prob] of adults
  set electorate (count people with [age >= 18])
  set turnout safeDiv num-voting electorate
  set turnout-maj safeDiv (count people with [age >= 18 and voted? and ethnicity = "majority"])  (count people with [age >= 18 and ethnicity = "majority"])
  set turnout-min safeDiv (count people with [age >= 18 and voted? and ethnicity != "majority"])  (count people with [age >= 18 and ethnicity != "majority"])
  set turnout-imm safeDiv (count people with [age >= 18 and voted? and immigrant-gen < 2])  (count people with [age >= 18 and immigrant-gen < 2])
  set turnout-nonimm safeDiv (count people with [age >= 18 and voted? and immigrant-gen >= 2])  (count people with [age >= 18 and immigrant-gen >= 2])
  set av-age safeMean [age] of people
  set sd-age standard-deviation [age] of people
  set av-hsize safeMean [count people-here] of households
  set sd-hsize standard-deviation [count people-here] of households
  set av-adfriends safeMean [count my-friendships] of adults
  set sd-adfriends standard-deviation [count my-friendships] of adults 
  set prop-maj safeDiv (count people with [ethnicity = "majority"]) pop-size
  set prop-inv-min safeDiv (count people with [ethnicity = "invisible-minority"]) pop-size
  set prop-vis-min safeDiv (count people with [ethnicity = "visible-minority"]) pop-size
  set prop-adult safeDiv (count adults) pop-size
  set prop-1stgen safeDiv (count people with [immigrant-gen = 1]) pop-size
  set prop-2ndgen safeDiv (count people with [immigrant-gen = 2]) pop-size
  set prop-nonempty-n safeMean 
    [safeDiv (count neighbors with [patch-type = "household" and any? people-here]) (count neighbors with [patch-type = "household"])] 
     of households
  set prop-sim-n safeMean [safeDiv (count other-people-near with [[ethnicity] of myself = ethnicity]) (count other-people-near)] of people
  set prop-sim-fr safeMean [safeDiv (count friendship-neighbors with [[ethnicity] of myself = ethnicity]) (count friendship-neighbors)] of people
  set link-dens safeDiv (sum [count friendship-neighbors] of people) (count people * (count people - 1))
  set av-clust safeMean [safeDiv 
      (2 * count-links-between friendship-neighbors) 
      (count friendship-neighbors * (count friendship-neighbors - 1))] 
    of (people with [age > 18])
  set num-isolates count adults with [not any? my-discussant-links]
  let adult-friendships friendships with [adult? end1 and adult? end2]
  set av-fr-samevote safeDiv 
    (count (adult-friendships with [[voted-for] of end1 = [voted-for] of end2])) 
    (count adult-friendships)
  set av-fr-whvoted safeDiv
    (count (adult-friendships with [[voted?] of end1 = [voted?] of end2])) 
    (count adult-friendships)
  let adult-family-relationships family-relationships with [adult? end1 and adult? end2]
  set av-hh-samevote safeDiv 
    (count (adult-family-relationships with [[voted-for] of end1 = [voted-for] of end2])) 
    (count adult-family-relationships)
  set av-hh-whvoted safeDiv 
    (count (adult-family-relationships with [[voted?] of end1 = [voted?] of end2])) 
    (count adult-family-relationships)  
  set red-voters count people with [voted-for = red] 
  set blue-voters count people with [voted-for = blue] 
  set yellow-voters count people with [voted-for = yellow] 
  set no-voters count people with [not voted?]
  ;; new for paper/presentation
  set num-adult-involved count adults with [politically-involved]
  set num-adult-interested count adults with [politically-interested]
  set num-adult-view-taking count adults with [politically-view-taking]
  set num-adult-noticing count adults with [politically-noticing]
  set num-adult-not-noticing count adults with [not politically-noticing]
  
  set num-voting-for-civic-duty count adults with [member? "civic duty" last-voting-reasons]
  set num-voting-for-generalised-habit count adults with [member? "generalised habit" last-voting-reasons]
;;  set num-voting-for-involved count adults with [member? "involved" last-voting-reasons]
;;  set num-voting-for-satisfied-and-interested count adults with [member? "satisfied and interested" last-voting-reasons]
;;  set num-voting-for-satisfied-and-party-habit count adults with [member? "satisfied and party habit" last-voting-reasons]
  set num-voting-for-party-mobilisation count adults with [member? "mobilised by party" last-voting-reasons]
  set num-voting-for-dragging count adults with [member? "dragged" last-voting-reasons]
  set num-voting-for-rational-considerations count adults with [member? "rational" last-voting-reasons]
  
  set num-voting-for-civic-duty-main count adults with [main-voting-reason = "civic duty"]
  set num-voting-for-generalised-habit-main count adults with [main-voting-reason = "generalised habit"]
  set num-voting-for-party-mobilisation-main count adults with [main-voting-reason = "mobilised by party"]
  set num-voting-for-dragging-main count adults with [main-voting-reason = "dragged"]
  set num-voting-for-rational-considerations-main count adults with [main-voting-reason = "rational"]
  
  set num-dragged-to-vote-by-partner count adults with [dragged-by = "partner"]
  set num-dragged-to-vote-by-interested-family count adults with [dragged-by = "politically interested family"]
  set num-dragged-to-vote-by-friend count adults with [dragged-by = "friend"]
  set num-dragged-to-vote-by-civic-dutiful-or-involved-family count adults with [dragged-by = "civicly dutiful or involved family"]
  
  set turnout-18-21 safeDiv (count people with [voted? and age >= 18 and age <= 21]) (count people with [age >= 18 and age <= 21])
  set turnout-22-30 safeDiv (count people with [voted? and age >= 22 and age <= 30]) (count people with [age >= 22 and age <= 30])
  set turnout-31-45 safeDiv (count people with [voted? and age >= 31 and age <= 45]) (count people with [age >= 31 and age <= 45])
  set turnout-46-65 safeDiv (count people with [voted? and age >= 46 and age <= 65]) (count people with [age >= 46 and age <= 65])
  set turnout-66-75 safeDiv (count people with [voted? and age >= 66 and age <= 75]) (count people with [age >= 66 and age <= 75])
  set turnout-76+ safeDiv (count people with [voted? and age >= 76]) (count people with [age >= 76])
  
  set num-with-0-friends count adults with [count friendship-neighbors = 0]
  set num-with-1-5-friends count adults with [count friendship-neighbors >= 1 and count friendship-neighbors <= 5]
  set num-with-6-10-friends count adults with [count friendship-neighbors >= 6 and count friendship-neighbors <= 10]
  set num-with-11+friends count adults with [count friendship-neighbors >= 11]
  
  set num-mb-influenced count adults with [mob-num = 1]
  set num-cascade-influenced count adults with [mob-num > 1]
  
  set pop-adults count adults
  set pop-just-imm count adults with [just-imm]
  set num-cd (count adults with [civic-duty?]) 
  set num-cd-base (count adults with [immigrant-gen > 1 and civic-duty?]) 
  set num-cd-imm (count adults with [immigrant-gen = 1 and civic-duty?]) 
  set imm-1stgen-size (count adults with [immigrant-gen = 1])
  set imm-2ndgen-size (count adults with [immigrant-gen = 2])
end

to init-stats-file
  if file-exists? stats-filename [stop]
  file-open stats-filename
  file-write-list ["run-id" "ticks" "year" "month" "week" "long-campaign?" "short-campaign?" "election-tick-num" "ticks-to-year-end" "election?" "mobilisation-rate" 
    "p2p-influence?" "habit-on?" "no-rat-voting?" "greys-vote?" "homophily?"
    "influence-rate" "household-drag?" "pop-size" "imm-1stgen-size" "imm-2ndgen-size"
    "world-size" "fof-prob" "make-link-mult" "drop-link-mult" 
    "electorate" "num-voting" "num-would-vote" "turnout" "turnout-maj" "turnout-min" "turnout-imm" "turnout-nonimm" "av-age" "sd-age" "av-hsize" 
    "sd-hsize" "av-adfriends" "sd-adfriends" "prop-maj" "prop-inv-min" "prop-vis-min" "prop-adult" "prop-1stgen" "prop-2ndgen" "prop-nonempty-n" 
    "prop-sim-n" "prop-sim-fr" "link-dens" "av-clust" "av-fr-samevote" "av-fr-whvoted" "av-hh-samevote" "av-hh-whvoted" "red-voters" "blue-voters" 
    "yellow-voters" "no-voters" "num-adult-involved" "num-adult-interested" "num-adult-view-taking" "num-adult-noticing" "num-adult-not-noticing" 
    "num-voting-for-civic-duty" "num-voting-for-generalised-habit" 
    "num-voting-for-dragging" "num-voting-for-rational-considerations" "num-voting-for-civic-duty-main" 
    "num-voting-for-generalised-habit-main" "num-voting-for-dragging-main" 
    "num-voting-for-rational-considerations-main" "num-dragged-to-vote-by-partner" 
    "num-dragged-to-vote-by-interested-family" "num-dragged-to-vote-by-friend" "num-dragged-to-vote-by-civic-dutiful-or-involved-family" 
    "turnout-18-21" "turnout-22-30" "turnout-31-45" "turnout-46-65" "turnout-66-75" 
    "turnout-76+""num-with-0-friends" "num-with-1-5-friends" "num-with-6-10-friends" "num-with-11+friends"
    "num-mb-influenced" "num-cascade-influenced" "pop-adults" "pop-just-imm" "num-cd"
    ] ", "
  file-close
end

to stats-to-file
  file-open stats-filename
  file-write-list (list run-id ticks year month week long-campaign? short-campaign? election-tick-num ticks-to-year-end election? (prob-contacted * contact-mult)  
    p2p-influence? habit-on? no-rat-voting? greys-vote? homophily?
    influence-rate household-drag? pop-size imm-1stgen-size imm-2ndgen-size
    world-size fof-prob make-link-mult drop-link-mult  
    electorate num-voting num-would-vote turnout turnout-maj turnout-min turnout-imm turnout-nonimm av-age sd-age av-hsize sd-hsize av-adfriends sd-adfriends 
    prop-maj prop-inv-min prop-vis-min prop-adult prop-1stgen prop-2ndgen prop-nonempty-n prop-sim-n prop-sim-fr link-dens av-clust av-fr-samevote 
    av-fr-whvoted av-hh-samevote av-hh-whvoted red-voters blue-voters yellow-voters no-voters num-adult-involved num-adult-interested 
    num-adult-view-taking num-adult-noticing num-adult-not-noticing num-voting-for-civic-duty num-voting-for-generalised-habit 
    num-voting-for-dragging num-voting-for-rational-considerations num-voting-for-civic-duty-main 
    num-voting-for-generalised-habit-main num-voting-for-dragging-main 
    num-voting-for-rational-considerations-main num-dragged-to-vote-by-partner num-dragged-to-vote-by-interested-family num-dragged-to-vote-by-friend 
    num-dragged-to-vote-by-civic-dutiful-or-involved-family turnout-18-21 turnout-22-30 
    turnout-31-45  turnout-46-65  turnout-66-75 turnout-76+  num-with-0-friends  num-with-1-5-friends  num-with-6-10-friends  num-with-11+friends
    num-mb-influenced num-cascade-influenced pop-adults pop-just-imm num-cd) ", "
  file-close
end

to sn-to-file
  output-social-network (word "Voter model - " output-filename " @" ticks "-" behaviorspace-run-number "-" numeric-date-and-time)
end

to output-social-network [fn]
  output-vna-social-network fn
end

to output-vna-social-network [fn]
  let sep " "
  let fn1 (word fn ".vna")
  if file-exists? fn1 [file-delete fn1]
  file-open fn1

  file-print "*Node data"
  file-write-list (list "ID" "age" "class" "ethnicity" "immigrant-gen" "voted-for" "interest-level" "adult?") sep
  ask people [file-write-list (list who age class ethnicity immigrant-gen voted-for interest-level (age >= 18)) " "]  

  file-print "*Tie data"
  file-write-list (list "from" "to" "strength" "used?" "kind") sep
  foreach sort discussant-links [
     file-write-list (list ([who] of ([end1] of ?)) ([who] of ([end2] of ?)) (1 + [usage] of ?) ([usage] of ? > 0) ([breed] of ?)) sep
  ]

  file-close 
  clear-usage
end

to output-ucinet-social-network [fn]
  let sep " "
  let fn1 (word fn " - links.txt")
  if file-exists? fn1 [file-delete fn1]
  file-open fn1
  
  let adult-list sort adults
  file-write-list (list "dl n =" (1 + length adult-list) ", format = nodelist1") sep
  file-print "labels:"
  file-write-list map [word "agent" [who] of ?] adult-list ","
  file-print "data: ID1 ID2 type Weight"
  
;;  let ad nobody
;;  foreach adult-list [
;;    set ad ?
;;    file-write-list fput (1 + position ad adult-list) map [1 + position ? adult-list] filter [[age] of ? >= 18] sort ([friendship-neighbors] of ad) sep
;;  ]
  
  foreach sort adult-discussant-links [
     file-write-list (list (1 + position [end1] of ? adult-list) (1 + position [end2] of ? adult-list) ([breed] of ?) ([usage] of ?)) sep
  ]

  file-close
  
  let pfn (word fn " - node attributes.txt")
  if file-exists? pfn [file-delete pfn]
;;  if file-exists? pfn [set pfn (word "node-props-" fn remove ":" date-and-time "-"  behaviorspace-run-number ".csv")]
  file-open pfn
  file-write-list (list "who" "age" "class" "ethnicity" "immigrant-gen" "voted-for") sep
  ask people [file-my-props]  
  file-close 
  clear-usage
end


to file-my-props
  file-write-list (list who age class ethnicity immigrant-gen voted-for) " "
end

to file-op-link-data [lab]
  let lis []
  foreach sort both-ends [
    set lis fput [who] of ? lis
  ]
  file-write-list lput lab lis " "
end

to file-write-list [lis sep]
  while [not empty? lis] [
    file-type first lis
    file-type sep
    set lis but-first lis
  ]
  file-print ""
end

to-report other-people-near
  ;;  all the people in neighbouring patches
  report (other turtle-set [people-here] of neighbors)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; reading and processing data file  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to a-a-INIT-DATA-PROCS end

  ;; read in data from file derived from BHPS

to read-data
  ;; to read in the data from the BHPS sample file and process it 
  file-close-all 
  file-open input-filename
  let raw-data []
  ;; read in list of titles in data file
  set dhl csv-string-to-list file-read-line

  ;; read in first line, initialise data-line
  let line-list csv-string-to-list file-read-line
  let last-f-num 0
  let f-num val-of "bhid" line-list dhl
  let data-line list (val-of "bhhsize" line-list dhl) line-list
    
  while [not file-at-end?] [
    
    ;; read in next line
    set line-list csv-string-to-list file-read-line
    set last-f-num f-num
    set f-num val-of "bhid" line-list dhl
    
    ;  check if this line is still in same family
    ifelse f-num = last-f-num [
      ;; if it is the add it to the data line
      set data-line lput line-list data-line
    ] [
      ;; if its not then data-line is finished, add finished data-line to data
;;      if checking-on? [if not check-nums-in-before-proc data-line [show (word "not right numbers in data before processing: " data-line)]]
      set raw-data fput data-line raw-data
      ;; start a new data-line with it
      set data-line list (val-of "bhhsize" line-list dhl) line-list
    ] 
  ]
  set raw-data fput data-line raw-data
  file-close
;;  if checking-on? [show "**********************************************************************************"]
  
;; each item is a list of size then members 
  set sample-households [] 
  set sample-immigrant-households []
  set sample-nonimmigrant-households []
  set sample-majority-households []
  set sample-minority-households []
  let household [] let members []
  let immigrant 0
  let majority 0
  set popnum 0
  set greynum 0
  let processed-member []
  foreach raw-data [
    set household (list first ?)
    set members but-first ?
    set immigrant false
    set majority true
    foreach members [
      set popnum popnum + 1
      if (member? (val-of "bvote4" ? dhl) ["don't kn" "inapplic" "proxy re" "refused"]) [set greynum greynum + 1]
      ;; (val-of "bvote4" lis dhl) ["labour" "conserva" "lib dem" "don't kn" "green pa" "inapplic" "proxy re" "refused" "scot nat" "other pa"] 
      set processed-member process-member ?
      set household fput processed-member household
      if (val-of "imm-gen" processed-member shhl) < 3 
        [set immigrant true] 
      if (val-of "race" processed-member shhl) != "majority"
        [set majority false]
    ]
;;    if checking-on? [
;;      if not check-nums-in-after-proc reverse household 
;;          [show (word "not right numbers in data after processing: " reverse household)]
;;    ]
    set sample-households fput reverse household sample-households
    ifelse immigrant 
      [set sample-immigrant-households fput reverse household sample-immigrant-households]
      [set sample-nonimmigrant-households fput reverse household sample-nonimmigrant-households]
    ifelse majority
      [set sample-majority-households fput reverse household sample-majority-households]
      [set sample-minority-households fput reverse household sample-minority-households]
  ]
;;  show (word "Num. immigrant households in sample: " length sample-immigrant-households)
;;  show (word "Num. nonimmigrant households in sample: " length sample-nonimmigrant-households)
;;  show (word "Num. majority-only households in sample: " length sample-majority-households)
;;  show (word "Num. households with minorities in sample: " length sample-minority-households)
end

to-report check-nums-in-after-proc [d]
  report first d = (length but-first d + (sum item 6 first but-first d))
end

to-report check-nums-in-before-proc [d]
  report first d = (length but-first d + (sum sublist (first but-first d) 15 19))
end

to-report val-of [head-str data-lis heading-list]
  ;; reports the value of the data -item from the field indicated by the input heading string, to make code easier to read
  let opt -9999
  carefully [
;;    if position head-str heading-list [error (word head-str " not found in " heading-list)]
    set opt item (position head-str heading-list) data-lis
  ]  [
    show (word error-message " with " head-str)
    report -9999
  ]
  report opt
end

to-report my-val-of [head-str]
  ;; same as above but assumes init-data and shhl
  report val-of head-str init-data shhl
end

to-report process-member [lis]
;;  takes a list, a line of data and maps its values to the agent characteristics, i.e. from BHPS heading to variable
  let pol item
     position ( val-of "bvote4" lis dhl) ["labour" "conserva" "lib dem" "don't kn" "green pa" "inapplic" "proxy re" "refused" "scot nat" "other pa" "none" "plaid cy" "other an"] 
     [red blue yellow grey yellow grey grey grey yellow yellow grey yellow grey]
  let eth item
     position ( val-of "race" lis dhl) ["black-af" "black-ca" "indian" "pakistan" "white" "inapplic" "missing" "other et" "black-ot" "chinese" "banglade"]
     ["visible-minority" "visible-minority" "visible-minority" "visible-minority" "majority" "majority" "majority" "visible-minority" "visible-minority" "visible-minority" "visible-minority"]
  if eth = "majority" and member? (val-of "racel" lis dhl) ["white ir" "other wh"] [set eth "invisible-minority"]
  let inter 0
  if (val-of "bvote6" lis dhl) = "very interested" [set inter 3]
  if (val-of "bvote6" lis dhl) = "fairly int" [set inter 2]
  if (val-of "bvote6" lis dhl) = "not very" [set inter 1]
  if pol != grey [set inter inter + 1]
  let my-child-list (list (val-of "bnch02" lis dhl) (val-of "bnch34" lis dhl) (val-of "bnch511" lis dhl) (val-of "bnch1215" lis dhl))
  let imm-gen 0
  ifelse member? (val-of "yr2uk4" lis dhl) ["inapplic" "missing" "proxy re"]
    [set imm-gen 3]
    [ifelse (val-of "yr2uk4" lis dhl) - (val-of "doby" lis dhl) >= 18 [set imm-gen 1] [set imm-gen 2]]
  let class-num class-num-from val-of "resp_sec_5cat_b" lis dhl
  let dom-par-class-num  val-of "parent_sec_5cat_b" lis dhl 
  if dom-par-class-num = 0 or dom-par-class-num = NOBODY [set dom-par-class-num class-num]
  let degree? false
  if (val-of "degree" lis dhl) = 1 [set degree? true]
  let int-label (val-of "bvote6" lis dhl)
  let interest-num 0
  ifelse member? int-label ["proxy re" "missing" "not ment" "innaplic"]
    [ifelse int-label = "inapplic"
       [set interest-num 0]
       [set interest-num random 4]]
    [set interest-num position int-label  ["not at a" "not very" "fairly i" "very int"]]
  if ((val-of "borgma" lis dhl) = "member p") [set interest-num 4]
;;  if interest-num = FALSE [error (word "interest-num = " FALSE ", with int-label=" int-label ", val-of borgma lis dhl=" (val-of "borgma" lis dhl))]
  let pref-strength 0
  if member? (val-of "bvote5" lis dhl) ["very str"] 
    [set pref-strength 1]
  let init-party-habit false
  if (val-of "bvote1" lis dhl = "yes") and (val-of "bvote7" lis dhl = "yes") and (val-of "bvote4" lis dhl = val-of "bvote8" lis dhl)
    [set init-party-habit true]
  let init-gen-habit false
  if (val-of "bvote1" lis dhl = "yes") and (val-of "bvote7" lis dhl = "yes") and prob 0.3 
    [set init-gen-habit true]

  report (list 
     (val-of "pid" lis dhl)  ;; person id
     (val-of "bhid" lis dhl)  ;; household id
     (val-of "bage" lis dhl)  ;; age
     ((val-of "bmastat" lis dhl = "married") or (val-of "bmastat" lis dhl = "living a")) ;; partnered?
     (val-of "bnchild" lis dhl) ;; num my children
     (val-of "bnkids" lis dhl) ;; num children in household
     (list (val-of "bnch02" lis dhl) (val-of "bnch34" lis dhl) (val-of "bnch511" lis dhl) (val-of "bnch1215" lis dhl)) ;; list of hh child ages
     (val-of "bsex" lis dhl) ;; sex, "male" or "female"
     (eth)  ;; ethnicity
     (pol)
     (ifelse-value ((val-of "bvote1" lis dhl) = "yes") [pol] [grey]) ;; strong party affiliation: red, blue, yellow or grey
     (ifelse-value (((val-of "bvote1" lis dhl) = "yes") or ((val-of "bvote2" lis dhl) = "yes")) [pol] [grey])  ;; party inclination
     (val-of "bvote7" lis dhl = "yes") ;; voted in last election?
     (inter)  ;; level of political interest 0 (none significant) 1 (some interest) 2 (very interested)
     ((val-of "borgaf" lis dhl) = "active r") ;; involvemnent in religious group
     ((val-of "borgmj" lis dhl) = "member s") ;; member of sports club    
     (((val-of "borgma" lis dhl) = "member p") or ((val-of "borgmb" lis dhl) = "member t") or ((val-of "borgmg" lis dhl) = "member v"))
     ;; member of civic org
     (member? (val-of "bjbstat" lis dhl) ["employed" "self-emp" "maternit"]);; bjstat self-employed, employed, maternity
     (imm-gen)  ;; immigrant generation 1, 2, >= 3 rest
     (class-num) ;; 5-way classification from resp_sec_5cat_b
     (dom-par-class-num) ;; 5-way clasification of dominant parental class
     (degree?)
     (interest-num)
     (pref-strength)
     (init-party-habit)
     (init-gen-habit)
  )
;; each member a list of: 
;;["id" "hid" "age" "partnered?" "num-my-children" "num-children-in-household" "list-of-child-ages" 
;;            "sex" "race" "raw-party" "party-mem" "party-tend" "voted-in-last?" "int-pol" "religous-act?" "sports-act?" "mem-civic-org?" "employed?"
;;            "imm-gen" "class-num" "par-class-num" "degree?" "interest-level" "preference-strength" "init-party-habit init-gen-habit"]
end

to-report class-num-from [str]
  let cn 0
  ifelse str = NOBODY or str = "inapplic"
    [set cn (1 + random 5)]
    [set cn 1 + position str ["I" "II/IIIa" "IV" "V/VI" "VII/IIIb"]]
  report cn
end


to update-appearence
  ;; updates the turtle appearance for changes in politics, age and ethnicity
  tv "update appearence of" self
  set color politics 
  set size 0.05 + age * 0.5 / 80
  tv "ethnicity" ethnicity
  set shape item (position ethnicity ethnicities) ethnicity-shapes
  show-turtle
end

to initialise-patch-to [kindstr start? maj-prop orig]
  ;; initialises a patch to the kind indicated, most complex case is that of a non-empty household
  set patch-type kindstr
  ifelse patch-type = "empty" 
    [set pcolor item (position "household" patch-types) patch-colours]
    [set pcolor item (position patch-type patch-types) patch-colours]
  if patch-type = "household" or patch-type = "empty" [
    if ((pxcor + pycor) mod 2 = 0) [set pcolor pcolor + 1]
    
    if patch-type = "empty" [set patch-type "household" stop]
    ;; create members of household
    tv "********household*******" self

    ;; pick a random household from either the majority of minority BHPS samples
    let target-data []
    ifelse start? 
      [ifelse prob maj-prop
        [set target-data pick-at-random-from-list sample-majority-households]
        [set target-data pick-at-random-from-list sample-minority-households]
      ]
      [ifelse prob 1
        [set target-data pick-at-random-from-list sample-immigrant-households]
        [set target-data pick-at-random-from-list sample-nonimmigrant-households]
      ]

    tv "target-data" target-data
    rec-hist target-data
    
    let adult-data but-first target-data
    tv "adult-data" adult-data
    let num-adults length adult-data
    tv "num-adults" num-adults
    
    let child-age-list (val-of "list-of-child-ages" (first (sort-by [(val-of "num-my-children" ?1 shhl) > (val-of "num-my-children" ?2 shhl)] adult-data)) shhl)
    tv "child-age-list" child-age-list
    let num-children-in-household sum child-age-list
    tv "num-children-in-household" num-children-in-household
    let num-members num-adults + num-children-in-household
    
    let num-children-hh num-members - num-adults
    let px pxcor let py pycor
    
    ;; create adults
    foreach adult-data [
      sprout-people 1 [
        init-agent 
        move-to myself
        shift-rand
        set-my-characteristics ?
        set origin orig
        tv " adult person" self
      ]
    ]
    
    let adults-here people-here
    
    tv "adults-here" sort adults-here
    
    

    
    fix-partner-relations adults-here
    
    let characteristic-parents characteristic-parents-here adults-here
    tv "characteristic-parents" sort characteristic-parents
    
    ;; create children to age pattern given in BHPS
    
    foreach seq 0 3 1 [
      let num-children item ? child-age-list
      let min-age item ? [0 3 5 12]
      let max-age item ? [2 4 11 15]
      if num-children != "none"
         [repeat num-children [
           sprout-people 1 [
             move-to myself
             shift-rand
             init-agent 
             ;;; child characteristics comes from dominant parent which is first in list
             set-child-characteristics characteristic-parents 
             set age min-age + random (1 + max-age - min-age)
             tv "born child of" sort characteristic-parents
           ]
         ]]
    ]
    
    ;; occasionally in BHPS not all children in household belong to adults there
    if num-children-in-household < num-children-hh [
      let min-age 0
      let max-age 15
      repeat (num-children-hh - num-children-in-household) [
        sprout-people 1 [
          tv "Child intitialised without parent " who
          move-to myself
          shift-rand
          init-agent 
          set-child-characteristics characteristic-parents 
          set age min-age + random (1 + max-age - min-age)
          tv "extra born child of" sort characteristic-parents
        ]
      ]
    ]
    
    fix-parent-relationships adults-here people-here with [age < 16]
    tv "people-here" sort people-here
    update-household

     if checking-on? [check-kids]
  ]
  if patch-type = "school" [sprout-schools 1 [init-place-agent]]
  if patch-type = "workplace" [sprout-workplaces 1 [init-place-agent]]
  if patch-type = "activity1" [sprout-activity1-places 1 [init-place-agent]]
  if patch-type = "activity2" [sprout-activity2-places 1 [init-place-agent]]
end

to maybe-flip-cd [prbn as]
  let target-cd false
  ifelse prbn > 0 
    [set target-cd true]
    [set target-cd false]
  if as != nobody [
    ask as [
      if prob abs prbn 
        [set civic-duty? target-cd]
    ]
  ]
end

to check-kids
  let here self
  if any? (people-here with [age < 16]) and not any? (people-here with [age >= 18]) 
      [error (word "kids without parents or present adults at " self "!!!")]
end

to set-my-characteristics [chars]
;; each member a list of: 
;;["id" "hid" "age" "partne"red?" "num-my-children" "num-children-in-household" "list-of-child-ages" 
;;            "sex" "race" "raw-party" "party-mem" "party-tend" "voted-in-last?" "int-pol" "religous-act?" "sports-act?" "mem-civic-org?" "employed?"
;;            "imm-gen" "class-num" "degree?" "interest-level" "preference-strength" "init-party-habit" "init-gen-habit"]
;;
  ;; person-own:
  ;; age ethnicity partner my-endorsements politics last-household last-moved
  ;; last-action children older-relations parents init-data employed? 
  ;; interest voted? voted-for init-activity-list year-last-child immigrant-gen 
  ;; class moved-out? ill? num-my-children post-18-edu? civic-duty? interest-level
  ;; party-habit? gen-habit?
  set init-data chars
  set bhid my-val-of "hid"
  set id my-val-of "id"
  set age my-val-of "age" 
  if age < 18 [set init-activity-list fput a-school init-activity-list]
  set ethnicity my-val-of "race"
  set politics my-val-of "raw-party" ;; ***********"
  set last-politics politics
  if my-val-of "religous-act?" [set init-activity-list fput an-activity1-place init-activity-list]
  if my-val-of "sports-act?" [set init-activity-list fput an-activity2-place init-activity-list]
  set employed? my-val-of "employed?"
  if employed? [set init-activity-list fput a-workplace init-activity-list]
  set last-lost-job year - 5
  set immigrant-gen my-val-of "imm-gen"
  set just-imm false
  set class my-val-of "class-num"
  ;;; should be from BHPS?
  set dom-parent-class my-val-of "par-class-num"
  ifelse age > 20 
    [set moved-out? true]
    [set moved-out? false]
  set num-my-children my-val-of "num-my-children"
  set post-18-edu? my-val-of "degree?"
;;  if post-18-edu? [put-end (list "got-post-18-edu" year month)]
  set interest-level my-val-of "interest-level"
  ifelse not is-number? interest-level
    [set interest-level 0]
    [if interest-level >= 4 [put-end (list "lots-discussion-in-home" year month)]
      if interest-level >= 3 [put-end (list "some-discussion-in-home" year month)]
        if interest-level >= 1 [put-end (list "starts-noticing-politics" year month)]]
  set parents no-turtles
  set civic-duty? my-val-of "mem-civic-org?"
  set last-civic-duty? civic-duty?
  set children no-turtles
  rec-last-action "initialised"
  set party-habit? my-val-of "init-party-habit"
  set gen-habit? my-val-of "init-gen-habit"
  set mob-num 0
  set aquired-cd false
  set lost-cd false
  update-appearence
end

to fix-partner-relations [ppl]
  ;; for initialisation purposes guess who is whose partner in a patch
  let pot-partners ppl with [my-val-of "partnered?"]
  if count pot-partners > 1
    [ask one-of pot-partners [set-partner-to one-of other pot-partners]]
end

to-report characteristic-parents-here [pl]
  ;; needs to be set with two parents first and all parents added to child
  let spl sort-on [-1 * num-my-children] pl
  tv "sorted pl" spl
  report turtle-set safeSubList spl 0 2
end

to-report mutual-partners? [p1 p2]
  report ([partner] of p1 = p2 and [partner] of p2 = p1)
end

to set-child-characteristics [ch-parents]
  ;; null values already intitiated in init-agent
  set bhid [my-val-of "hid"] of one-of ch-parents
  set id 0
  tv "setting child" who
  tv "characteristic parents" sort ch-parents
  if age > 4 [set init-activity-list fput a-school init-activity-list]
  set ethnicity new-ethnicity [ethnicity] of ch-parents
  if ethnicity = 0 [error (word "Person " who " without an ethnicity. Parents = " sort ch-parents)]
  let d-parent dominant-parent-of ch-parents
  set immigrant-gen 1 + [immigrant-gen] of d-parent
  set just-imm false
  set class [class] of d-parent
  set dom-parent-class class
  rec-last-action "hatched and initialised"
  update-appearence
end

to fix-parent-relationships [adult-set child-set]
  tv "fix-parent-relationships, adult-set" sort adult-set
  tv "fix-parent-relationships, child-set" sort child-set
  let my-child-set empty-as
  ask adult-set [
    parent-with-all self safe-n-of (my-val-of "num-my-children") child-set
  ]
  ask child-set [set older-relations adult-set]
end

to parent-with-all [adlt child-set]
  ask child-set [parent-with adlt self]
end

to parent-with [adlt chld]
  ask adlt 
    [
      add-child chld
      create-family-relationship-with chld [init-link]
     ]
  ask chld [add-parent adlt]
end

to add-parent [psn]
  set parents (turtle-set psn parents)
end

to add-child [psn]
  set children (turtle-set children psn)
end

to init-place-agent
  set color ([pcolor] of patch-here) - lightness
  set size 0.9
  move-to myself
end

to init-person-at-start
;;  if not empty? init-activity-list [show init-activity-list]
  foreach init-activity-list [start-involvement-with ?]
;;  ifelse age > 15 [
;;    if politics != grey [put-end (list "politically-involved" year month) put-end (list "I-am-a-voter" year month) ]
;;    if my-val-of "int-pol" > 2 [put-end (list "politically-interested" year month) put-end (list "I-am-a-voter" year month)]
;;    if prob 0.3 [put-end (list "I-am-a-voter" year month)]
;;    if my-val-of "mem-civic-org?" [put-end (list "civic-duty" year month)]
;;    if prob 0.1 [put-end (list "politically-interested" year month)]
;;  ]  [
;;    if age > 14 and prob 0.1 [put-end (list "politically-interested"year month)]
;;  ]
  update-appearence
  if age > 4 and age < 16 and own-school = nobody [fix-my-school]
end

to fix-schools [as]
  ask as [fix-my-school]
end
  
to fix-my-school
  stop-school
  start-involvement-with a-school
end

to initialise-links 
  ask people-here [
    create-family-relationships-with other people-here [init-link]
    if prob 0.25 [make-friend-with a-similar-neighbour "neighbour"] 
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; soem useful procedures to make code more readable ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report partnered?
  report (partner != nobody)
end

to-report a-school
  ;; there is always at least one school
  report min-one-of schools [distance myself]
end

to-report a-workplace
  ;; there is always at least one workplace but not necessarily more
  ifelse count workplaces < 4
    [report one-of workplaces]
    [report one-of min-n-of 4 workplaces [distance myself]]
end

to-report an-activity1-place
  let me self
  let as activity1-places
  if any? as [report min-one-of as [disimilarity-to-activity me self]]
end
  
to-report an-activity2-place
  ;; pick nearest sport club?
  let me self
  let as activity2-places 
  if any? as 
    [report min-one-of as [disimilarity-to-activity me self]]
end

to-report a-similar-neighbour
  let as people-on neighbors
  ifelse count as < 10
    [report one-of as]
    [report one-of min-n-of 10 as [disimilarity myself]]
end

to make-friend-with [aperson lnkt]
  if aperson != nobody and aperson != self 
    [
      if lnkt = "school" [create-school-friendship-with aperson [init-link]]
      if lnkt = "workplace" [create-workplace-friendship-with aperson [init-link]]
      if lnkt = "activity1" [create-activity1-friendship-with aperson [init-link]]
      if lnkt = "activity2" [create-activity2-friendship-with aperson [init-link]]
      if lnkt = "neighbour" [create-neighbour-friendship-with aperson [init-link]]
    ]
end

to msfl
  ;; maybe show activity link depending on switch
;;  show-link
  ifelse show-friendships? [show-link] [hide-link]
end

to init-link
  ;; making partner links red repsonibility of calling code
  if breed  = school-friendships [msfl set color (col-of "school" + 2)]
  if breed = workplace-friendships [msfl set color (col-of "workplace" + 2)]
  if breed = activity1-friendships [msfl set color (col-of "activity1" + 2)]
  if breed = activity2-friendships [set color (col-of "activity2" + 2)]
  if breed = neighbour-friendships 
    [
      ifelse ([partner] of end1) = end2 and ([partner] of end2) = end1
        [show-link set color red]
        [msfl set color white]
     ]
  if breed = family-relationships  [msfl show-link set color grey]
  if breed = school-memberships [msal set color col-of "school" + 6]
  if breed = workplace-memberships [msal set color col-of "workplace" + 6]
  if breed = activity1-memberships [msal set color col-of "activity1" + 6]
  if breed = activity2-memberships [msal set color col-of "activity2" + 6]
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; stop/start activities ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to stop-school
  let myschool one-of schools with [school-membership-neighbor? myself]
  if myschool != nobody [
    ask link-with myschool [die]]
    if on-watch-list? [output-print (word year ": " self "(aged " [age] of self ") stops going to " myschool)
  ]
  rec-last-action "stopped school"
end

to start-involvement-with [anactivity]
;;  show (word anactivity " with breed " [breed] of anactivity "!!!!")
  if ([breed] of anactivity) = schools [create-school-membership-with anactivity [init-link]]
  if ([breed] of anactivity) = workplaces [create-workplace-membership-with anactivity [init-link]]
  if ([breed] of anactivity) = activity1-places [create-activity1-membership-with anactivity [init-link]]
  if ([breed] of anactivity) = activity2-places [create-activity2-membership-with anactivity [init-link]]    
  if on-watch-list? [output-print (word year ": " self "(aged " [age] of self ") started at " anactivity)]
  rec-last-action (word "started " anactivity)
end

to msal
  ;; maybe show activity link depending on switch
  ifelse show-activity-memb? [show-link] [hide-link]
end

to stop-involvement-with [anactivity]
  ask link-with anactivity [die]
  if on-watch-list? [output-print (word year ": " self "(aged " [age] of self ") stops " anactivity)]
  rec-last-action (word "Stopped " anactivity)
end

to set-color-of [anact]
  ;; to set colour of link same as activity
  set color ([color] of anact) - 1
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; homophily stuff ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to-report disimilarity [oth]
  ;; reports dissimilarity measure between self and agent: oth
  report disimilarity-between self oth
end

to-report disimilarity-over-link [lnk]
  report [disimilarity ([end2] of lnk)] of ([end1] of lnk)
end

to-report disimilarity-between [ag1 ag2]
  if not homophily? [report 1]
  ;;  works out dissimilarity measure between agents
  let age1 0 let age2 0 let politics1 0 let politics2 0 let ethnicity1 "" let ethnicity2 "" let class1 0 let class2 0 let int-lev1 0 let int-lev2 0
  ask ag1 [set age1 age set politics1 politics set ethnicity1 ethnicity set class1 class set int-lev1 interest-level] 
  ask ag2 [set age2 age set politics2 politics set ethnicity2 ethnicity set class2 class set int-lev2 interest-level] 
  report 2 * (abs ((age1 - age2) / (max list 1 (min list age1 age2)))) + 0.5 * diff politics1 politics2 
         + 3 * diff ethnicity1 ethnicity2 + abs (class1 - class2)
;;  report abs (int-lev1 - int-lev2)
end

to-report disimilarity-to-those-on [ag pch]
  report min-disimilarity-to-those-on ag pch
end

to-report min-disimilarity-to-those-on [ag pch]
  ;;  report the disimilarity of the closest person on the patch to the agent: ag
  if not any? people-here [report dissim-of-empty]
  report min map [disimilarity-between ag ?] sort [people-here] of pch
end

to-report mean-disimilarity-to-those-on [ag pch]
  ;;  report the disimilarity of the closest person on the patch to the agent: ag
  if not any? people-here [report dissim-of-empty]
  report mean map [disimilarity-between ag ?] sort [people-here] of pch
end

to-report disimilarity-around [pch]
  ;; reports the average disimilarity-to-those-on surrounding patches to pch
  let lis map [disimilarity-to-those-on myself ?] sort (([neighbors] of pch) with [count people-here > 0])
  ifelse empty? lis [report dissim-of-empty] [report mean lis]
end

to-report disimilarity-around-to [ag pch]
  ;; reports the average disimilarity-to-those-on surrounding patches to pch
  let lis map [disimilarity-to-those-on ag ?] sort (([neighbors] of pch) with [count people-here > 0])
  ifelse empty? lis [report dissim-of-empty] [report mean lis]
end


to-report diff [v1 v2]
  ;; used in homophily functions
  ifelse v1 = v2 [report 0] [report 1]
end

to shift-rand
  ;; shifts the displayed position of the agents slightly to make more of them visible in world
  set xcor xcor + rand-offset
  set ycor ycor + rand-offset
end

to-report rand-offset
  report min list 0.375 max list -0.375 (random-normal 0 0.1333)
end

;;;;;;;;;;;;;;;;;
;;; Main loop ;;;
;;;;;;;;;;;;;;;;;

to go
  reset-timer
  calc-date
  if year > end-date [show (word "End at: "numeric-date-and-time) stop]
  
  set num-intention-influenced-p2p-all 0
  set sum-intention-increased-p2p-all 0
  set num-intention-influenced-mb-all 0
  set sum-intention-increased-mb-all 0
  set num-intention-influenced-p2p-grey 0
  set sum-intention-increased-p2p-grey 0
  set num-intention-influenced-mb-grey 0
  set sum-intention-increased-mb-grey 0
  set num-short-campaign-messages 0
  set num-long-campaign-messages 0  
  set long-campaign? false
  set short-campaign? false
  if week = 0 [
    set cum-num-mob-withgrey 0
    set cum-num-mob-withoutgrey 0
    set cum-num-mob-voted-withgrey 0
    set cum-num-mob-voted-withoutgrey 0
    set num-voting-withgrey 0
    set num-voting-withoutgrey 0 
    set sub-year-tick 0
  ]
  if week > 0 [set sub-year-tick sub-year-tick + 1]
  
  set election-tick-num 0
  set start-short-campaign? false
  set ticks-to-year-end (end-tick - sub-year-tick)
  
  set election? sub-year-tick >= end-tick and ((safeModEquals (year + 1) major-election-period 0) or (safeModEquals (year + 1) minor-election-period 0))
  
  if (safeModEquals (year + 1) minor-election-period 0) and ticks-to-year-end < minor-election-length 
    [set short-campaign? true
     set long-campaign? true 
     if ticks-to-year-end <= minor-election-length [set start-short-campaign? true]
     set election-tick-num minor-election-length - ticks-to-year-end]
  if election? and not short-campaign? [set start-short-campaign? true]
  if (safeModEquals (year + 1) major-election-period 0) and ticks-to-year-end < major-election-length
    [set long-campaign? true 
     set election-tick-num major-election-length - ticks-to-year-end]
  if (safeModEquals (year + 1) major-election-period 0) and ticks-to-year-end < major-election-short-len
    [set short-campaign? true
     if ticks-to-year-end <= major-election-short-len [set start-short-campaign? true]]
    
  set campaign? short-campaign? or long-campaign?
     
  set discussion-stat-list []
  if week = 0 [ask people [update-status-and-age]]

  set drift-ip ((random 3) - 1) / 100
  set drift-nip ((random 3) - 1) / 100
  
  if week = 0 [ask people [
      set move-reason ""
      set mob-num 0
      set intention-prob 0
      set mobilised? false
    ]
    ask households [set contacted? false]
  ]
  
  ask activity-memberships [ifelse show-activity-memb? [show-link] [hide-link]]
  ask friendships [ifelse show-friendships? [show-link] [hide-link]]
  

  immigration
  emmigration
  
  ask households [
    birth-death 
  ]
  
  ask people [
    update-appearence
    set num-disc-to 0
    set num-disc-from 0
    set was-confounded? false
    set aquired-cd false
    set lost-cd false
  ]
  if week = 0 [ask people [forgetting]]  ;;; only occasional forgetting!
  ask people [network-changes]
  ask people with [age >= 16 and (not partnered?)] [maybe-partner]
  ask people with [partnered?] [maybe-separate]
  ask people with [age >= 18] [maybe-move]

  ;; smoother influence function
  let num-infl-int floor (influence-rate / ticks-per-year)
  let num-infl-dec ((influence-rate / ticks-per-year) - num-infl-int)
  ask people [
    if prob num-infl-dec [influence-normally]
  ]
  repeat num-infl-int
     [ask people [influence-normally]]
     
;;  ask people [forgetting]
     
  ask people [consolidate-each-tick]
  if week = 0 [ask people [consolidate-each-year]]
  drift-process
  if week = 0 [ask people [check-politics]]
  
  if start-short-campaign? [
    ask adults [
      set main-voting-reason ""
      set last-voting-reasons []
      init-intention-prob
    ]
  ]
  
  if long-campaign? or short-campaign? [
    repeat contact-mult [long-campaign-intervention]
  ]
  
  if election? [
    
    ask people [
      set dragged-by "" 
    ]
    
    ask people with [age >= 18] [
      determine-whether-to-vote       
    ]
    
    ask people with [voted? and age >= 18] [
      drag-others
    ]
    ask people with [voted? and age >= 18] [
      voting-process
    ]
    
;;     if election is using local mode then result decided by votes in the region ow. the results imposed in the list

    set election-result-list map [count adults with [voted? and voted-for = ?] ] parties
    set election-result item (position (max election-result-list) election-result-list) parties 

    set cum-num-mob-voted-withoutgrey count adults with [mobilised? and voted? and not (politics = grey)]
    set cum-num-mob-voted-withgrey count adults with [mobilised? and voted?]
    
    set opposition-parties remove grey remove election-result parties
    ask people [voting-feedback]
    if election? [voting-plots]
    set first-vote? false
  ]

  if checking-on? [checking-stuff]
  
  ask people [update-civic-duty]
  
  set num-discussions length discussion-stat-list
  set num-talked count adults with [num-disc > 0]
  set av-num-disc-disp (mean [num-disc-to] of adults) * ticks-per-year / 52
  
  if when-calc-data? > 0 and (ticks + 1) mod when-calc-data? = 0 [
    plot-friendship-dist
    plot-household-dist
    plot-age-dist
    if show-FOF? [plot-fof-dist]
    calc-output-variables
    if to-file? [stats-to-file]
    if sna-out? [sn-to-file]
  ;;  if month-name = "jan" and member? year [1950 1980 2010] [ç (word "social net" year)]
  ;;  plot-ends
  ]
  tick
  set time-per-tick timer
end

to checking-stuff
  ;;; check there is nobody without a class
  check-no-class
  ;;; check no abandoned children
  let gh (households with [any? (people-here with [age < 16]) and not any? (people-here with [age >= 16])])
  if any? gh [error (word "Patch " one-of gh " with abandoned kids!!")]
  ;;; check no asymetrical partnerships
  ask people with [partnered?] [if ([partner] of partner != self) [error (word "Aysmetric partnership " self " and " partner "!!!")]]
  ask people [if is-list? parents [error (word self " has list of parents: " parents "!!!")]]
  ask patches [check-kids]
  ask people [if age < 16 and moved-out? [error (word self " has moved-out? set but has age " age "!!!")]]
  ask patches [
    ask people-here [
      ask other people-here [
        if not family-relationship-neighbor? myself
          [inspect self error (word self " and " myself " are both in same patch but not related!" )]
      ]
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; update stuff ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-status-and-age
  ;; happens once a year week 0
  set age age + 1
  if age = 5 [start-involvement-with a-school]
  if age = 18 [stop-school]
  if age = 20 [set post-18-edu? have-deg? class]   
  if age = 35 
    [set class new-class class post-18-edu?
     change-class-of-kids-at-home]
  if age = 65 [stop-employment]
end

to-report status
  if age < 5 [report "baby"]
  if age >= 5 and age < 18 [report "child"]
  if age >= 18 and age <= 65 [report "adult"]
  if age > 65 [report "retired"]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; movement stuff ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to immigration
  if sub-year-tick > 0 [stop]
  ask people [set just-imm false]
  let as empty-as
  let n-im floor (immigration-rate * pop-size)
  let c-im n-im
  while [c-im > 1 and n-im > 1] [
    set c-im c-im - 1
    set as patches with [patch-type = "household" and not any? people-here]
    if any? as [
      ask one-of as [
        initialise-patch-to "household" false majority-prop "external immigration"
        set n-im n-im - count people-here
        tv "a household immigrates!" true
        update-household
        if on-watch-list? [output-print (word year ": patch " self " with people " sort people-here " immigrated into country")]
        ask people-here [rec-last-action (word "Immigrated into country") set last-moved year set-move-reason "immigration"]
        ask people-here [set just-imm true]
        ask people-here [set immigrant-gen 1]
      ]
    ]
  ]
  set n-im floor (uk-inflow-rate * pop-size)
  set c-im n-im
  while [c-im > 1 and n-im > 1] [
    set c-im c-im - 1
    set as patches with [patch-type = "household" and not any? people-here]
    if any? as [
      ask one-of as [
        initialise-patch-to "household" true majority-prop "internal immigration"
        set n-im n-im - count people-here
        update-household
        if on-watch-list? [output-print (word year ": patch " self " with people " sort people-here " moved here from within country")]
        ask people-here [rec-last-action (word "Immigrated within country") set last-moved year set-move-reason "from uk"]
        ask people-here [set just-imm true] ;; !!!!!!! are internal immigrants base or immigrants ??
        ask people-here [set immigrant-gen 3]
      ]
    ]
  ]
end

to emmigration
  ;; emmigation at moment works per person not household!
  if sub-year-tick > 0 [stop]
  let as empty-as
  let n-em floor (emmigration-rate * pop-size)
  let c-em n-em
  while [c-em > 1 and n-em > 1] [
    set c-em c-em - 1
    set as patches with [patch-type = "household" and any? people-here]
    if any? as [
      ask (one-of as) [
        set n-em n-em - count people-here 
        patch-move-out]
    ]
  ]
end

to patch-move-out
  ask people-here [person-move-out]
end

to person-move-out
  if on-watch-list? [
    output-print (word year ": " self "(aged " [age] of self ") moved out of area.")
    add-another-to-watch-list self
  ]
  clean-die
end

to clean-die
  ask children [set parents parents with [myself != self]]
  die
end

to set-move-reason [rsn]
  if not member? rsn move-reasons [error (word "Set move reason, " rsn " not in official list!")]
  if not member? rsn occuring-move-reasons [set occuring-move-reasons fput rsn occuring-move-reasons]
  set move-reason rsn
end

;;;;;;;;;;;;;;;;;;;;


to-report num-households
  report count patches with [patch-type = "household" and any? people-here]
end

to birth-death
  let poss-parents sort people-here with [age > 14 and age < 46 and partner != nobody and year-last-child < (year)] 
  while [not empty? poss-parents] [
    ask first poss-parents [
      if prob per-tick birth-prob age [birth]
      set poss-parents but-first poss-parents
      if partner != nobody [set poss-parents remove partner poss-parents]
    ]
  ]
  ask people-here[
    if prob per-tick ill-prob age [set ill? true]
  ]
  ask people-here [
    if prob per-tick death-prob age [death]
  ]
end
  

to birth
  let birth-patch patch-here
  let child nobody
  let the-parents (turtle-set self [partner] of self)
  if partner != nobody [set parents (turtle-set self partner)]
  hatch-people 1 [
    init-agent
    set child self
    set class [class] of myself
    set immigrant-gen 1 + [immigrant-gen] of myself
    do-move birth-patch "it being born"
    set older-relations (turtle-set myself people-here with [age >= 18 and partner != nobody] [partner] of myself)
    if on-watch-list? [output-print (word year ": born " self " with parent " myself " at " birth-patch)]
    rec-last-action (word "born to " sort the-parents)
    set origin "born"
  ] 
  ask the-parents [
    parent-with self child
    set year-last-child year
  ]
end

to death
  if on-watch-list? [output-print (word year ": " self "(aged " [age] of self ") died at " patch-here)]
  move-orphans would-be-orphans-of-mine
  if checking-on? [if any? people-here with [age < 16] and not any? people-here with [age >= 18] 
                         [error (word patch-here " has kids but no adults!!!")]]
  if on-watch-list? [add-another-to-watch-list self]
  clean-die
end

to-report info
  report (list who age)
end

to-report would-be-orphans-of-mine
  report other people-here with [age < 18 and no-older-relations-here-other-than myself]
end

to-report no-older-relations-here-other-than [pers]
  let here patch-here
  report not any? other older-relations with [self != pers and patch-here = here]
end

to-report orphans-here 
  ifelse any? other people-here with [age >= 18]
    [report empty-as]
    [report other people-here with [age < 18 and partner = nobody]]
end

to move-orphans [as]
  let dying self
  let ph patch-here
  ask as [
    let oor older-relations with [self != dying]
    ifelse any? oor 
      [do-move [patch-here] of one-of oor
        "due to being orphaned and moved to an older relation"]
      [adopt-out-of-area]
  ]
end

to adopt-out-of-area
  if on-watch-list? [output-print (word year ": " self "(aged " [age] of self ") adopted out of the area due to being orphaned with no elder relatives")]  
  if on-watch-list? [add-another-to-watch-list self]
  clean-die
end

to-report households
  report patches with [patch-type = "household"]
end

to-report empty-households
  report households with [not any? people-here]
end

to-report non-empty-households
  report households with [any? people-here]
end

to-report adults
  report people with [age >= 18]
end

to-report over24
  report people with [age > 24]
end

to-report adult? [ag]
  report [age] of ag >= 18
end

to-report schoolchildren
  report people with [age > 4 and age < 18]
end

to-report activity-memberships
  report (link-set school-memberships workplace-memberships activity1-memberships activity2-memberships)
end

to-report friendships
  report (link-set school-friendships workplace-friendships activity1-friendships 
                     activity2-friendships neighbour-friendships)
end

to-report my-friendships
  report (link-set my-school-friendships my-workplace-friendships my-activity1-friendships 
                     my-activity2-friendships my-neighbour-friendships)
end

to-report my-discussant-links
  report (link-set my-family-relationships my-school-friendships my-workplace-friendships my-activity1-friendships 
                     my-activity2-friendships my-neighbour-friendships)
end

to-report discussant-links
  report (link-set family-relationships school-friendships workplace-friendships activity1-friendships 
                     activity2-friendships neighbour-friendships)
end

to-report adult-discussant-links
  report discussant-links with [is-adult? end1 and is-adult? end2]
end

to-report is-adult? [ag]
  report [age] of ag >= 18
end

to-report friendship-neighbors
   report other (turtle-set school-friendship-neighbors workplace-friendship-neighbors activity1-friendship-neighbors 
                      activity2-friendship-neighbors neighbour-friendship-neighbors)
end

to-report friendship-neighbors-without-neighbors
   report other (turtle-set school-friendship-neighbors workplace-friendship-neighbors activity1-friendship-neighbors 
                      activity2-friendship-neighbors)
end

to-report friendship-neighbors-with-household
   report other (turtle-set school-friendship-neighbors workplace-friendship-neighbors activity1-friendship-neighbors 
                      activity2-friendship-neighbors neighbour-friendship-neighbors family-relationship-neighbors)
end

to-report friendship-neighbors-with-household-without-neighbors
   report other (turtle-set school-friendship-neighbors workplace-friendship-neighbors activity1-friendship-neighbors 
                      activity2-friendship-neighbors family-relationship-neighbors)
end

to-report local-neighbours
  report people-on neighbors
end


to network-changes
  ;;  changes to social network
;;  if age > 12 and prob per-tick 0.005 [add-random-friend]
  if age > 14 and prob per-tick (make-link-mult * 0.125) [add-activity-friend]
  if age > 12 and prob per-tick (make-link-mult * fof-prob) [add-friend-of-friend]
  if age > 12 and prob per-tick (make-link-mult * add-near-fr-prob) [add-near-friend]
  if age > 19 and any? (children with [age >= 4]) and prob per-tick (make-link-mult * 0.075) [add-schoolparent-friend]
  maybe-drop-random-friend-per-tick
  if age > 18 and not employed? and prob per-tick (make-link-mult * 0.2) [start-employment]
  if employed? and prob per-tick (drop-link-mult * 0.05) [stop-employment]
  if age > 14 and prob per-tick (make-link-mult * 0.025) [add-new-activity]
  if age > 15 and prob per-tick (drop-link-mult * drop-activity-prob) [drop-an-activity]
end

to network-changes-init
  ;;  changes to social network
;;  if age > 12 and prob 0.005 [add-random-friend]
  if age > 14 and prob (make-link-mult * 0.125) [add-activity-friend]
  if age > 12 and prob (make-link-mult * 0.4) [add-friend-of-friend]
  if age > 12 and prob (make-link-mult * add-near-fr-prob) [add-near-friend]
  if age > 19 and any? (children with [age >= 4]) and prob (make-link-mult * 0.075) [add-schoolparent-friend]
  maybe-drop-random-friend
  if age > 18 and not employed? and prob (make-link-mult * 0.2) [start-employment]
  if employed? and prob (drop-link-mult * 0.05) [stop-employment]
  if age > 14 and prob (make-link-mult * 0.025) [add-new-activity]
  if age > 15 and prob (drop-link-mult * drop-activity-prob) [drop-an-activity]
end
  

to stop-employment
  let emp workplace-membership-neighbors
  if count emp > 0 [
    ask my-workplace-memberships [die]
    if on-watch-list? [output-print (word year ": " self "(aged " [age] of self ") stops work at " one-of emp)]
    rec-last-action (word "Stopped work at " emp)
  ]
  set employed? false
  set last-lost-job year
end

to start-employment
  start-involvement-with a-workplace 
  set employed? true
end

to add-new-activity
  let as (turtle-set activity1-places activity2-places)
  if any? as [start-involvement-with min-one-of as [disimilarity-to-activity myself self]]
end
  
to drop-an-activity
  let an-act max-one-of (turtle-set activity1-membership-neighbors activity2-membership-neighbors) [disimilarity-to-activity myself self]
  if an-act != nobody [ask link-with an-act [die]]
end

to-report disimilarity-to-activity [ag act]
  let as empty-as
  ask act [set as link-neighbors]
  ifelse any? as 
    [report mean [disimilarity ag] of as]
    [report 0]
end

to add-random-friend
  make-friend-with a-similar-from 5 (other people) "other"
end

to add-activity-friend
  let kind random-member ["school" "workplace" "activity1" "activity2"]
  let as no-turtles
  if kind = "school" [set as (other turtle-set [school-membership-neighbors] of school-membership-neighbors)]
  if kind = "workplace" [set as (other turtle-set [workplace-membership-neighbors] of workplace-membership-neighbors)]
  if kind = "activity1" [set as (other turtle-set [activity1-membership-neighbors] of activity1-membership-neighbors)]
  if kind = "activity2" [set as (other turtle-set [activity2-membership-neighbors] of activity2-membership-neighbors)]
  if any? as [make-friend-with a-similar-from 3 as kind]
end


to add-activity1-friend
  let as (other turtle-set [activity1-membership-neighbors] of activity1-membership-neighbors)
  if any? as [make-friend-with a-similar-from 3 as "activity1"]
end

to add-activity2-friend
  let as (other turtle-set [activity2-membership-neighbors] of activity2-membership-neighbors)
  if any? as [make-friend-with a-similar-from 3 as "activity2"]
end

;; school-friendship-neighors workplace-friendship-neighors activity1-friendship-neighors activity2-friendship-neighors 
;; neighbour-friendship-neighors family-relationship-neighors


to add-friend-of-friend
  if not fof? [stop]
  let kind random-member ["school" "workplace" "activity1" "activity2" "family" "neighbour"]
  let as no-turtles
  if kind = "school" [set as (other turtle-set [school-friendship-neighbors] of school-friendship-neighbors)]
  if kind = "workplace" [set as (other turtle-set [workplace-friendship-neighbors] of workplace-friendship-neighbors)]
  if kind = "activity1" [set as (other turtle-set [activity1-friendship-neighbors] of activity1-friendship-neighbors)]
  if kind = "activity2" [set as (other turtle-set [activity2-friendship-neighbors] of activity2-friendship-neighbors)]
  if kind = "family" [set as (other turtle-set [family-relationship-neighbors] of family-relationship-neighbors)]    
  if kind = "neighbour" [set as (other turtle-set [neighbour-friendship-neighbors] of neighbour-friendship-neighbors)]    
  if any? as [make-friend-with a-similar-from 3 as kind]
end

;;to add-friend-of-householder
;;  let as (other turtle-set [friendship-neighbors] of household-membership-neighbors)
;;  if any? as [make-friend-with a-similar-from 3 as "neighbour"]
;;end


to add-schoolparent-friend
  ;;; check this still works with multiple parents
  let as co-school-parents
  if any? as [make-friend-with a-similar-from 3 as "school"]
end

to add-schoolfriend
  let as other co-schoolers turtle-set self
end

to-report co-schoolers [ag-set]
  let as turtle-set [school-membership-neighbors] of ag-set
  report turtle-set remove 0 ([school-membership-neighbors] of as)
end

to-report my-school-fellows
  report co-schoolers turtle-set self
end

to-report co-school-parents
  let as co-schoolers ((turtle-set children) with [age < 16])
  report other turtle-set remove 0 [parents] of as
end

to-report co-members
  report other (turtle-set 
    [school-friendship-neighbors] of school-friendship-neighbors
    [workplace-friendship-neighbors] of workplace-friendship-neighbors
    [activity1-friendship-neighbors] of activity1-friendship-neighbors
    [activity2-friendship-neighbors] of activity2-friendship-neighbors
    )
end

to-report childrens-schools
  report turtle-set [own-school] of children
end

to-report school-of [ag]
  let as (turtle-set [school-membership-neighbors] of ag) 
  ifelse any? as [report one-of as] [report nobody]
end

to-report own-school
  let as (turtle-set school-membership-neighbors)
  ifelse any? as [report one-of as] [report nobody]
end

to add-near-friend
  make-friend-with a-similar-neighbour "neighbour"
end

to drop-random-friend
  if any? my-friendships [ask (one-of my-friendships) [die]]
end

to maybe-drop-random-friend
  ;; needs to be made more context dependent when freindship reasons are marked
  let pr drop-friend-prob
  let nf count friendship-neighbors
  if prob (drop-link-mult * pr * (1.01 ^ nf)) [drop-random-friend]
end

to maybe-drop-random-friend-per-tick
  ;; needs to be made more context dependent when freindship reasons are marked
  let pr drop-friend-prob
  let nf count friendship-neighbors
  if prob per-tick (pr * (1.01 ^ nf)) [drop-random-friend]
end

to-report a-similar-from [size-choice-set as]
  if count as < size-choice-set [report min-one-of as [disimilarity myself]]
  report min-one-of (n-of size-choice-set as) [disimilarity myself]
end

to maybe-partner
  if partnered? [stop]
  let as empty-as
  if prob per-tick prob-partner [
    set as potential-partners
    if any? as [
      let poss-partner a-similar-from 8 as
      partner-with poss-partner
    ]
  ]
end

to-report potential-partners
  ;; potential partners are anyone you have a vague connection with
  report other acquaintances with [age >= 16 and (not partnered?) and not (patch-here = [patch-here] of myself)]
end

to-report acquaintances
  report (turtle-set friendship-neighbors [friendship-neighbors] of friendship-neighbors co-members co-school-parents)
end

to partner-with [p1]
  if checking-on? and (partner != nobody) [error (word self " trying to partner " p1 " when " self " is already partnered to " partner "!!!")]
  if checking-on? and ([partner] of p1 != nobody) [error (word self " trying to partner " p1 " who is already partnered to " [partner] of p1 "!!!")]
  ask p1 [set partner myself]
  set partner p1
  maybe-move-on-partnering p1
  if link-neighbor? p1 [ask link-with p1 [die]]
  create-family-relationship-with p1 [init-link set color red]
  if checking-on? and after-setup? [ask patch-here [check-kids]]
  ;;  show "as a partnership"
  ;;  ask link-with p1 [msfl set color red]
  if on-watch-list? [output-print (word year ": " self "(aged " [age] of self ") partners with " p1 " at " patch-here)]
  rec-last-action (word "I partnered " p1)
  ask p1 [rec-last-action (word "Was partnered with " myself)]
end

to set-partner-to [p1]
  if checking-on? and (partner != nobody) [error (word self " trying to partner " p1 " when " self " is already partnered to " partner "!!!")]
  if checking-on? and ([partner] of p1 != nobody) [error (word self " trying to partner " p1 " who is already partnered to " [partner] of p1 "!!!")]
  ask p1 [set partner myself]
  set partner p1
  if link-neighbor? p1 [ask link-with p1 [die]]
  create-family-relationship-with p1 [init-link set color red]
  if on-watch-list? [output-print (word year ": " self "(aged " [age] of self ") had partner set to " p1 " at " patch-here)]
  rec-last-action (word self " had partner set to " p1)
  ask p1 [rec-last-action (word " had partner set to " myself)]
end

to maybe-move-on-partnering [prt]
  ;; decide on where to move to on partnering if anywhere
  ;; needs thought ZZZ
  if (patch-here = [patch-here] of prt) [stop]
  let here patch-here
  let nph count people-here
  let npt 0
  ask prt [set npt count people-here]
  ifelse nph < 2 [ask prt [move-to-patch here]]
    [ifelse npt < 2 [move-to-patch [patch-here] of prt]
       [move-to-empty-patch]]
end

to maybe-separate
  if partner = nobody [stop]
  if prob per-tick seperate-prob [
    ifelse kids-here?
      [if prob 0.25 [seperate-from partner]]
      [seperate-from partner]
  ]
end

to-report kids-here?
  report any? people-here with [age < 16]
end

to seperate-from [oth]
  let here patch-here
  if on-watch-list? [output-print (word year ": " self "(aged " [age] of self ") seperates from " oth " at " here)]
  while [link-neighbor? oth] [ask link-with oth [die]]
  if link-neighbor? oth [error "link not killed in seperate"]
  set partner nobody
  ask oth [set partner nobody]
  
  let mkh children with [patch-here = here]
  let okh no-turtles
  ask oth [set okh children with [patch-here = here]]
  if count mkh > count okh [ask oth [move-out-dep]]
  if count mkh < count okh [move-out-dep]
  ifelse prob 0.5 
     [ask oth [move-out-dep]]
     [move-out-dep]
  rec-last-action (word "Seperated from " oth)
end


to move-out-dep
  ifelse age < 18 [move-out-u18] [move-out]
end

to move-out-u18
  let ph patch-here
  ifelse last-household != nobody and any? (people-on last-household) with [age >= 18]
  [
    move-person-with-kids last-household "moving back to last household after separation"
  ]
  [
    let ps patches with [patch-type = "household" and self != ph and any? people-here with [age >= 18]]
    if any? ps[
      let new-patch one-of ps
      move-person-with-kids new-patch "moving to an new place with other adults after seperation"
    ]
  ]
end

to move-out
  ifelse last-household != nobody and prob per-tick 0.5
  [
    move-person-with-kids last-household "moving back to last household after separation"
  ]
  [
    let ps patches with [patch-type = "household" and not any? people-here]
    if any? ps and age >= 18 [
      let new-patch one-of ps
      move-person-with-kids new-patch "moving to a new empty place after seperation"
    ]
  ]
end

to maybe-move
  ;; calculate probability of moving
  let prb 0
  ifelse prob 0.5 
    [set prb leave-prob-male age]
    [set prb leave-prob-female age]
  if moved-out? [set prb 0.1 * prb]
  let nph count people-here
  if nph > 5 [repeat nph - 5 [set prb 1.2 * prb]]
  set prb move-prob-mult * prb
  if prob per-tick prb [move-to-empty-patch]
end

to move-to-empty-patch
  ;; look for new empty patch either (a) the nearest or (b) with similar neighbours
  let new-patch nobody
  ifelse prob prob-move-near 
    [set new-patch min-one-of empty-households [distance myself]]
    [set new-patch min-one-of empty-households [disimilarity-around self]]
  ifelse new-patch != nobody [move-to-patch new-patch] [tv "No patch to move to" who]
end


to move-to-patch [pch]
  ;; move kids and partner with oneself if have one
  if patch-here = pch [stop]
  move-person-with-kids pch "moving to an empty home"
  if partner != nobody [
    ask partner [
      move-person-with-kids pch "moving with partner"
    ]
  ]
  ask patch-here [
    if not any? (people-here with [age >= 18]) and any? (people-here with [age < 16 or not moved-out?])
       [ask (people-here with [age < 16 or not moved-out?]) [do-move pch "moving with adult"]]
    if checking-on? and after-setup? [check-kids]
  ]
  if checking-on? and after-setup? [ask pch [check-kids]]
  ;; update-household
end

to move-person-with-kids [pch reason]
  ;; move children and un-parented minors with oneself
  ;; REQUIRES THOUGHT A 17 CAN MOVE AND TAKE KIDS FROM PARENTS ZZZ
  tv "move-person-with-kids to " pch
  let here patch-here
  let deps children with [patch-here = here] with [(age < 16 or not moved-out?)]
  if any? people-here with [age < 18 and not moved-out? and member? myself sort older-relations]
    [set deps (turtle-set deps people-here with [age < 18 and not moved-out? and member? myself sort older-relations])]
  if not any? other people-here with [age >= 18]
    [set deps (turtle-set deps people-here with [age < 16])]
  ask deps [do-move pch "moving with adult"]
  do-move pch reason
  if checking-on? and after-setup? [
    ask pch [check-kids]
    ask patch-here [check-kids]
  ]
  tv "finished move-person-with-kids to " pch
end

to do-move [pch reason]
  ;; execute move
  set last-household patch-here
  move-to pch
  shift-rand
  set last-moved year
  set-move-reason reason
  update-appearence
  ask my-neighbour-friendships [if ([patch-here] of other-end != pch) and prob 0.98 [die]]
  ask my-family-relationships [if ([patch-here] of other-end != pch) and prob 0.95 [die]]
  fix-family-relationships
  if on-watch-list? and reason != "" [output-print (word year ": " self "(aged " [age] of self ") moved from " last-household " to " pch " due to " reason)]
  rec-last-action (word "Moved from " last-household " to " pch " due to " reason) ;; set last-moved year
  if age > 4 and age <= 18 [
    ask my-school-friendships [if prob 0.99 [die]]
    fix-my-school
  ]
  ;;; need anything for parents school-friendships?
  if not moved-out? and age >= 18 [
    if not any-reponsible-adults? [
      set moved-out? true
    ]
  ]
end

to-report any-reponsible-adults?
  report 
    any-member? sort parents people-here 
    or
    any-member? sort older-relations people-here
end

to fix-family-relationships
  let oths-here other people-here
  if any? oths-here [
    ask oths-here [
      if not family-relationship-neighbor? myself 
        [create-family-relationship-with myself]
    ]
  ]
end

to update-household
  ;; adjust household links and friendship links
  let old-hm ((turtle-set [family-relationship-neighbors] of people-here)) 
  ask people-here [
    foreach sort old-hm [
      if prob 0.75 and (family-relationship-with ?) != nobody [kill (family-relationship-with ?)]
    ]
  ]
  ask people-here [create-family-relationships-with other people-here [init-link]]
  ;; drop some old friendship links
end

to kill [ag]
  ask ag [die]
end

to-report my-children-here
  let here patch-here
  report children with [patch-here = here]
end

;;;; endorsements ;;;;;;;;;;;
to a-a-ENDORSEMENT-PROCS END

to influence-normally
  ;; politically-view-taking
  let vote-fac 0
  if voted? [set vote-fac 0.05]

  ifelse politically-view-taking and partner != nobody and prob (0.25 + vote-fac)
    [maybe-talk-about-politics-with partner]
    [ifelse politically-interested and partner != nobody and prob (0.45 + vote-fac)
      [maybe-talk-about-politics-with partner]
      [if politically-involved and partner != nobody and prob (0.65 + vote-fac)
        [maybe-talk-about-politics-with partner]]]

  ifelse politically-view-taking and count family-relationship-neighbors > 0 and prob (0.05 + vote-fac)  
    [maybe-talk-about-politics-with family-relationship-neighbors]    
    [ifelse politically-interested and count family-relationship-neighbors > 0 and prob (0.15 + vote-fac) 
      [maybe-talk-about-politics-with  family-relationship-neighbors]
      [if politically-involved and count family-relationship-neighbors > 0 and prob (0.35 + vote-fac)  
        [maybe-talk-about-politics-with  family-relationship-neighbors]]]

  ifelse politically-view-taking and count friendship-neighbors > 0 and prob (0.01 + vote-fac) 
    [maybe-talk-about-politics-with  friendship-neighbors]    
    [ifelse politically-interested and count friendship-neighbors > 0 and prob (0.05 + vote-fac) 
      [maybe-talk-about-politics-with  friendship-neighbors]
      [if politically-involved and count friendship-neighbors > 0 and prob (0.15 + vote-fac) 
        [maybe-talk-about-politics-with  friendship-neighbors]]]

end

to consolidate-each-tick
  ;; rules for start noticing politcs
  ;; ********* changed from 6 3
  ifelse moved-out? [
    if num-background-discussions >= 6 [put-end (list "starts-noticing-politics" year month)]
  ] [
    if num-background-discussions >= 3 [put-end (list "starts-noticing-politics" year month)]
  ]
  ;; effect of discussions on interest ladder
  if not moved-out? [
    if both-parents-interested-enough? [
      if num-remembered-family-discussions >= 4 [put-end (list "some-discussion-in-home" year month)]
      if num-remembered-family-discussions >= 8 [put-end (list "lots-discussion-in-home" year month)]
    ]
  ]
  ;; ZZZ do we want interest levels to only increas?
  set interest-level min-interest-level
;;  set interest-level max list interest-level min-interest-level
  if moved-out? [
    if num-remembered-discussions >= 6 [set interest-level interest-level + 1]
    if num-remembered-discussions >= 3 [set interest-level interest-level + 1]
  ]
  set interest-level min list 4 interest-level
  
  ;; civic duty forgetting stuff
  let ed-fac 1
  if post-18-edu? [set ed-fac 2]
  ;;; ************* changed from 0.02 **********************
  if age >= 25 [
    if prob per-tick (0.01 / ed-fac) [unset-civic-duty]
  ]
end

to consolidate-each-year
  ;; party preference/color aquireing in parental home
  if (age <= 12) and (politics = grey) [
    let parent-list sort parents
    if not empty? parent-list [
      let p1 first parent-list 
      ifelse length parent-list > 1 [
        let p2 second parent-list
        let p1il [interest-level] of p1
        let p2il [interest-level] of p2
        ifelse p1il = p2il [
          if [politics] of p1 = [politics] of p2
            [change-politics-to [politics] of p1 ""]
        ]
        [
          ifelse p1il > p2il
            [change-politics-to [politics] of p1 ""]
            [change-politics-to [politics] of p2 ""]
        ]
      ]
      [
        change-politics-to [politics] of p1 ""
      ]
    ]
  ]
  
  ;; party pref change later
  if age > 12 and politics = grey [
    let propl scaleList num-filtered-coloured-discussions
    ;; returns empty list if not enough discussions etc.
    if not empty? propl [
      let max-val max propl
      let max-pos position max-val propl
      let max-party item max-pos parties
      ifelse not politically-view-taking 
        [if politics != grey [change-politics-to grey "not politically view taking"]]
        [ifelse politics = grey
          [if max propl > 0.5 [change-politics-to max-party ""]]
          [ifelse politically-interested
            [if max propl > 0.9 [change-politics-to max-party ""]]
            [ifelse party-habit?
              [if max propl > 0.8 [change-politics-to max-party ""]]
              [if max propl > 0.6 [change-politics-to max-party ""]]
            ]
          ]
        ]
     ]
  ]  

  ;; party habit change
  if num-conseq-voted-same >= 3  [set party-habit? true]
  if politics = grey  [set party-habit? false]
  
  ;; generalised habit change
  if num-conseq-voted >= 3 [set gen-habit? true]
  if num-conseq-not-voted >= 2 [set gen-habit? false]
end

to drift-process
  ;; drift process per-tick using drift-ip and drift-nip and first-vote?
  if not first-vote? [
    let op1 first opposition-parties
    let op2 second opposition-parties
    ifelse drift-ip > 0
      [ask rand-sample-of drift-ip grey 2 [change-politics-to election-result ""]]
      [ask rand-sample-of drift-ip election-result 2 [change-politics-to grey ""]]
    ifelse drift-nip > 0
      [
         ask rand-sample-of drift-nip grey 2 [change-politics-to op1 ""]
         ask rand-sample-of drift-nip grey 2 [change-politics-to op2 ""]
       ]
      [
         ask rand-sample-of drift-nip op1 2 [change-politics-to grey ""]
         ask rand-sample-of drift-nip op2 2 [change-politics-to grey ""]
       ]
  ]
end

to change-politics-to [prty str]
  set politics prty
  ifelse str = "" 
    [tv "agent changed to: " prty]
    [tv (word "agent changed due to " str "to: ") prty]
end

to check-politics
  ifelse last-politics != politics [
    set switched-this-year? true
    if politics != grey [
      set switched-ever? true
    ]
   set last-politics politics 
  ] [
    set switched-this-year? false
  ]
end

to-report rand-sample-of [prop pol int-lev]
  let allposs adults with [politics = pol and interest-level = int-lev]
  let prb per-tick abs prop
  let numsamp round prb * count allposs
  report n-of numsamp allposs
end

to maybe-increase-civic-duty
  let ed-fac 1
  if post-18-edu?
    [set ed-fac 2] 
  let vote-fac 1
  if voted? [set vote-fac 2]
  ;;;; **************** changed from 0.05 and 0.02 : double last voted **************************
  if age >= 14 [
    if prob (0.25 * ed-fac * vote-fac) [set-civic-duty]
  ]
  if age >= 18 [
    if prob (0.125 * ed-fac * vote-fac) [set-civic-duty]
  ]
end

to unset-civic-duty
  set civic-duty? false
end

to set-civic-duty
  set civic-duty? true
end

to update-civic-duty
  if not last-civic-duty? and civic-duty? [set aquired-cd true]
  if last-civic-duty? and not civic-duty? [set lost-cd true]
  set last-civic-duty? civic-duty?
end


to-report num-filtered-coloured-discussions
  ;; ops a list in order of parties of number of allowed remembered coloured discussions
  let alld all-end-with "talk-about-politics-with"
  let sorted-coloured-discussions sort-by [(item 6 ?1 + 0.01 * item 7 ?1) < (item 6 ?2 + 0.01 * item 7 ?2)] filter [(item 2 ?) != grey] alld
  if length sorted-coloured-discussions < 3 [report []]
  ;; changed from 5 to 3 in the above
  tv "sorted-coloured-discussions" sorted-coloured-discussions
  let dpeople  remove-duplicates map [item 1 ?] sorted-coloured-discussions
  tv "dpeople" dpeople
  let lscd []
  let per-dl []
  let p nobody
  foreach dpeople [
    set p ?
    set per-dl filter [item 1 ? = p] sorted-coloured-discussions
    while [length per-dl > 3] [
      set per-dl but-first per-dl
    ]
    set lscd fput (map [item 2 ?] per-dl) lscd
  ]
  tv "lscd" lscd
  let flscd flatten-once lscd
  tv "flscd" flscd
  let opl []
  let pp 0
  foreach parties [
    set pp ?
    set opl lput length filter [? = pp] flscd opl
  ]
  tv "opl" opl
  report opl
end

to-report num-background-discussions
  report count-end-with "someone-talking-about-politics"
end

to-report num-remembered-discussions
  report count-end-with "talk-about-politics-with"
end

to-report num-remembered-family-discussions
  let rfd all-end-with "talk-about-politics-with"
  report length filter [item 5 ? = family-relationships] rfd
end

to-report num-remembered-nonfamily-discussions
  let rnfd all-end-with "talk-about-politics-with"
  report length filter [item 5 ? != family-relationships] rnfd
end

to-report both-parents-interested-enough?
  if not any? parents [report false]
  if count parents = 1 [report [interest-level] of one-of parents > 1]
  report ([interest-level] of first sort parents > 1) and ([interest-level] of second sort parents > 1)
end

to increase-interest-level
  set interest-level min list 4 interest-level + 1
end

to decrease-interest-level
  set interest-level max list min-interest-level interest-level - 1
end

to-report min-interest-level
  let m1 0
  if any-end-with? "starts-noticing-politics" [set m1 1]
  let m2 0
  if post-18-edu? [set m2 m2 + 1]
  if any-end-with? "some-discussion-in-home" [set m2 m2 + 1]
  if any-end-with? "lots-discussion-in-home" [set m2 m2 + 1]
  report max list m1 m2
end

to-report num-friends-with [endor]
  report count friendship-neighbors with [any-end-with? endor]
end
  
to forgetting
  ;; first param is years that nothing of this kind is forgotten, second is prop per year it is forgotten after that
;;  mm-delete-all-older-than-with 3 0.95
  mm-delete-older-than-with "talk-about-politics-with" talk-about-politics-min talk-about-politics-remb
  mm-delete-older-than-with "someone-talking-about-politics" someone-talk-politics-min someone-talk-politics-remb
;;  mm-delete-older-than-with "starts-noticing-politics" 100 1
  mm-delete-older-than-with "voted" voted-min voted-remb
  mm-delete-older-than-with "satisfied-by-voting" satisfied-min satisfied-remb
  mm-delete-older-than-with "dissatisfied-by-voting" satisfied-min satisfied-remb
  mm-delete-older-than-with "satisfied-by-not-voting" satisfied-min satisfied-remb
  mm-delete-older-than-with "dissatisfied-by-not-voting" satisfied-min satisfied-remb
;;  forgetting gen-habit? after 20 years
end

to maybe-talk-about-politics-with [person]
  if is-agentset? person[set person one-of person]
  ifelse politically-noticing: person [
    talk-about-politics-with person (link-breed self person) false
  ] [
    ask person [put-end (list "someone-talking-about-politics" year month)]
  ]
end
  
to talk-about-politics-with [person network-kind mb?]
  let the-link link-with person
  if exists person [
    let iam-pi politically-involved
    set num-disc-to num-disc-to + 1
    ask person [
      put-end (list
                 "talk-about-politics-with"
                 myself 
                 ([politics] of myself) 
                 ([civic-duty?] of myself)
                 iam-pi
                 network-kind       ;; type of network: school, work, family, neighbour, activity1, activity2, party?
                 year month)
      set num-disc-from num-disc-from + 1
      if ([civic-duty?] of myself) [maybe-increase-civic-duty]
      set discussion-stat-list fput (list ([politics] of myself)  ([civic-duty?] of myself) iam-pi age network-kind) discussion-stat-list
      if the-link != nobody [ask the-link [set usage usage + 1]]
      ;;; intention influence
      if short-campaign? [
        if intention-prob < ([intention-prob] of myself) [
          ifelse politics = [politics] of myself [
            ifelse ([intention-prob] of myself) > 0.75 
              [set intention-prob intention-ch-fn  ([intention-prob] of myself) intention-prob 0.4 mb?]
              [if ([intention-prob] of myself) > 0.5 [set intention-prob intention-ch-fn ([intention-prob] of myself) intention-prob 0.3 mb?]]
          ]  [
            ifelse ([intention-prob] of myself) > 0.75 
              [set intention-prob intention-ch-fn  ([intention-prob] of myself)  intention-prob  0.2  mb?]
              [if ([intention-prob] of myself) > 0.5 [set intention-prob intention-ch-fn ([intention-prob] of myself) intention-prob 0.1 mb?]]
          ]
        ]
      ]
    ]
  ]
end

to-report intention-ch-fn [their-ip my-ip incr mb?]
  let new-ip min list their-ip (my-ip + incr)
  let dif new-ip - my-ip
  if dif > 0 [
    ifelse mb? [
      if mob-num = 0 [
        set mobilised? true
        set mob-num 1     
        set cum-num-mob-withgrey cum-num-mob-withgrey + dif
        set num-intention-influenced-mb-all num-intention-influenced-mb-all + 1
        set sum-intention-increased-mb-all sum-intention-increased-mb-all + dif
        ifelse politics = grey [
          set num-intention-influenced-mb-grey num-intention-influenced-mb-grey + 1
          set sum-intention-increased-mb-grey sum-intention-increased-mb-grey + dif
        ] [
          set cum-num-mob-withoutgrey cum-num-mob-withoutgrey + dif
        ]
      ]
    ]  [
      if (mob-num > 0) and p2p-influence? [
        set mob-num mob-num + 1
        set num-intention-influenced-p2p-all num-intention-influenced-p2p-all + 1
        set sum-intention-increased-p2p-all sum-intention-increased-p2p-all + dif
        if politics = grey [
          set num-intention-influenced-p2p-grey num-intention-influenced-p2p-grey + 1
          set sum-intention-increased-p2p-grey sum-intention-increased-p2p-grey + dif
        ]
      ]
    ]
  ]
  ifelse mb? or p2p-influence? [report new-ip] [report my-ip]
end



to clear-usage
  ask links [set usage 0]
end

to-report politically-noticing
  report (interest-level >= 1)
end

to-report politically-view-taking
  report (interest-level >= 2)
end

to-report politically-interested
  report (interest-level >= 3)
end

to-report politically-involved
   report (interest-level >= 4)
end

to-report only-politically-interested
  report (interest-level = 3)
end

to-report only-politically-view-taking
  report (interest-level = 2)
end

to-report only-politically-noticing
  report (interest-level = 1)
end
 

to-report politically-noticing: [ag]
  report ([interest-level] of ag) >= 1
end

to-report politically-view-taking: [ag]
  report ([interest-level] of ag) >= 2
end

to-report politically-interested: [ag]
  report ([interest-level] of ag) >= 3
end

to-report politically-involved: [ag]
   report ([interest-level] of ag) >= 4
end

;;;;;;;;;;;;  election stuff  ;;;;;;;;;;;;
to a-a-ELECTION-PROCS end

to init-intention-prob
  set intention-prob 0
  set last-voting-reasons []
  set main-voting-reason ""
  let nngdr count-end-with 
         "satisfied-by-voting" + count-end-with "dissatisfied-by-not-voting" 
         - count-end-with "dissatisfied-by-voting" - count-end-with "satisfied-by-not-voting" 
  let satisfied? (nngdr > ((random-float 0.02) - 0.01))
  if civic-duty? [set intention-prob 1 add-last-voting-reason  "civic duty"]
  if habit-on? and gen-habit? [set intention-prob 1 add-last-voting-reason  "generalised habit"]
  if (politics != grey or greys-vote?) and not no-rat-voting? [
    ifelse politically-involved
      [set intention-prob 1 add-last-voting-reason  "rational"]
      [if satisfied?
        [ifelse politically-interested  ;; strong party preference ***
          [set intention-prob 1 add-last-voting-reason  "rational"]
          [if party-habit? [set intention-prob 1 add-last-voting-reason "rational"]  
        ] 
      ]
    ]
  ]
end

to add-last-voting-reason [str]
  set last-voting-reasons fput str last-voting-reasons
  if str = "generalised habit" 
    [set main-voting-reason str]
  if str = "civic duty" and main-voting-reason != "generalised habit" 
    [set main-voting-reason str]
  if str = "rational" and not member? main-voting-reason ["civic duty" "generalised habit"] 
    [set main-voting-reason str]
  if str = "mobilised by party" and not member? main-voting-reason ["civic duty" "generalised habit" "rational"] 
    [set main-voting-reason str]
  if str = "dragged" and not member? main-voting-reason ["civic duty" "generalised habit" "rational" "mobilised by party"] 
    [set main-voting-reason str] 
end

to long-campaign-intervention
  let party-mobiliser nobody
  let target-group adults
  if any? target-group [
    ask target-group [
      ifelse not short-campaign? 
        [set party-mobiliser one-of adults with [politically-involved]]
        [set party-mobiliser one-of adults with [politically-involved and politics = [politics] of myself]]
      if party-mobiliser != nobody [
        ;; note next if not per-tick!
        if prob prob-contacted [
          if not mob-once-ph? or [not contacted?] of patch-here [
            ask party-mobiliser [talk-about-politics-with myself party-memberships true]
            ask patch-here [set contacted? false]
          ]
          ;; add-last-voting-reason "long campaign contacted"
          set num-long-campaign-messages num-long-campaign-messages + 1
          if short-campaign? [set num-short-campaign-messages num-short-campaign-messages + 1]
        ]
      ]
    ]
  ]
end

to determine-whether-to-vote
  ;; finally whether someone will vote or not!
  set dragged-by ""
  set voted-for grey
  set confounding-factors []
  let conf-fact 1
  let pol-involv-fact 1
  if politically-involved [set pol-involv-fact 2]
  let decfact 1
  if year - last-moved < 2 [set decfact decfact * (1 - (0.6 * conf-fact) / pol-involv-fact) add-counfounding-factor "moved recently"]
  if any? children [if [age] of min-one-of children [age] < 1 [set decfact decfact * (1 - (0.4 * conf-fact) / pol-involv-fact) add-counfounding-factor "has baby"]]
  if not employed? and (year - last-lost-job) < 2 [set decfact decfact * (1 - (0.5 * conf-fact) / pol-involv-fact) add-counfounding-factor "unemployed"]
  if prob (0.01  * conf-fact) [set decfact 0 add-counfounding-factor "randomly ill"]
  if ill? [set decfact 0 add-counfounding-factor "old age infirmity"]
  set voted-last-time? voted?
  set voted? false
  if politics != grey or greys-vote? [
    if prob intention-prob [
      ifelse prob decfact [
        set voted? true
      ] [
        set voted? false
        set was-confounded? true
      ]
    ]
  ] 
  rec-last-action (word "Did I vote? " voted?)
  ifelse voted? [
    set last-voted-for voted-for
    set num-conseq-voted num-conseq-voted + 1
    set num-conseq-not-voted 0
  ]
  [
    set num-conseq-voted 0
    set num-conseq-voted-same 0
    set num-conseq-not-voted num-conseq-not-voted + 1
  ]
end


to add-counfounding-factor [str]
  set confounding-factors fput str confounding-factors 
end

to drag-others
  if not household-drag? [stop]
  if prob intention-prob [
  
    if prob 0.95 and politically-involved and partner != nobody 
      [ask partner [set voted? true set dragged-by "partner"]]
    if prob 0.5 and politically-involved and any? family-relationship-neighbors
      [ask one-of family-relationship-neighbors [set voted? true set dragged-by "politically interested family"]]
    if prob 0.20 and politically-involved and any? friendship-neighbors
      [ask one-of friendship-neighbors [set voted? true set dragged-by "friend"]]
    
    if prob 0.5 and only-politically-interested and partner != nobody 
      [ask partner [set voted? true set dragged-by "partner"]]
    if prob 0.25 and only-politically-interested and any? family-relationship-neighbors
      [ask one-of family-relationship-neighbors [set voted? true set dragged-by "politically interested family"]]
    if prob 0.1 and only-politically-interested and any? friendship-neighbors
      [ask one-of friendship-neighbors [set voted? true set dragged-by "friend"]]
      
    if prob 0.35 and not politically-interested and partner != nobody 
      [ask partner [set voted? true set dragged-by "partner"]]
    if prob 0.1 and not politically-interested and any? family-relationship-neighbors
      [ask one-of family-relationship-neighbors [set voted? true set dragged-by "politically interested family"]]
    if prob 0 and not politically-interested and any? friendship-neighbors
      [ask one-of friendship-neighbors [set voted? true set dragged-by "friend"]]
      
    if prob 0.1 and (civic-duty? or politically-involved) and any? family-relationship-neighbors
      [ask one-of family-relationship-neighbors [set voted? true set dragged-by "civicly dutiful or involved family"]]
    rec-last-action (word "Dragged someone to vote")
  ]
end

to voting-process
  
  if dragged-by != "" [
    add-last-voting-reason "dragged"
  ]
    
;;   actual process of going to vot, might include draffing someone else to vote too

  set num-voting-withgrey num-voting-withgrey + 1
  ifelse politics = grey
    [set voted-for pick-at-random-from-list remove grey parties
     ]
    [set voted-for politics
     set num-voting-withoutgrey num-voting-withoutgrey + 1]
;;  put-end (list "voted" voted-for year month)  
  rec-last-action (word "Voted for " voted-for)
  ifelse voted-for = last-voted-for 
    [set num-conseq-voted-same num-conseq-voted-same + 1]
    [set num-conseq-voted-same 0]
  
  if on-watch-list? [
    ifelse voted? 
      [output-print (word year ": " self "(aged " [age] of self ") voted for the " label-of voted-for " party")]
      [output-print (word year ": " self "(aged " [age] of self ") voted for the " label-of voted-for " party")]
  ]
end

to voting-feedback
  if voted? and election-result = voted-for [put-end (list "satisfied-by-voting" year month)]
  if voted? and election-result != voted-for [put-end (list "dissatisfied-by-voting" year month)]
  if not voted? and election-result = voted-for [put-end (list "satisfied-by-not-voting" year month)]
  if not voted? and election-result != voted-for [put-end (list "dissatisfied-by-not-voting" year month)]
end

;;;;;;;;;;;;  input data and other underlying stuff  ;;;;;;;;;;;;
to a-a-DATA-STUFF end

to calc-date
  set year start-date + floor (ticks / ticks-per-year)
  set month (ticks mod ticks-per-year) * 12 / ticks-per-year
  set week (ticks mod ticks-per-year) * 52 / ticks-per-year
  set month-name item month months
end

to-report birth-prob [ag]
  tv word "birth-prob "self ag
  let bp 0.25 * normal-dist ag 20.5 2.5 + 1.7 * normal-dist ag 30 5.5
  let nc count children
  if nc > 4 [set bp  0]
  if nc > 3 [report birth-mult * 0.125 * bp]
  if nc > 2 [report birth-mult * 0.25 * bp]
  if nc > 1 [report birth-mult * 0.75 * bp]
  if nc > 0 [report birth-mult * 1.5 * bp]
  if nc = 0 [report birth-mult * 2 * bp]
end

to-report ill-prob [ag]
  ifelse ag <= 75 [report 0] [report (1 - (0.9 ^ (age - 75)))]
end

to-report death-prob [ag]
  tv word "death-prob "self ag
  if ag > 100 [report 1]
  report item ag [ 0.0072385 0.000601 0.0003505 0.00027 0.0002115 0.000188 0.000183 0.0001645 0.0001615 0.000162 0.000152 0.0001615 
    0.0001715 0.0001965 0.000253 0.000311 0.0003985 0.0005465 0.0006 0.000597 0.0006005 0.0006195 0.000629 0.0006355 0.0006245 
    0.000617 0.000652 0.00064 0.000667 0.00069 0.0006785 0.0007585 0.0007935 0.000805 0.000869 0.00097 0.001038 0.0011275 0.0012415 
    0.001361 0.001393 0.001573 0.001734 0.0018095 0.00202 0.002281 0.0026125 0.002823 0.003143 0.0034855 0.003951 0.0043775 0.004813 
    0.0053155 0.0057885 0.0065615 0.0072775 0.0082185 0.0091035 0.0101265 0.0114135 0.012816 0.014102 0.0158855 0.0177275 0.0197315 
    0.0214385 0.0240655 0.026127 0.028802 0.0309835 0.034017 0.0377685 0.042083 0.0457685 0.0492125 0.0542015 0.059693 0.0653905 
    0.0719955 0.079432 0.0862525 0.0947775 0.103915 0.113735 0.1234415 0.1354525 0.1471135 0.1570765 0.171934 0.1857995 0.200491 
    0.217592 0.235631 0.255039 0.275602 0.2941745 0.308699 0.318437 0.3537675 0.364971]
end

to-report leave-prob-male [ag]
  tv word "leave-prob "self ag
  if ag < 16 [report per-tick 0]
  if ag < 20 [report per-tick 0.034216429]
  if ag < 25 [report per-tick 0.221232747]
  if ag < 30 [report per-tick 0.271762342]
  if ag < 35 [report per-tick 0.136659979]
  if ag < 41 [report per-tick 0.068329989]
  if ag < 46 [report per-tick 0.034164995]
  if ag < 51 [report per-tick 0.017082497]
  report 0
end

to-report leave-prob-female [ag]
  tv word "leave-prob "self ag
  if ag < 16 [report per-tick 0]
  if ag < 20 [report per-tick 0.020629639]
  if ag < 25 [report per-tick 0.141390787]
  if ag < 30 [report per-tick 0.214862178]
  if ag < 35 [report per-tick 0.170393345]
  if ag < 41 [report per-tick 0.085196673]
  if ag < 46 [report per-tick 0.042598336]
  if ag < 51 [report per-tick 0.021299168]
  report 0
end

to-report new-class [old-class edu?]
  let prob-dest []
  ifelse edu? 
    [set prob-dest [
     [29.25        55.44        6.30        4.67         4.34]
     [24.35        53.81        5.95        9.74         6.15]
     [22.75        46.17       12.00       11.72         7.36]
     [19.25        47.39        7.95       17.31         8.10]
     [15.46        50.72        4.78       15.41        13.62]]]
    [set prob-dest [
      [5.74        44.47         8.18       27.40        14.21]
      [4.34        36.80         9.24       31.20        18.42]
      [3.14        25.70        17.38       30.27        23.51]
      [2.74        25.60         7.54       37.81        26.32]
      [2.87        20.60         8.69       39.07        28.76]]]
  report 1 + chooseProbilistically item (old-class - 1) prob-dest
end

to change-class-of-kids-at-home
  ask (children with [not moved-out? and age < 25]) [set class [class] of myself]
end
    
to-report have-deg? [my-class]
  report prob (item (my-class - 1) [     
     50.25    
     38.61    
     26.16    
     20.36    
     14.71] / 100)
end

to-report new-ethnicity [eth-list]
  tv "ethnicity list" sort eth-list
  let feth first eth-list
  if length eth-list < 2 [report feth]
  let seth second eth-list
  if feth = seth [report first eth-list]
  if feth = "visible-minority" or seth = "visible-minority" [report "visible-minority"]
  report "majority"
end

to-report dominant-parent-of [par-set]
  report min-one-of par-set [class]
end

to-report dominant-parent
  report dominant-parent-of parents
end

to-report non-dominant-parent
  report max-one-of parents [class]
end

to-report per-tick [nm]
  ;; does not use those below - assumes per week
  report per-tick-l nm
end

to-report per-tick-l [nm]
  report nm / ticks-per-year
end

to-report per-tick-m [nm]
  report 1 - ((1 - nm) ^ (1 / ticks-per-year))
end

to-report label-of [cn]
  ifelse member? cn parties
    [report item (position cn parties) party-labels]
    [report "not a party!"]
end

;;;;;;;;;;;;;;;;;;;;;;;;
;; Plots and outputs
;;;;;;;;;;;;;;;;;;;;;;;;
to a-a-PLOT-PROCS end

to plot-fof-dist
  set-current-plot "FOF Dist (Adults)"
  histogram [link-prop friendship-neighbors] of (people with [age > 18])
;;  histogram [safeDiv (2 * count-links-between friendship-neighbors) (count friendship-neighbors * (count friendship-neighbors - 1))] of (people with [age > 18])
end
  
to-report count-links-between [as]
  let num-links 0
  ask as [
    set num-links num-links + count friendship-neighbors with [member? self as]
  ]
  report num-links
end

to-report link-prop [as]
  report safeDiv (count-links-between as) (count as * (count as - 1))
end
  
to-report flink-prop [as]
  report safeDiv (count-flinks-between as) (count as * (count as - 1))
end

to-report count-flinks-between [as]
  let num-links 0
  ask as [
    set num-links num-links + count family-relationship-neighbors with [member? self as]
  ]
  report num-links
end


to plot-friendship-dist
  set-current-plot "Discussant Connections (Adults)"
  set-plot-x-range 0 30
  set-plot-pen-interval 1
  ;; histogram [count my-friendships] of (people with [age > 18])
  histogram [count my-discussant-links] of adults
end

to plot-household-dist
  set-current-plot "Household Size Dist"
  set-plot-x-range 1 20
  set-plot-y-range 0 20
  histogram [count people-here] of households
end


to plot-age-dist
  set-current-plot "Age Distrbution"
  let al [age] of people
  set-plot-x-range 0 100
  set-plot-y-range 0 20
  histogram [age] of people
end

to init-voting-plot
  set-current-plot "Voting"
  set-plot-x-range start-date end-date 
  set-current-plot-pen "red"
  plot-pen-up
  set-current-plot-pen "blue"
  plot-pen-up
  set-current-plot-pen "yellow"
  plot-pen-up
  set-current-plot-pen "grey"
  plot-pen-up
  
  set-current-plot "Turnout by Ethnicity"
  set-plot-x-range start-date end-date 
  set-current-plot-pen "majority" plot-pen-up
  set-current-plot-pen "invis-min" plot-pen-up
  set-current-plot-pen "vis-min" plot-pen-up
  
  set-current-plot "Turnout by Immigrant Gen"
  set-plot-x-range start-date end-date 
  set-current-plot-pen "1st gen" plot-pen-up
  set-current-plot-pen "2nd gen" plot-pen-up
  set-current-plot-pen "3+ gen" plot-pen-up
  
  set-current-plot "Turnout by class"
  set-plot-x-range start-date end-date 
  set-current-plot-pen "1"
  plot-pen-up
  set-current-plot-pen "2"
  plot-pen-up
  set-current-plot-pen "3"
  plot-pen-up
  set-current-plot-pen "4"
  plot-pen-up
  set-current-plot-pen "5"
  plot-pen-up
  
end

to voting-plots
  set-current-plot "Voting"
  if first-vote? [
    set-current-plot-pen "red"
    plot-pen-down
    set-current-plot-pen "blue"
    plot-pen-down
    set-current-plot-pen "yellow"
    plot-pen-down
    set-current-plot-pen "grey"
    plot-pen-down
  ]
  set electorate count adults
  set-current-plot-pen "red"
  plotxy (year + month / 12) safeDiv count adults with [voted-for = red]  electorate
  set-current-plot-pen "blue" 
  plotxy (year + month / 12) safeDiv count adults with [voted-for = blue]  electorate
  set-current-plot-pen "yellow"
  plotxy (year + month / 12)  safeDiv count adults with [voted-for = yellow]  electorate
  set-current-plot-pen "black"
  plotxy (year + month / 12)  safeDiv count adults with [voted?]  electorate
  set last-election-year year
  set last-election-month month
  
  set-current-plot "Turnout by Ethnicity"
    if first-vote? [
    set-current-plot-pen "majority" plot-pen-down
    set-current-plot-pen "invis-min" plot-pen-down 
    set-current-plot-pen "vis-min" plot-pen-down 
    ]
  set-current-plot-pen "majority"
  let maj-voting people with [age >= 18 and ethnicity = "majority"]
  plotxy (year + month / 12) safeDiv count maj-voting with [voted?]
                                     count maj-voting 
  set-current-plot-pen "invis-min"
  let inmin-voting people with [age >= 18 and ethnicity = "invisible-minority"]
  plotxy (year + month / 12) safeDiv count inmin-voting with [voted?]
                                     count inmin-voting 
  set-current-plot-pen "vis-min"
  let vimin-voting people with [age >= 18 and ethnicity = "visible-minority"]
  plotxy (year + month / 12) safeDiv count vimin-voting with [voted?]
                                     count vimin-voting 
  
  set-current-plot "Turnout by Immigrant Gen"
  if first-vote? [
    set-current-plot-pen "3+ gen" plot-pen-down
    set-current-plot-pen "2nd gen" plot-pen-down 
    set-current-plot-pen "1st gen" plot-pen-down 
  ]
  set-current-plot-pen "3+ gen"
  let oth-voting people with [age >= 18 and immigrant-gen > 2]
  plotxy (year + month / 12) safeDiv count oth-voting with [voted?]
                                     count oth-voting 
  set-current-plot-pen "2nd gen"
  let imm2-voting people with [age >= 18 and immigrant-gen = 2]
  plotxy (year + month / 12) safeDiv count imm2-voting with [voted?]
                                     count imm2-voting 
  set-current-plot-pen "1st gen"
  let imm-voting people with [age >= 18 and immigrant-gen = 1]
  plotxy (year + month / 12) safeDiv count imm-voting with [voted?]
                                     count imm-voting 
                                     
  set-current-plot "Turnout by class"
  if first-vote? [
    set-current-plot-pen "1"
    plot-pen-down
    set-current-plot-pen "2"
    plot-pen-down
    set-current-plot-pen "3"
    plot-pen-down
    set-current-plot-pen "4"
    plot-pen-down
    set-current-plot-pen "5"
    plot-pen-down
  ]
  set-current-plot-pen "1"
  plotxy (year + month / 12) safeDiv count adults with [voted? and class = 1] (count adults with [class = 1])
  set-current-plot-pen "2"
  plotxy (year + month / 12) safeDiv count adults with [voted? and class = 2] (count adults with [class = 2])
  set-current-plot-pen "3"
  plotxy (year + month / 12) safeDiv count adults with [voted? and class = 3] (count adults with [class = 3])
  set-current-plot-pen "4"
  plotxy (year + month / 12) safeDiv count adults with [voted? and class = 4] (count adults with [class = 4])
  set-current-plot-pen "5"
  plotxy (year + month / 12) safeDiv count adults with [voted? and class = 5] (count adults with [class = 5])
  
end

;; debug plot
to plot-ends
  set-current-plot "ends"
  foreach plotted-ends [
    set-current-plot-pen ?
    plot count people with [any-end-with? ?]
  ]
end

to do-output
  clear-output
;;  let un-species-list remove-duplicates [species-num] of people
;;  set num-list map [(list ? (count people with [species-num = ?]) ([gene] of one-of people with [species-num = ?]))] un-species-list
;;  set num-list sort-by [second ?1 > second ?2] num-list
;;  set num-list safeSubList num-list 0 10
;;  foreach num-list [
;;    output-type (word "Species " first ? ": (" second ? ") ") output-print pretty-show simplify third ?
;;  ]  
;;  do-key
end

to do-key
  set-current-plot "Key"
  clear-plot
  let y 10
;;  foreach num-list [
;;    set-plot-pen-color colour-of first ?
;;    plot-shape 10 y
;;    set y y - 1
;;  ]
end

to-report colour-of [sp]
  ifelse member? sp colour-list-kinds
    [report (item (position sp colour-list-kinds) colour-list)]
    [report grey]
end

to plot-shape [x y]
  foreach seq 0.1 1 0.1 [
    plot-sq x y (? / 2)   
  ]
end

to plot-sq [x y s]
  plot-pen-up 
  plotxy x + s y + s
  plot-pen-down 
  plotxy x + s y - s plotxy x - s y - s plotxy x - s y + s plotxy x + s y + s
end

to-report on-watch-list?
  if trace? [report false]
  report member? self watch-list
end

to add-another-to-watch-list [prs]
  set watch-list fput min-one-of other people [age] watch-list
  set watch-list remove prs watch-list
end

;;;;;;;;;;;;;;;;;;;;;;
;; endorsements ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;
to a-a-ENDORSEMENT-UTILS end

to init-ends
;;  set my-endorsements []
  set my-talking-endorsements []
  set my-satisfaction-endorsements []
  set my-other-endorsements []
end

to put-end [lis]
  ifelse member? first lis endorsements [
;;      set my-endorsements fput lis my-endorsements
      ifelse first lis = "talk-about-politics-with" 
        [set my-talking-endorsements fput lis my-talking-endorsements] [
        ifelse member? first lis ["satisfied-by-voting" "dissatisfied-by-voting" "satisfied-by-not-voting" "dissatisfied-by-not-voting"] 
         [set my-satisfaction-endorsements fput lis my-satisfaction-endorsements] 
         [
           let my-oth-list all-end-with "starts-noticing-politics"
           ifelse not empty? my-oth-list
            [set my-other-endorsements fput lis filter [(first ?) != "starts-noticing-politics"] my-other-endorsements]
            [set my-other-endorsements fput lis my-other-endorsements]
         ]
      ]
    ]
    [error (word first lis " not a declared endorsement in: put-end " lis)]
end

to-report all-end-with [keywrd]
;;  if not member? keywrd endorsements [error (word keywrd " not a declared endorsement in: all-end-with ")]
  ifelse keywrd  = "talk-about-politics-with"
    [report my-talking-endorsements] [
    ifelse member? keywrd ["satisfied-by-voting" "dissatisfied-by-voting" "satisfied-by-not-voting" "dissatisfied-by-not-voting"] 
      [report filter [first ? = keywrd] my-satisfaction-endorsements] [
       report filter [first ? = keywrd] my-other-endorsements
      ]
  ]
end

to delete-oldest-end-with [keywrd]
;;  if not member? keywrd endorsements [error (word keywrd " not a declared endorsement in: delete-oldest-end-with ")]
  ifelse member? keywrd ["talk-about-politics-with"] 
    [set my-talking-endorsements but-last my-talking-endorsements] [
    ifelse member? keywrd ["satisfied-by-voting" "dissatisfied-by-voting" "satisfied-by-not-voting" "disatisfied-by-not-voting"] 
      [set my-satisfaction-endorsements but-last my-satisfaction-endorsements]
      [set my-other-endorsements but-last my-other-endorsements]
    ]
;;  set my-endorsements remove (last all-end-with keywrd) my-endorsements
end

to delete-older-than-with [keywrd lag prb]
;;  if not member? keywrd endorsements [error (word keywrd " not a declared endorsement in: delete-older-than-with " lag prb)]
;;  let temp-ends []
;;  foreach  my-endorsements [
;;    if (age-of-end ? <= lag) or (prob prb) [set temp-ends fput ? temp-ends]
;;  ]
;;  set my-endorsements temp-ends
  ifelse member? keywrd ["talk-about-politics-with"] 
    [set my-talking-endorsements filter [first ? != keywrd or age-of-end ? <= lag or prob prb] my-talking-endorsements] [
    ifelse member? keywrd ["satisfied-by-voting" "dissatisfied-by-voting" "satisfied-by-not-voting" "dissatisfied-by-not-voting"] 
      [set my-satisfaction-endorsements filter [first ? != keywrd or age-of-end ? <= lag or prob prb] my-satisfaction-endorsements]
      [set my-other-endorsements filter [first ? != keywrd or age-of-end ? <= lag or prob prb] my-other-endorsements]
    ]
;;  set my-endorsements filter [first ? != keywrd or age-of-end ? <= lag or prob prb] my-endorsements
end

to mm-delete-all-older-than-with [lag prb]
  set my-talking-endorsements filter [age-of-end ? <= (lag / forget-mult) or prob (prb / forget-mult)] my-talking-endorsements
  set my-satisfaction-endorsements filter [age-of-end ? <= (lag / forget-mult) or prob (prb / forget-mult)] my-satisfaction-endorsements
  set my-other-endorsements filter [safe? ? or age-of-end ? <= (lag / forget-mult) or prob (prb / forget-mult)] my-other-endorsements
end

;; about a single endorsement

to-report safe? [en]
  report member? first en ["starts-noticing-politics"]
end

to-report age-of-end [endrsmt]
  report year + (month / 12) - (last but-last endrsmt) - ((last endrsmt) / 12)
end

;;;; secondary end code

to-report any-end-with? [keywrd]
;;  if not member? keywrd endorsements [error (word keywrd " not a declared endorsement in: any-end-with? ")]
  report not empty? all-end-with keywrd
end

to-report count-end-with [keywrd]
;;  if not member? keywrd endorsements [error (word keywrd " not a declared endorsement in: count-end-with ")]
  report length all-end-with keywrd
end

to-report older-than-with [keywrd lag]
  ;;; year month ticks-per-year
;;  if not member? keywrd endorsements [error (word keywrd " not a declared endorsement in: older-than-with " lag)]
  report filter [age-of-end ? > lag] all-end-with keywrd
end

to-report remove-with-neg-prob [prb lis]
  ;;; year month ticks-per-year
  report filter [prob (1 - per-tick prb)] lis
end

to mm-delete-older-than-with [keywrd lag prb]
;;  if not member? keywrd endorsements [error (word keywrd " not a declared endorsement in: mm-delete-older-than-with " lag prb)]
  delete-older-than-with keywrd (lag / forget-mult) (prb / forget-mult)
end

;;;;;;;;;;;;;;;;;;;;;;;
;; utils
;;;;;;;;;;;;;;;;;;;;;;
to a-a-GENERAL-UTILS end

to-report any-member? [item-list test-list]
  if empty? item-list [report false]
  if member? first item-list test-list [report true]
  report any-member? but-first item-list test-list
end

to-report numeric-date-and-time
  let str date-and-time
  report (word substring str 16 27 "-" substring str 0 2 substring str 3 5 substring str 13 15)
end

to-report remove-all [rem-lis lis]
  report filter [not member? ? rem-lis] lis
end

to pause
  if not user-yes-or-no? (word "Continue?") [error "User halted simulation!!"]
end

to-report showpause [inp]
  if not user-yes-or-no? (word "Value is: " inp " -- Continue?") [error "User halted simulation!!"]
  report inp
end

to iph
  ask people-here [inspect self]
end

to ipp [p]
  foreach (pchl person p (list person p)) [inspect ?]
end

to-report pchl [p l]
  let pp [partner] of p
  if pp = nobody [report l]
  ifelse member? pp l
    [report l]
    [report pchl pp fput pp l]
end

to iper [p]
  inspect person p
end

to ipat [p1 p2]
  inspect patch p1 p2
end

to rec-last-action [str]
  if not rec-la? [stop]
  if last-action = 0 [set last-action []]
  set last-action fput with-tick str last-action
  ask patch-here [
    if history = 0 [set history []]
    set history fput (word myself with-tick str) history
  ]
end

to rec-hist [stf]
  if not rec-la? [stop]
  if history = 0 [set history []]
  set history fput (word with-tick stf) history
end

to-report with-tick [str]
  ifelse after-setup? 
    [report (word str " at ick: " ticks "; ")]
    [report (word str " at setup; ")]
end

to-report link-breed [p1 p2]
  let pl []
  ask p1 [set pl sort my-links]
  ask p2 [
    let p2l sort my-links
    set pl filter [member? ? p2l] pl
  ]
  if empty? pl [report "none"]
  report [breed] of (random-member pl)
end

to-report col-of [lbl]
  if not member? lbl patch-types [error (word lbl " is not a recognised patch type!")]
  report item (position lbl patch-types) patch-colours
end
  
to-report random-member [ls]
  report item (random length ls) ls
end

to-report prob [p]
  report random-float 1 < p
end

to-report subtract-list [lis1 lis2]
  report filter [not member? ? lis2] lis1
end

to-report safeSubList [lis srt en]
  let len length lis
  if en < 1 or srt > len [report []]
  report subList lis max list 0 srt min list en len
end

to-report safe-n-of [nm lis]
  if is-list? lis [if length lis >= nm [report n-of nm lis]]
  if is-agentset? lis [if count lis >= nm [report n-of nm lis]]
  report lis
end

to-report safe-one-of [lis]
  report safe-n-of 1 lis
end

to-report flatten-once [lis]
  let op-list []
  foreach lis [
    foreach ? [set op-list fput ? op-list]
  ]
  report op-list
end

to-report scale [nm a-min b-max c-min d-max]
  report c-min + (d-max - c-min) * (nm - a-min) / (b-max - a-min)
end


to-report minList [lis1 lis2]
  report (map [min list ?1 ?2] lis1 lis2)
end

to-report maxList [lis1 lis2]
  report (map [max list ?1 ?2] lis1 lis2)
end

to-report sumList [lis1 lis2]
  report (map [?1 + ?2] lis1 lis2)
end

to-report sdList [sqLis sumLis numLis] 
  report (map [sqrt max (list 0 ((?1 / numLis) - ((?2 / numLis) ^ 2)))] sqLis sumLis)
end

to-report fputIfNew [exLisLis newLis]
  report (map [ifelse-value (member? ?2 ?1) [?1] [fput ?2 ?1]] exLisLis newLis)
end

to-report csv-string-to-list [str]
;;  if member? ":" str [error word "Colon in: " str]
  let lis []
  while [not empty? str] [
    set lis fput next-value str lis
    set str after-next str
  ]  
  report reverse lis
end  

to-report after-next [str]
  let pos-comma position "," str
  if pos-comma != false [report subString str (pos-comma + 1) length str]
  report ""
end  

to-report next-value [str]
  let pos-comma position "," str
  if pos-comma != false [
    report read subString str 0 pos-comma
    ]
  report read str
end

to-report read [str]
  set str strip-spaces str
  if empty? str [report nobody]
    ifelse is-string-a-number? str
      [report read-from-string str]
      [report str]
end  

to-report strip-spaces [str]
  report strip-leading-spaces strip-trailing-spaces str
end  

to-report strip-leading-spaces [str]
  if empty? str [report str]
  if first str != " " [report str]
  report strip-leading-spaces but-first str
end

to-report is-string-a-number? [str]
  if empty? str 
    [report false]
  report is-nonempty-string-a-number? str
end

to-report is-nonempty-string-a-number? [str]
  if empty? str [report true]
  let ch first str
  if ch = "." [report is-string-digits? but-first str]
  if not is-str-digit? ch [report false]
  report is-nonempty-string-a-number? but-first str
end

to-report is-string-digits? [str]
  if empty? str [report true]
  let ch first str
  if not is-str-digit? ch [report false]
  report is-string-digits? but-first str
end  
  
to-report is-str-digit? [ch]
  ifelse ch >= "0" and ch <= "9"
    [report true]
    [report false]
end

to-report strip-trailing-spaces [str]
  if empty? str [report str]
  if last str != " " [report str]
  report strip-trailing-spaces but-last str
end  

to-report insert [itm ps lis]
  report (sentence sublist lis 0 ps (list itm) sublist lis ps (length lis))
end

to-report insertAfter [itm ps lis]
  report insert itm (ps + 1) lis
end

to-report num-nodes [lis]
  report length nodes-in lis
end

to-report nodes-in [lis]
  if not is-list? lis [report (list lis)]
  let op-list []
  foreach lis [set op-list append op-list nodes-in ?]
  report op-list
end

to-report second [lis]
  report item 1 lis
end

to-report third [lis]
  report item 2 lis
end

to XXX
  let tt 1 
  set tt tt - 1
  set tt 1 / tt
end

to-report showPass [arg]
  show arg
  report arg
end

to-report posBiggest [lis]
  report position (reduce [ifelse-value (?1 >= ?2) [?1] [?2]] lis) lis 
end

to-report allPos [expr]
  let oplis [[]]
  foreach but-first (n-values (length expr) [?]) [
    let ps ?
    let posLis allPos (item ps expr)
    set opLis append (map [fput ps ?1] posLis) opLis
  ]
  report opLis
end

to-report replaceAtPos [posList baseExpr insExpr]
  if posList = [] [report insExpr]
  report replace-item (first posList) baseExpr (replaceAtPos (but-first posList) (item first posList baseExpr) insExpr)
end

to-report atPos [posList expr]
  if empty? posList [report expr]
  report atPos but-first posList item (first poslist) expr
end

to-report append [list1 list2]
  if empty? list1 [report list2]
  report fput (first list1) (append (but-first list1) list2)
end

to-report selectProbilistically [charList numList]
  report item (chooseProbilistically numList) charList
end

to-report chooseProbilistically [numList]
  report findPos (random-float 1) cummulateList scaleList numList
end

to-report chooseReverseProbilistically [numList]
  if length numList = 1 [report 0]
  report findPos (random-float 1) cummulateList reverseProbList scaleList numList
end

to-report reverseProbList [numList]
  report map [1 - ?1] numList
end

to-report cummulateList [numList]
  report cummulateListR numList 0
end

to-report cummulateListR [numList cumm]
  if empty? numList [report []]
  let newCumm cumm + first numList
  report fput newCumm cummulateListR but-first numList newCumm
end

to-report scaleList [numLis]
  if empty? numLis [report numLis]
  let sumLis sum numLis
  if sumLis = 0 [report numLis]
  report map [?1 / sumLis] numLis
end

to-report findPos [vl numList]
  report findPosR vl numList 0
end

to-report findPosR [vl numList  ps]
  if empty? numList [report ps]
  if vl <= (first numList) [report ps]
  report findPosR vl but-first numList (1 + ps)
end

to-report freqOfIn [lis allList]
  report reduce [fput (numOfIn ?2 lis) ?1 ] (fput [] allList)
end  
  
to-report freqOf [lis]
  if empty? lis [report []]
  let sort-lis sort lis
  let red-lis sort remove-duplicates lis
  let op-lis red-lis
  let num-lis []
  let cnt 0
  foreach sort-lis [
    ifelse ? = first red-lis 
      [set cnt cnt + 1]
      [set num-lis fput cnt num-lis 
       set cnt 1
       set red-lis but-first red-lis]
  ]
  set num-lis fput cnt num-lis 
  report pair-list (reverse num-lis) op-lis
;;  report pair-list reverse num-lis red-lis
  ;;  report fput (list (numOfIn first lis lis) (first lis)) (freqOf remove first lis lis)
end

to-report freqRep [lis]
  report sort-by [first ?1 > first ?2] filter [first ? > 1] freqOf lis 
end

to-report numOfIn [itm lis]
  report length (filter [itm = ?] lis)
end

to-report patchesToDist [dist]
  if dist = 0 [report self]
  let patchList []
  foreach seq (-1 * dist) dist 1 [
    let xc ?
      foreach seq (-1 * dist) dist 1 [
        set patchList fput patch-at xc ? patchList
      ]
  ]
  report patch-set patchList
end

to-report individualsToDist [dist]
  report people-on patchesToDist dist
end

to-report hammingDist [gene1 gene2]
  report sum (map [ifelse-value (?1 = ?2) [0] [1]] gene1 gene2)
end

to-report distBetween [x1 y1 x2 y2]
  report (max list abs (x1 - x2) abs (y1 - y2))
;;  report sqrt (((x1 - x2) ^ 2) + ((y1 - y2) ^ 2))
end

to-report seq [from upto stp]
  report n-values (1 + ceiling ((upto - from) / stp)) [from + ? * stp]
end

to-report safeDiv [numer denom]
  if denom = 0 and numer = 0 [report 1]
  if denom = 0 [report 0]
  report numer / denom
end  

to-report flip-bit [ps bitList]
  report replace-item ps bitList (1 - (item ps bitList))  
end


to showList [lis]
  foreach but-last lis [type ? type " "]
  print last lis
end


to-report is-divisor-of [num den] 
  report (0 = (num mod den))
end

to-report pair-list [lis1 lis2]
 report (map [list ?1 ?2] lis1 lis2)
end

to-report depth [lis]
  if not is-list? lis [report 0]
  if empty? lis [report 0]
  report 1 + max map [depth ?] lis
end

to-report empty-as
  report (turtle-set [])
end

to-report exists [obj]
  if is-turtle-set? obj [report any? obj]
  report obj != nobody
end

to-report pick-at-random-from-list [lis]
  report item random length lis lis
end

to tv [str val]
  if trace? [output-print (word str "=" val)]
end

to-report normal-dist [x mn sd]
  report exp (-0.5 * ((x - mn) / sd) ^ 2) / (sd * sqrt (2 * pi))
end

to-report careful-item [ps lis str]
  let rs 0
  carefully 
    [set rs item ps lis] 
    [output-print (word "str" ": no position " ps " in: " lis)]
  report rs
end

to-report safeModEquals [nm bs rs]
  if bs <= 0 [report false]
  report (nm mod bs) = rs
end
to-report safe-count [as]
  if as = NOBODY [report 0]
  report count as
end

to-report safeMean [lst]
  if empty? lst [report 0]
  report mean lst
end

to-report safeSD [lst]
  if empty? lst [report 0]
  report standard-deviation lst
end
@#$#@#$#@
GRAPHICS-WINDOW
305
10
795
521
-1
-1
24.0
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
19
0
19
1
1
1
ticks
7.0

BUTTON
813
501
869
534
Setup
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
932
501
987
534
Go
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

BUTTON
873
501
928
534
Step
go
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

PLOT
7
57
297
199
Voting
Year
Proportion
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"black" 1.0 0 -16777216 true "" ""
"red" 1.0 0 -2674135 true "" ""
"blue" 1.0 0 -13345367 true "" ""
"yellow" 1.0 0 -1184463 true "" ""
"grey" 1.0 0 -7500403 true "" ""

SLIDER
811
10
972
43
start-date
start-date
0
2050
0
1
1
NIL
HORIZONTAL

PLOT
7
201
296
337
Age Distrbution
Age
Number
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"default" 5.0 1 -16777216 true "" ""

OUTPUT
305
537
808
747
12

MONITOR
910
84
973
129
Secs/tick
time-per-tick
17
1
11

SLIDER
812
46
973
79
end-date
end-date
0
500
200
1
1
NIL
HORIZONTAL

MONITOR
7
10
57
55
Year
year
17
1
11

MONITOR
59
10
109
55
Month
month-name
17
1
11

SWITCH
813
465
973
498
show-friendships?
show-friendships?
1
1
-1000

SWITCH
813
429
973
462
show-activity-memb?
show-activity-memb?
1
1
-1000

SLIDER
812
244
976
277
drop-friend-prob
drop-friend-prob
0
0.5
0.1
0.005
1
NIL
HORIZONTAL

SLIDER
812
279
977
312
drop-activity-prob
drop-activity-prob
0
0.2
0.05
0.005
1
NIL
HORIZONTAL

PLOT
7
341
297
470
Household Size Dist
Household Size
Number
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

PLOT
8
472
298
604
Discussant Connections (Adults)
Nodes
Number
0.0
25.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

PLOT
8
608
297
747
FOF Dist (Adults)
Prop F know F links
Freq
0.0
1.0
0.0
10.0
true
false
"" ""
PENS
"default" 0.1 1 -16777216 true "" ""

MONITOR
599
950
657
995
Elect
electorate
17
1
11

SLIDER
813
353
975
386
prob-partner
prob-partner
0
0.1
0.03
0.001
1
NIL
HORIZONTAL

SLIDER
812
136
975
169
birth-mult
birth-mult
0
3
1.25
0.025
1
NIL
HORIZONTAL

SLIDER
812
172
976
205
death-mult
death-mult
0
2
0.8
0.01
1
NIL
HORIZONTAL

SLIDER
812
208
976
241
move-prob-mult
move-prob-mult
0
2
1
0.01
1
NIL
HORIZONTAL

CHOOSER
813
83
906
128
ticks-per-year
ticks-per-year
1 2 3 4 6 12 52
5

SLIDER
814
581
986
614
density
density
0
1
0.75
0.01
1
NIL
HORIZONTAL

SLIDER
814
616
986
649
majority-prop
majority-prop
0
1
0.8
0.01
1
NIL
HORIZONTAL

SLIDER
814
651
986
684
init-move-prob
init-move-prob
0
5
1.44
0.01
1
NIL
HORIZONTAL

SLIDER
814
684
986
717
prob-move-near
prob-move-near
0
1
0.5
.01
1
NIL
HORIZONTAL

SLIDER
814
720
986
753
immigration-rate
immigration-rate
0
0.1
0.01
0.005
1
NIL
HORIZONTAL

SLIDER
817
831
989
864
dissim-of-empty
dissim-of-empty
0
10
5
0.25
1
NIL
HORIZONTAL

PLOT
211
898
383
1048
Class Distribution
Class
Number
1.0
6.0
0.0
10.0
true
false
"set-plot-x-range 1 6" "set-plot-x-range 1 6"
PENS
"default" 1.0 1 -16777216 true "" "histogram [class] of people"

PLOT
236
754
492
893
Turnout by Ethnicity
time
Turnout
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"majority" 1.0 0 -16777216 true "" ""
"invis-min" 1.0 0 -14070903 true "" ""
"vis-min" 1.0 0 -13840069 true "" ""

PLOT
564
755
812
894
Turnout by Immigrant Gen
time
Turnout
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"3+ gen" 1.0 0 -14737633 true "" ""
"1st gen" 1.0 0 -2064490 true "" ""
"2nd gen" 1.0 0 -7858858 true "" ""

MONITOR
532
997
590
1042
Av Clust
av-clust
2
1
11

MONITOR
390
900
440
945
Pop
pop-size
0
1
11

MONITOR
532
950
590
995
Link Dens
link-dens
4
1
11

MONITOR
389
951
460
996
Av HH Same
av-fr-samevote
2
1
11

MONITOR
463
950
528
995
Av Fr Same
av-fr-samevote
2
1
11

MONITOR
443
900
494
945
1st gen
count people with [immigrant-gen = 1]
0
1
11

MONITOR
496
900
550
945
2nd gen
count people with [immigrant-gen = 2]
0
1
11

MONITOR
552
900
602
945
Empty
count patches with [patch-type = \"household\" and not any? people-here]
17
1
11

MONITOR
604
900
654
945
Vis Min
count people with [ethnicity = \"visible-minority\"]
17
1
11

MONITOR
657
899
707
944
Inv Min
count people with [ethnicity = \"invisible-minority\"]
17
1
11

SLIDER
977
58
1159
91
forget-mult
forget-mult
0.25
4
1
0.01
1
NIL
HORIZONTAL

PLOT
6
898
206
1048
Pop
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"maj" 1.0 0 -16777216 true "" "plot count people with [ethnicity = \"majority\"]"
"invis-min" 1.0 0 -14070903 true "" "plot count people with [ethnicity = \"invisible-minority\"]"
"vis-min" 1.0 0 -13840069 true "" "plot count people with [ethnicity = \"visible-minority\"]"
"imm1" 1.0 0 -2674135 true "" "plot count people with [immigrant-gen = 1]"
"imm2" 1.0 0 -955883 true "" "plot count people with [immigrant-gen = 2]"
"j-imm" 1.0 0 -8630108 true "" "plot count people with [just-imm]"

SLIDER
816
757
988
790
uk-inflow-rate
uk-inflow-rate
0
0.1
0.01
0.001
1
NIL
HORIZONTAL

SLIDER
817
794
988
827
emmigration-rate
emmigration-rate
0
0.2
0.015
0.001
1
NIL
HORIZONTAL

SWITCH
939
537
1029
570
trace?
trace?
1
1
-1000

SWITCH
814
538
935
571
checking-on?
checking-on?
1
1
-1000

PLOT
589
1578
799
1733
Class party preference
Class
Num with each preference
1.0
6.0
0.0
10.0
true
false
"set-plot-x-range 1 6" "set-plot-x-range 1 6"
PENS
"blue" 1.0 1 -13345367 true "" "histogram [class] of adults with [color = blue]"
"yellow" 1.0 1 -1184463 true "" "histogram [class] of adults with [color = yellow]"
"red" 1.0 1 -2674135 true "" "histogram [class] of adults with [color = red]"

PLOT
6
752
228
891
Turnout by class
time
Turnout
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"1" 1.0 0 -16777216 true "" ""
"2" 1.0 0 -12895429 true "" ""
"3" 1.0 0 -9276814 true "" ""
"4" 1.0 0 -5987164 true "" ""
"5" 1.0 0 -3026479 true "" ""

SWITCH
1034
537
1124
570
rec-la?
rec-la?
1
1
-1000

PLOT
6
1053
297
1225
Interest Levels
Time
Numbers
0.0
10.0
0.0
10.0
true
true
"" "if not after-setup? [stop]"
PENS
"involved" 1.0 0 -2674135 true "" "plot count adults with [politically-involved]"
"interested" 1.0 0 -955883 true "" "plot count adults with [only-politically-interested]"
"with a view" 1.0 0 -10899396 true "" "plot count adults with [only-politically-view-taking]"
"noticing" 1.0 0 -13791810 true "" "plot count adults with [politically-noticing]"
"not notice" 1.0 0 -7500403 true "" "plot count adults with [not politically-noticing]"

PLOT
9
1232
605
1405
Numbers of Discussions
Time
Number per week
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"total" 1.0 0 -16777216 true "" "if after-setup? [plot length discussion-stat-list]"
"civic duty" 1.0 0 -14835848 true "" "if after-setup? [plot length filter [item 1 ?] discussion-stat-list]"
"involved" 1.0 0 -2674135 true "" "if after-setup? [plot length filter [item 2 ?] discussion-stat-list]"

SLIDER
813
317
976
350
influence-rate
influence-rate
0
400
5
0.5
1
NIL
HORIZONTAL

PLOT
10
1409
266
1574
Discussion Levels
Time
Number
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"st noticing" 1.0 0 -7500403 true "" "plot count people with \n   [any-end-with? \"starts-noticing-politics\"]"
"some family" 1.0 0 -1604481 true "" "plot count people with [any-end-with? \"some-discussion-in-home\"]"
"lots family" 1.0 0 -2674135 true "" "plot count people with [any-end-with? \"lots-discussion-in-home\"]"

PLOT
304
1054
581
1228
Numb Discussions
Number of Discussions
Frequency
0.0
1.0
0.0
10.0
true
true
"set-plot-x-range 0 50\nset-plot-pen-interval 1" "set-plot-x-range 0 50\nset-plot-pen-interval 1"
PENS
"adults" 1.0 1 -13345367 true "" "histogram [length all-end-with \"talk-about-politics-with\"] of adults"

PLOT
821
1085
1034
1226
Distribution of Post-18 edu
NIL
NIL
1.0
6.0
0.0
10.0
true
false
"" "set-plot-x-range 1 6"
PENS
"post-18-edu" 1.0 1 -16777216 true "" "histogram [class] of adults with [post-18-edu?]"

PLOT
591
1074
818
1225
Distribution of Interest Levels
Interest Level
Number
0.0
5.0
0.0
10.0
true
false
"" "set-plot-x-range 0 5"
PENS
"interest" 1.0 1 -16777216 true "" "histogram [interest-level] of adults"

PLOT
10
1577
283
1734
Inheritance of Party
Time
Proportion Same
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"dominant" 1.0 0 -16777216 true "" "if ticks > 0 [plot safeDiv\n  (count people with [any? parents] \n    with [politics = ([politics] of dominant-parent)])\n  (count people with [any? parents])]"
"non-dom" 1.0 0 -7500403 true "" "if ticks > 0 [plot safeDiv\n  (count people with [count parents > 1] \n    with [politics = ([politics] of non-dominant-parent)])\n  (count people with [count parents > 1])]"
"non-grey" 1.0 0 -2674135 true "" "if ticks > 0 [plot safeDiv \n  (count people with [politics != grey and any? parents] \n    with [politics = ([politics] of non-dominant-parent)])\n  (count people with [politics != grey and any? parents])]"

PLOT
290
1577
584
1734
Proportion Adults Switched
Time
Proportion
0.0
10.0
0.0
0.0010
true
true
"" ""
PENS
"any" 1.0 0 -16777216 true "" "plot (count adults with [switched-this-year?]) / (count adults)"
"mobile" 1.0 0 -2674135 true "" "plot (count adults with [class != dom-parent-class and switched-this-year?]) \n     / (count adults)"
"non-mobile" 1.0 0 -13840069 true "" "plot (count adults with [class = dom-parent-class \n                          and switched-this-year?]) / (count adults)"

PLOT
270
1411
620
1573
Confounding Factors
Election
Number
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"moved recently" 1.0 0 -16777216 true "" "if ticks > 0 and election? [plot count adults with \n  [member? \"moved recently\" confounding-factors]]"
"has baby" 1.0 0 -7500403 true "" "if ticks > 0 and election? [plot count adults with [member? \"has baby\" confounding-factors]]"
"unemployed" 1.0 0 -2674135 true "" "if ticks > 0 and election? [plot count adults with [member? \"unemployed\" confounding-factors]]"
"randomly ill" 1.0 0 -955883 true "" "if ticks > 0 and election? [plot count adults with [member? \"randomly ill\" confounding-factors]]"
"old age infirmity" 1.0 0 -6459832 true "" "if ticks > 0 and election? [plot count adults with [member? \"old age infirmity\" confounding-factors]]"

PLOT
625
1410
1037
1571
Dragged By Numbers
Election
Number
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"partner" 1.0 0 -5825686 true "" "if ticks > 0 and election? [plot count adults with [dragged-by = \"partner\"]]"
"pol int family" 1.0 0 -8630108 true "" "if ticks > 0 and election? [plot count adults with [dragged-by = \"politically interested family\"]]"
"friend" 1.0 0 -14835848 true "" "if ticks > 0 and election? [plot count adults with [dragged-by = \"friend\"]]"
"civ dur or inv family" 1.0 0 -13345367 true "" "if ticks > 0 and election? [plot count adults with [dragged-by = \"civicly dutiful or involved family\"]]"

PLOT
806
1577
1042
1732
Political Leanings
Time
Numbers
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"red" 1.0 0 -2674135 true "" "if ticks > 0 [plot count adults with [politics = red]]"
"blue" 1.0 0 -13345367 true "" "if ticks > 0 [plot count adults with [politics = blue]]"
"yellow" 1.0 0 -1184463 true "" "if ticks > 0 [plot count adults with [politics = yellow]]"
"none" 1.0 0 -7500403 true "" "if ticks > 0 [plot count adults with [politics = grey]]"

SLIDER
991
757
1148
790
prob-contacted
prob-contacted
0
1
0
0.01
1
NIL
HORIZONTAL

SWITCH
1004
909
1146
942
household-drag?
household-drag?
0
1
-1000

MONITOR
463
997
528
1042
Av Fr voted
av-fr-whvoted
2
1
11

MONITOR
389
997
460
1042
Av HH voted
av-hh-whvoted
2
1
11

MONITOR
977
10
1050
55
Av. Talk. Ends.
mean [length my-talking-endorsements] of adults
2
1
11

INPUTBOX
660
948
757
1008
when-calc-data?
12
1
0
Number

SWITCH
763
941
853
974
to-file?
to-file?
0
1
-1000

SWITCH
763
976
864
1009
sna-out?
sna-out?
1
1
-1000

INPUTBOX
595
1011
812
1071
output-filename
default settings run
1
0
String

PLOT
680
1231
1036
1405
Initial Voting Reasons
Election
Number
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"not" 1.0 0 -7500403 true "" "if ticks > 0 and election? [plot count adults with [empty? last-voting-reasons]]"
"civic" 1.0 0 -16777216 true "" "if ticks > 0 and election? \n  [plot count adults with [member? \"civic duty\" last-voting-reasons]]"
"habit" 1.0 0 -14835848 true "" "if ticks > 0 and election? \n  [plot count adults with [member? \"generalised habit\" last-voting-reasons]]"
"rational" 1.0 0 -2674135 true "" "if ticks > 0 and election? \n  [plot count adults with [member? \"rational\" last-voting-reasons]]"
"dragged" 1.0 0 -955883 true "" "if ticks > 0 and election? \n  [plot count adults with [member? \"dragged\" last-voting-reasons]]"

SLIDER
976
95
1159
128
talk-about-politics-remb
talk-about-politics-remb
0
1
0.8
0.01
1
NIL
HORIZONTAL

SLIDER
976
130
1160
163
talk-about-politics-min
talk-about-politics-min
0
10
1
.1
1
NIL
HORIZONTAL

SLIDER
976
165
1161
198
someone-talk-politics-remb
someone-talk-politics-remb
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
977
201
1161
234
someone-talk-politics-min
someone-talk-politics-min
0
10
1
.1
1
NIL
HORIZONTAL

SLIDER
978
238
1160
271
voted-remb
voted-remb
0
1
0.9
0.01
1
NIL
HORIZONTAL

SLIDER
979
275
1160
308
voted-min
voted-min
0
50
3
.1
1
NIL
HORIZONTAL

SLIDER
979
311
1159
344
satisfied-remb
satisfied-remb
0
1
0.9
0.01
1
NIL
HORIZONTAL

SLIDER
979
347
1160
380
satisfied-min
satisfied-min
0
30
2
.1
1
NIL
HORIZONTAL

PLOT
8
1737
641
1966
Moving Reasons (adults per year)
NIL
Number
0.0
10.0
0.0
10.0
true
true
"foreach remove \"\" move-reasons [\n  create-temporary-plot-pen ?\n  set-plot-pen-color item (position ? move-reasons) colour-list\n]" "if ticks > 0 and (ticks mod ticks-per-year) = (ticks-per-year - 1) [foreach remove \"\" move-reasons [\n  set-current-plot-pen ?\n  plot count adults with [move-reason = ?]\n]]"
PENS

SLIDER
813
388
975
421
seperate-prob
seperate-prob
0
0.1
0.0050
0.001
1
NIL
HORIZONTAL

MONITOR
1052
10
1105
55
Av. Satis. Ends
mean [length my-satisfaction-endorsements] of adults
2
1
11

MONITOR
1108
10
1159
55
Av. Oth. Ends.
mean [length my-other-endorsements] of adults
2
1
11

MONITOR
111
10
161
55
Week
week
0
1
11

SLIDER
991
574
1146
607
major-election-period
major-election-period
0
10
5
1
1
NIL
HORIZONTAL

SLIDER
991
686
1148
719
minor-election-period
minor-election-period
0
10
0
1
1
NIL
HORIZONTAL

SLIDER
991
612
1147
645
major-election-length
major-election-length
0
52
1
1
1
NIL
HORIZONTAL

SLIDER
991
721
1147
754
minor-election-length
minor-election-length
0
10
0
1
1
NIL
HORIZONTAL

PLOT
8
1969
434
2184
Campaign Messages (only during campaigns)
Time
Num per week
0.0
1.0
0.0
1.0
true
true
"" ""
PENS
"short" 1.0 0 -16777216 true "" "if week < 2 or campaign? [plot num-short-campaign-messages]"
"long" 1.0 0 -7500403 true "" "if week < 2 or campaign? [plot num-long-campaign-messages]"

PLOT
439
1971
847
2184
Intention Change each Tick (during campaigns)
Time
Expected Change
0.0
1.0
0.0
1.0
true
true
"" ""
PENS
"mob" 1.0 0 -2674135 true "" "if week < 2 or short-campaign? [plot sum-intention-increased-mb-all]"
"p2p" 1.0 0 -10899396 true "" "if week < 2 or short-campaign? [plot sum-intention-increased-p2p-all]"

SLIDER
991
793
1148
826
contact-mult
contact-mult
0
10
1
1
1
NIL
HORIZONTAL

PLOT
646
1738
1039
1966
Number Influenced each Tick (during campaigns)
Number
Time
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"mob" 1.0 0 -5298144 true "" "if week < 2 or short-campaign? [plot count adults with [mob-num = 1]]"
"2nd order" 1.0 0 -12087248 true "" "if week < 2 or short-campaign? [plot count adults with [mob-num > 1]]"

MONITOR
709
899
759
944
Num.Isol.
count adults with [not any? my-discussant-links]
0
1
11

PLOT
852
1971
1040
2091
Intentions Dist
NIL
NIL
0.0
1.1
0.0
10.0
true
false
"" ""
PENS
"all" 1.0 1 -16777216 true "" "set-plot-x-range 0 1.1\nset-plot-pen-interval 0.1\nhistogram [intention-prob] of adults"
"mob" 1.0 1 -2674135 true "" "set-plot-x-range 0 1.1\nset-plot-pen-interval 0.1\nhistogram [intention-prob] of adults with [mob-num = 1]"
"p2p" 1.0 0 -10899396 true "" "set-plot-x-range 0 1.1\nset-plot-pen-interval 0.1\nhistogram [intention-prob] of adults with [mob-num > 1]"

MONITOR
911
2093
968
2138
Week
week
0
1
11

MONITOR
609
1232
676
1273
Pop
pop-size
0
1
10

MONITOR
609
1276
676
1317
Could Talk
count adults with [interest-level > 1]
0
1
10

MONITOR
608
1319
677
1360
Num Disc.
num-discussions
0
1
10

MONITOR
609
1362
675
1403
Num Talk
num-talked
0
1
10

SLIDER
992
648
1147
681
major-election-short-len
major-election-short-len
0
10
0
1
1
NIL
HORIZONTAL

MONITOR
852
2139
909
2184
Short?
short-campaign?
0
1
11

MONITOR
852
2093
909
2138
Long?
long-campaign?
17
1
11

MONITOR
911
2139
968
2184
Elect
election?
17
1
11

SWITCH
878
946
991
979
greys-vote?
greys-vote?
0
1
-1000

MONITOR
970
2093
1041
2138
Num Voted
num-voting-withoutgrey
0
1
11

MONITOR
970
2140
1042
2185
Num Mob
cum-num-mob-withoutgrey
0
1
11

SWITCH
993
945
1123
978
p2p-influence?
p2p-influence?
1
1
-1000

SLIDER
981
457
1154
490
make-link-mult
make-link-mult
0
5
1
0.01
1
NIL
HORIZONTAL

SLIDER
980
383
1153
416
world-size
world-size
10
60
20
5
1
NIL
HORIZONTAL

SWITCH
879
980
970
1013
fof?
fof?
0
1
-1000

SWITCH
973
981
1104
1014
no-rat-voting?
no-rat-voting?
1
1
-1000

SWITCH
866
910
1002
943
mob-once-ph?
mob-once-ph?
1
1
-1000

MONITOR
165
9
243
54
Sub-year tick
sub-year-tick
0
1
11

SLIDER
981
421
1154
454
fof-prob
fof-prob
0
1
0.4
0.01
1
NIL
HORIZONTAL

SLIDER
994
493
1155
526
drop-link-mult
drop-link-mult
0
5
1
0.01
1
NIL
HORIZONTAL

SLIDER
991
829
1148
862
add-near-fr-prob
add-near-fr-prob
0
1
0.25
0.01
1
NIL
HORIZONTAL

INPUTBOX
819
1023
963
1083
input-filename
synth-4500-1.csv
1
0
String

SLIDER
815
867
987
900
init-network-loop
init-network-loop
0
50
10
1
1
NIL
HORIZONTAL

SWITCH
982
1017
1084
1050
habit-on?
habit-on?
0
1
-1000

SWITCH
1024
874
1137
907
homophily?
homophily?
0
1
-1000

SWITCH
763
905
853
938
trace?
trace?
1
1
-1000

@#$#@#$#@
Release version 2. with minor bug fixes and new options and sliders

## WHAT IS IT?

This is intended as a “Data Integration Model” (Edmonds 2010b).  That is a consistent, detailed and dynamic description, in the form of an agent-based simulation, of the available evidence concerning the question of why people bother to vote.  This integrates a variety of kinds and qualities of evidence, from source data and statistics to more qualitative evidence in the form of interviews.  The model is being developed following a “KIDS” rather than a “KISS” methodology, that is, it aims to be more guided by the available evidence rather than simplicity (Edmonds & Moss 2005).

Thus this is a complex model, with many different social processes interweaving.  Although not specifically designed as such, it turns out that the model has distinct "layers" - that is aspects of the model that affect "higher" layers but with only weak feedback loops "downwards".  These are:

1. The input data which initialises the agents in new households (either at the start or in-coming households)
1. The demographic processes: immigration, emmigration, partnering, birth, death, separation, ageing etc.
1. The social network that develops and changes between agents (representing a relationship that would allow a political discussion if the agents were so minded)
1. The social influence via political discussions that can occur over the network links
1. The decisions and processes which determine whether agents vote or not

This Info tab can only give a brief introduction, for a fuller description see the associated documentation.

The purpose of this model is to enable the exploration of some social processes behind voter turnout, including demographic trends in household size and composition, social influence via the social networks the individuals are embedded within, wider social norms such as civic duty, personal habit and identity, as well as individual rationality.  This structure was designed to allow the relative priority and interaction of many different context-dependent social processes to be explored.  Thus this model is an explanatory model - it demonstrates the plausibility of (complicated) explanations of outcomes from the initial conditions, settings and processes in the model.

It is important to understand that this is NOT a simulation with free-parameters that are conditioned on some "in-sample" data.  It does have a lot of parameters, but these are set (or could be set) from empirical data.   The model is then run "as is" and can be compared with available data - to see how and where it matches this and when it does not.  Thus (unlike many models) it is not an attempt to 'fit' any data, but rather is a computational description to enable the 'detangling' and critique of various explanations of observed social behaviour.  

There are some paramters that are not directly empirical - scaling paramters that bridge between the scale of model events and what these might correspond to in real life - these have been set in order to get realistic distributions of ages, household sizes etc..  These are not set by a 'fitting' process but are the result of conscious choices by the modellers.

## HOW TO USE IT

1. Enter the names of the data file you wish to use (almost certainly one of the synthetic data files provided)
1. Enter the name of the file you wish measurements from the output of the data to be saved in.  The "when-calc-data?" determines how often data is saved (1=every tick, 2= every 2 ticks etc.).  Check "to-file?" is on - this switches on and off data saving. "sna-out?" determines whether each time the social network is output (as a separate file each time).  Warning: the model can generate a LOT of data and files if you let it!
1. Set the paramaters as desired (see associated documentation).
1. Press the "setup" button to initialise the model, 
1. then "step" for a single step, or "go" for continuous running.

The model will stop running when either the "go" button is "unpressed" or the year reaches the set "end-date"

## DOCUMENTATION

There are two main pieces of model documentation (a) an ODD description of the model, giving more detail of how it works, its parameters etc. and (b) a text documenting the assumptions behind the model, and the evidence for these.  These two are complementary: (a) is a top-down description of what the model is, (b) is more in the line of a specification of what the model should be like.

## INPUT DATA

The input data filename is entered in the "data-filname" field in the model interface.  This is necessary for the model to be able to run.

The model uses data to initialise households of agents in a realistic fashion. The data we have used in publications derives from the BHPS 1992 survey data.  This data file is available, but from the ????? at ?????.  To access it you will have to agree to its associated conditions of use.  We thus can not freely distribute it with the model.

To enable people to play with the model, we instead provide some synthetic data whose "individuals" are not connected to any living person, but have some of the characteristics of the BHPS-derived data file.  Three different synthetic files are provided with 1500, 3000 and 4500 househollds respectively, the filenames of these are: "synth-1500-1.csv", "synth-3000-1.csv", and "synth-4500-1.csv".

## PARAMATERS (REAL REFERENTS)

Some of the principle paramaters that have real referents (that is, in principle they could be determined from empirical data), include:

* drop-friend-prob: the probability a link is dropped in a year
* drop-activity-prob: the probability an activity membership (not work or school) is dropped each year
* prob-partner: the probability of forming a sexual partnership if single per year
* prob-move-near: when a household moves this is the probability it moves to the nearest empty patch rather than to a patch with similar neighbours to itself
* immigration-rate: percentage of population that immigrates from outside the UK into the model (and hence is randomly selected from the immigrants section of the BHPS file)
* int-immigration-rate: percentage of population that immigrates from inside the UK into the model (and hence is randomly selected from the re-mixed version of the BHPS file)
* emigration-rate: the rate (per year) that households leave the model
* dissim-of-empty: when judging if a neighbourhood contains similar households to self, this is how dissimilar an empty space is (thus a low value of this results in housholds seeking to move near empty spaces, a high value to avoid empty spaces)
* election-mobilisation-rate: the percentage of its supporters who are not intending to vote that a party tries to get to vote
* start-mobilisation: when party mobilisation starts
* end-mobilisation: when party mobilisation stops

For a fuller list of these, consult the documentation.

## PROCESS OPTIONS

These allow the turning on and off of various processes or structures and thus allows the comparison of the simulation behaviour with and without them.

* household-drag?: whether agents attempt to drag others to vote
* rand-convs?: if on means that political conversations happen at random and are not constrained by the social network
* p2p-influence?: switches whether the specific influence between discussants during the election period on their intention to vote can occur
* no-rat-voting?: turns off the calculative (or "rational") aspects of the decision wether to vote
* greys-vote?: whether those with no political inclination can vote (if they do they do so randomly)
* mob-once-ph?: whether mobilisation conversations only occur once to each household
* fof?: switches the friend-of-a-friend social link creation mechanism

Some of the other parameters can be used to implicitly switch processe on and off:

* influence rate: setting this to zero switches off all political conversation (apart from mobilisation conversations)
* prob-contacted: setting this to zero switches off mobilisation during elections
* major-election-period and minor-election-period: setting these to zero switches off elections
* immigration-rate and int-immigration-rate: setting these to zero switches off any incomers to model (warning may critically affect longer=term population levels)
* emmigration-rate: setting this to zero switches off any emigration model (warning may critically affect longer=term population levels)
* birth-mult: setting this to zero switches off any births (warning may critically affect longer=term population levels)
* death-mult: setting this to zero switches off any deaths (warning may critically affect longer=term population levels)
* prob-partner: setting this to zero switches off any partnering after initialisation (warning may critically affect longer=term population levels)
* separate-prob: setting this to zero switches off any separation of partners (warning may critically affect longer=term population levels)
* forget-mult: setting this to zero switches off any forgetting of conversations etc. by agents (warning will cause model to slow down as agent accumulate huge lists of memories)
* move-prob-mult: setting this to zero switches off any moviing within model 

## PARAMTERS EFFECTING THE INITIALISATION

* density: the initial density of households in the spaces left for them after schools etc. have been allocated
* majority-prop: the proportion of the initial population from the majority group
* init-move-prob: how many times households are moved in the initialisation (this produces a slightly more realistic starting point for the model with weak clustering)

## CONTROLLING THE SIMULATION RUN

* start-date: year simulation starts
* end-date: year simulation finishes
* ticks-per-year: how many simulation ticks are in each year – probabilities throughout the simulation are adjusted so that roughly the same will happen with different settings of this, so as to enable fast debugging runs with 1 tick per year before slower ones with 12.  However there will be subtle differences in model behaviour for different settings of this.
* to-file?: switches whether simluation saves statistics to the file given in "output-filename"
* when-calc-data?: determines when the simulation saves statistics and/or network data (1=every tick, 2=every two ticks, etc.)
* sna-out?: switches whether the simulation outputs the current social network (one file each time is does this!)

## SCALING PARAMETERS

* birth-mult: a scaling parameter that changes the birth rates uniformly
* death-mult: a scaling parameter that changes the death rates uniformly
* move-prob-mult: a scaling parameter that changes the probability of moving
* influence-rate: a scaling parameter determining the maximum number of chances to influence others each agent has each year (this will be realised by very few agents if any, but will have the effect of scaling the number of discussions agents who are politically interested agents have)
* forget-mult: a scaling parameter that changes the rate of forgetting

## THE VISUALISATION

The world is an (unwrapped) 2D grid of locations.  At each location is one of:

* empty
* a household of agents 
* a school (green flower)
* a place of work (brown truck)
* an activity of type 1 (maroon cross)
* an activity of type 2 (purple target)

Agents are always within a household, they are represented as objects inside with the following characteristics:

* colour - which party they are inclined to vote for (grey=none)
* size - indicates age
* shape - solid circle = majority population, triangle=visible minority, black-filled circle=invisible minority

(depending on show-friendships?) the links show the social network links of different types between agents:

* grey - within household links
* white - neighbourhood
* brown - work-related links
* green - school related links (e.g. both have kids at the same school)
* maroon - via activity of type 1
* purple - via activity of type 2

(depending on show-activity-memb?) the (lighter coloured) links show the membership of agents of:

* light green - a school (kids only)
* light brown - a place of work (employment)
* light maroon - membership of activity of type 1
* light purple - membership of activity of type 2

## MONITORS

The following monitors are present (some are repeated for ease of viewing due to the fact that the graphs spread over several screens worth):

* Year - The simulation year
* Month - The simulation month
* Tick - the simulation tick number (starting at 0)
* Sub-year Tick - The simulation tick number within a year (starting at 0)
* Av. Talk. Ends. - Average number of discussion memories in agent memories (if this becomes too long it can slow down the simulation)
* Av. Satis. Ends - Average number of statisifed/disatisfied memories in agent memories
* Av. Oth. Ends. - Average number of other memories
* Secs/tick - Length in seconds of each simulation tick
* Long Camp? - Is it during a long campaign occuring?
* Sh. Camp? - Is it during a short campaign occuring?
* Cam? - Is iany kind of campaign occuring?
* El. Tick - The week number of a campaign (starting at 1)
* Pop - The number of agents
* !st Gen - The number of 1st generation immigrant agents
* 2nd Gen - The number of 2nd generation immigrant agents
* Empty - How many locations are empty
* Vis Min - How many agents of the visible minority
* Inv Min - How many agents of the invisible minority
* Av HH Same - Average proportion of household links whose end agents voted for the same party
* Av Fr Same - Average proportion of any links whose end agents voted for the same party
* Link Dens - The link density (out of all possible links)
* Elect - The number of agents that are elidgible to bote
* Av HH voted - Average proportion of household links whose end agents are the same in wether they voted/did not vote
* Av Fr Voted - Average proportion of any links whose end agents are the same in wether they voted/did not vote
* Av Clus - average network clustering
* Pop - The number of agents
* Could Talk - Number of agents with interest level > 1 (so could initiate a discussion)
* Num Disc. - Number of discussions in the current tick
* Num Talk - Number of agents who did talk in the current tick
* Long? - Is it during a long campaign occuring?
* Week - The week number in the year
* Num Voted - The number of agents who voted
* Short? - Is it during a short campaign occuring?
* Elect - Is it dureing any kind of election?
* Num Mob - The expected number of agents who would newly vote due to mobilisation (ignoring confounding factors)

## TEXTUAL OUTPUT

The central text area follows the events in a single (randomly chosen infant) agent's life.  When that agent dies another (newly born) agent is chosen and followed.  This helps give an idea of what might be happening to individual agents.

## GRAPHS

Line graphs:

* Voting - shows the number of agents voting (black) and for each party (red, blue, yellow)
* Turnout by class - shows the proportion of elidgible agents of each class that vote
* Turnout by Ethnicity - shows the proportion of elidgible agents of each ethnic class that vote
* Turnout by Immigrant Gen - shows the proportion of elidgible agents of 1st, 2nd, other immigrant generation that vote
* Population - shows the number of agents of the majority ethnicity (black), visible minority (green) and invisible minority (blue)
* Interest Levels - show the number of agents with each level of political interest
* Numbers of Discussions - show the number of discussions in the current simulation tick: all (black), those that carried messages of civic duty (green), those initiatiated by agents with the highest level of political interest (red)
* Initial Voting Reasons - whether the kinds of reason were one of the reasons an agent voted (each agent might have multiple reasons to vote)
* Discussion Levels - the background levels of discussion noted in the home: number who notice politics (grey), those with some discussion in the home (pink), those with lots of discussion in the home (red)
* Confounding Factors - the number of agents effected by the various counfounding factors (some agents may be confounded in more than one way)
* Dragged by Numbers - the number of agents who are "dragged" to the polls by various categories of people (this only records the last cateory who dragged them)
* Inheritance of Party - the proportion of agents with parents who have the same political inclination as the (black) domminant parent (one with highest class), (grey) non-dominant parent, (red) of thosse with political inclinations of non-dominant parent
* Proportion Adults Switched - the proportion of kinds of agent who have switched political leanings: any (black), those who have a different class to that of their dominant parent (red), those who are the same class as their dominant parent
* Political Leanings - number of agents with different political inclincations: none (grey) and for the three parties (red, blue, yellow)
* Moving Reasons (adults per year) - number of adults moving per year and the reason
* Number Influenced each Tick (during campaigns) - number of agents whose voting intention probability is changed during the short phase of an election campaign: through direct mobilisation (red), through subsequent, 2nd order person-to-person influence (green) [Not these graphs do not include week when the short campaign is not running]
* Campaign Messages (only during campaigns) - number of mobilisation discussions during: long (grey) and short (black) phases of an election campaign
* Intention Change each Tick (during campaigns) - The expected number of extra voters due to direct (red) and indirect (green) impact of mobilisation campaign [only during short phase of election campaigns]

Histograms:

* Age Distrbution - The distribution of agent ages
* Household Size Dist - the distribution of household sizes
* Discussant Connections (Adults) - the distribution of number of social links each agent has (adults only)
* FOF Dist (Adults) - the distribution of the proportion of those linked to each agent who are linked to each other (adults only)
* Class Distribution - distribution of classes
* Numb Discussions - districution of numbers of discussions each agent has
* Distribution of Post-18 edu - numbers of agents with post-18 eduction in each class
* Class party preference - numbers in each class who vote for each party
* Intentions Dist - the distribution of intentions to vote (a probability) during the short phase of an election campaighn

## CREDITS AND REFERENCES

http://scid-project.org
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
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="default settings" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>run-id</metric>
    <metric>ticks</metric>
    <metric>year</metric>
    <metric>month</metric>
    <metric>week</metric>
    <metric>long-campaign?</metric>
    <metric>short-campaign?</metric>
    <metric>election-tick-num</metric>
    <metric>election?</metric>
    <metric>prob-contacted * contact-mult</metric>
    <metric>influence-rate</metric>
    <metric>household-drag?</metric>
    <metric>pop-size</metric>
    <metric>electorate</metric>
    <metric>num-voting</metric>
    <metric>num-would-vote</metric>
    <metric>turnout</metric>
    <metric>turnout-maj</metric>
    <metric>turnout-min</metric>
    <metric>turnout-imm</metric>
    <metric>turnout-nonimm</metric>
    <metric>av-age</metric>
    <metric>sd-age</metric>
    <metric>av-hsize</metric>
    <metric>sd-hsize</metric>
    <metric>av-adfriends</metric>
    <metric>sd-adfriends</metric>
    <metric>prop-maj</metric>
    <metric>prop-inv-min</metric>
    <metric>prop-vis-min</metric>
    <metric>prop-adult</metric>
    <metric>prop-1stgen</metric>
    <metric>prop-2ndgen</metric>
    <metric>prop-nonempty-n</metric>
    <metric>prop-sim-n</metric>
    <metric>prop-sim-fr</metric>
    <metric>link-dens</metric>
    <metric>av-clust</metric>
    <metric>num-isolates</metric>
    <metric>av-fr-samevote</metric>
    <metric>av-fr-whvoted</metric>
    <metric>av-hh-samevote</metric>
    <metric>av-hh-whvoted</metric>
    <metric>red-voters</metric>
    <metric>blue-voters</metric>
    <metric>yellow-voters</metric>
    <metric>no-voters</metric>
    <metric>num-adult-involved</metric>
    <metric>num-adult-interested</metric>
    <metric>num-adult-view-taking</metric>
    <metric>num-adult-noticing</metric>
    <metric>num-adult-not-noticing</metric>
    <metric>num-voting-for-civic-duty</metric>
    <metric>num-voting-for-generalised-habit</metric>
    <metric>num-voting-for-dragging</metric>
    <metric>num-voting-for-rational-considerations</metric>
    <metric>num-voting-for-civic-duty-main</metric>
    <metric>num-voting-for-generalised-habit-main</metric>
    <metric>num-voting-for-dragging-main</metric>
    <metric>num-voting-for-rational-considerations-main</metric>
    <metric>num-dragged-to-vote-by-partner</metric>
    <metric>num-dragged-to-vote-by-interested-family</metric>
    <metric>num-dragged-to-vote-by-friend</metric>
    <metric>num-dragged-to-vote-by-civic-dutiful-or-involved-family</metric>
    <metric>turnout-18-21</metric>
    <metric>turnout-22-30</metric>
    <metric>turnout-31-45</metric>
    <metric>turnout-46-65</metric>
    <metric>turnout-66-75</metric>
    <metric>turnout-76+</metric>
    <metric>num-with-0-friends</metric>
    <metric>num-with-1-5-friends</metric>
    <metric>num-with-6-10-friends</metric>
    <metric>num-with-11+friends</metric>
    <metric>num-short-campaign-messages</metric>
    <metric>num-long-campaign-messages</metric>
    <metric>num-intention-influenced-mb-all</metric>
    <metric>sum-intention-increased-mb-all</metric>
    <metric>num-intention-influenced-p2p-all</metric>
    <metric>sum-intention-increased-p2p-all</metric>
    <metric>num-intention-influenced-mb-grey</metric>
    <metric>sum-intention-increased-mb-grey</metric>
    <metric>num-intention-influenced-p2p-grey</metric>
    <metric>sum-intention-increased-p2p-grey</metric>
    <metric>num-mb-influenced</metric>
    <metric>num-cascade-influenced</metric>
    <metric>cum-num-mob-withgrey</metric>
    <metric>cum-num-mob-withoutgrey</metric>
    <metric>num-voting-withgrey</metric>
    <metric>num-voting-withoutgrey</metric>
    <metric>cum-num-mob-voted-withgrey</metric>
    <metric>cum-num-mob-voted-withoutgrey</metric>
    <metric>pop-adults</metric>
    <metric>pop-just-imm</metric>
    <metric>num-cd</metric>
    <metric>num-cd-base</metric>
    <metric>num-cd-imm</metric>
    <metric>imm-1stgen-size</metric>
    <metric>imm-2ndgen-size</metric>
    <enumeratedValueSet variable="output-filename">
      <value value="&quot;default settings&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-mult">
      <value value="1.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="checking-on?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contact-mult">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death-mult">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density">
      <value value="0.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dissim-of-empty">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drop-activity-prob">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drop-friend-prob">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emmigration-rate">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-date">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fof?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fof-prob">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="forget-mult">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="greys-vote?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habit-on?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-drag?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="immigration-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influence-rate">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-move-prob">
      <value value="1.44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-network-loop">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-filename">
      <value value="&quot;synth-4500-1.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="major-election-length">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="major-election-period">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="major-election-short-len">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority-prop">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="make-link-mult">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minor-election-length">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minor-election-period">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="move-prob-mult">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-rat-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p2p-influence?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-contacted">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-move-near">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-partner">
      <value value="0.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="satisfied-min">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="satisfied-remb">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seperate-prob">
      <value value="0.0050"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-activity-memb?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-friendships?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sna-out?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="someone-talk-politics-min">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="someone-talk-politics-remb">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-date">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="talk-about-politics-min">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="talk-about-politics-remb">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticks-per-year">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="to-file?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uk-inflow-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voted-min">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voted-remb">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-calc-data?">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-size">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="SA inflence-rate" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>run-id</metric>
    <metric>ticks</metric>
    <metric>year</metric>
    <metric>month</metric>
    <metric>week</metric>
    <metric>long-campaign?</metric>
    <metric>short-campaign?</metric>
    <metric>election-tick-num</metric>
    <metric>election?</metric>
    <metric>prob-contacted * contact-mult</metric>
    <metric>influence-rate</metric>
    <metric>household-drag?</metric>
    <metric>pop-size</metric>
    <metric>electorate</metric>
    <metric>num-voting</metric>
    <metric>num-would-vote</metric>
    <metric>turnout</metric>
    <metric>turnout-maj</metric>
    <metric>turnout-min</metric>
    <metric>turnout-imm</metric>
    <metric>turnout-nonimm</metric>
    <metric>av-age</metric>
    <metric>sd-age</metric>
    <metric>av-hsize</metric>
    <metric>sd-hsize</metric>
    <metric>av-adfriends</metric>
    <metric>sd-adfriends</metric>
    <metric>prop-maj</metric>
    <metric>prop-inv-min</metric>
    <metric>prop-vis-min</metric>
    <metric>prop-adult</metric>
    <metric>prop-1stgen</metric>
    <metric>prop-2ndgen</metric>
    <metric>prop-nonempty-n</metric>
    <metric>prop-sim-n</metric>
    <metric>prop-sim-fr</metric>
    <metric>link-dens</metric>
    <metric>av-clust</metric>
    <metric>num-isolates</metric>
    <metric>av-fr-samevote</metric>
    <metric>av-fr-whvoted</metric>
    <metric>av-hh-samevote</metric>
    <metric>av-hh-whvoted</metric>
    <metric>red-voters</metric>
    <metric>blue-voters</metric>
    <metric>yellow-voters</metric>
    <metric>no-voters</metric>
    <metric>num-adult-involved</metric>
    <metric>num-adult-interested</metric>
    <metric>num-adult-view-taking</metric>
    <metric>num-adult-noticing</metric>
    <metric>num-adult-not-noticing</metric>
    <metric>num-voting-for-civic-duty</metric>
    <metric>num-voting-for-generalised-habit</metric>
    <metric>num-voting-for-dragging</metric>
    <metric>num-voting-for-rational-considerations</metric>
    <metric>num-voting-for-civic-duty-main</metric>
    <metric>num-voting-for-generalised-habit-main</metric>
    <metric>num-voting-for-dragging-main</metric>
    <metric>num-voting-for-rational-considerations-main</metric>
    <metric>num-dragged-to-vote-by-partner</metric>
    <metric>num-dragged-to-vote-by-interested-family</metric>
    <metric>num-dragged-to-vote-by-friend</metric>
    <metric>num-dragged-to-vote-by-civic-dutiful-or-involved-family</metric>
    <metric>turnout-18-21</metric>
    <metric>turnout-22-30</metric>
    <metric>turnout-31-45</metric>
    <metric>turnout-46-65</metric>
    <metric>turnout-66-75</metric>
    <metric>turnout-76+</metric>
    <metric>num-with-0-friends</metric>
    <metric>num-with-1-5-friends</metric>
    <metric>num-with-6-10-friends</metric>
    <metric>num-with-11+friends</metric>
    <metric>num-short-campaign-messages</metric>
    <metric>num-long-campaign-messages</metric>
    <metric>num-intention-influenced-mb-all</metric>
    <metric>sum-intention-increased-mb-all</metric>
    <metric>num-intention-influenced-p2p-all</metric>
    <metric>sum-intention-increased-p2p-all</metric>
    <metric>num-intention-influenced-mb-grey</metric>
    <metric>sum-intention-increased-mb-grey</metric>
    <metric>num-intention-influenced-p2p-grey</metric>
    <metric>sum-intention-increased-p2p-grey</metric>
    <metric>num-mb-influenced</metric>
    <metric>num-cascade-influenced</metric>
    <metric>cum-num-mob-withgrey</metric>
    <metric>cum-num-mob-withoutgrey</metric>
    <metric>num-voting-withgrey</metric>
    <metric>num-voting-withoutgrey</metric>
    <metric>cum-num-mob-voted-withgrey</metric>
    <metric>cum-num-mob-voted-withoutgrey</metric>
    <metric>pop-adults</metric>
    <metric>pop-just-imm</metric>
    <metric>num-cd</metric>
    <metric>num-cd-base</metric>
    <metric>num-cd-imm</metric>
    <metric>imm-1stgen-size</metric>
    <metric>imm-2ndgen-size</metric>
    <enumeratedValueSet variable="output-filename">
      <value value="&quot;SA inflence-rate&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-mult">
      <value value="1.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="checking-on?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="contact-mult">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="death-mult">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density">
      <value value="0.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dissim-of-empty">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drop-activity-prob">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="drop-friend-prob">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="emmigration-rate">
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="end-date">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fof?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fof-prob">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="forget-mult">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="greys-vote?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habit-on?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="homophily?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="household-drag?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="immigration-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="influence-rate">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-move-prob">
      <value value="1.44"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="init-network-loop">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-filename">
      <value value="&quot;synth-4500-1.csv&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="major-election-length">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="major-election-period">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="major-election-short-len">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="majority-prop">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="make-link-mult">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minor-election-length">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minor-election-period">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="move-prob-mult">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="no-rat-voting?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p2p-influence?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-contacted">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-move-near">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-partner">
      <value value="0.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="satisfied-min">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="satisfied-remb">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seperate-prob">
      <value value="0.0050"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-activity-memb?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-friendships?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sna-out?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="someone-talk-politics-min">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="someone-talk-politics-remb">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-date">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="talk-about-politics-min">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="talk-about-politics-remb">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticks-per-year">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="to-file?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uk-inflow-rate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voted-min">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="voted-remb">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="when-calc-data?">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world-size">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
