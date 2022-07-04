extensions[nw]

breed [candidates candidate] ;; people who are in some electoral list; obviously, they never change their preference.
breed[people person] ;; the simple citizen who must chose a preference.

globals [
  A_other ;; this variable is a consequence of the other ones' value.
  B_other ;; this variable is a consequence of the other ones' value.
  C_other ;; this variable is a consequence of the other ones' value.
]

people-own [
  impartial? ;; person who has no preference
  A_side? ;; person who will vote for Mayor A in the election
  B_side? ;; person who will vote for Mayor B in the election
  C_side? ;; person who will vote for Mayor C in the election
  charisma
  cogency
  weakness ;; how susceptible each person is to being convinced.
  social ;; il peso che ogni persona da alle iterazioni sociali.
  young? ;; if a person is younger than 35.
  senior? ;; if a person is older than 65.
  satisfied? ;; person who is satisfied of the current Mayor.
  dissatisfied? ;; person who is not satisfied of the current Mayor.
  ;; The utility function of each person is a linear combination of the variables of each mayor and the coefficients
  ;; (weights) representing the importance (in percentage) that each person gives to each variable.
  A_utility ;; utility function calculated on the mayor's choices of variable values A.
  B_utility ;; utility function calculated on the mayor's choices of variable values B.
  C_utility ;; utility function calculated on the mayor's choices of variable values C.
  p1 ;; the weight that each person gives to job varible.
  p2 ;; the weight that each person gives to tax varible.
  p3 ;; the weight that each person gives to reg (urban regeneration) varible.
  p4 ;; the weight that each person gives to vis (visibility of town) varible.
  p5 ;; the weight that each person gives to others varibles.
]

candidates-own[
  impartial? ;; person who has no preference
  A_side? ;; person who will vote for Mayor A in the election
  B_side? ;; person who will vote for Mayor B in the election
  C_side? ;; person who will vote for Mayor C in the election
  charisma
  cogency
  weakness ;; how susceptible each person is to being convinced.
  social ;; il peso che ogni persona da alle iterazioni sociali
  A_utility ;; utility function calculated on the mayor's choices of variable values A.
  B_utility ;; utility function calculated on the mayor's choices of variable values B
  C_utility ;; utility function calculated on the mayor's choices of variable values C.
]

to setup
  clear-all
  set A_other 0
  set B_other 0
  set C_other 0
  if (perc_youth + perc_seniority > 100)
  [
    user-message (word
      "The sum of perc_youth and perc_seniority "
      "should not be greater than 100.")
    stop
  ]
  if (perc_satisfied + perc_dissatisfied > 100)
  [
    user-message (word
      "The sum of perc_satisfied and perc_dissatisfied "
      "should not be greater than 100.")
    stop
  ]
  if A_job + A_tax + A_reg + A_vis > 100
  [
    user-message (word
      "The sum of A_job, A_tax, A_reg, A_vis and A_other "
      "should not be greater than 100.")
    stop
  ]
  if B_job + B_tax + B_reg + B_vis > 100
  [
    user-message (word
      "The sum of B_job, B_tax, B_reg, B_vis and B_other "
      "should not be greater than 100.")
    stop
  ]
  if C_job + C_tax + C_reg + C_vis > 100 [
    user-message (word
      "The sum of C_job, C_tax, C_reg, C_vis and C_other "
      "should not be greater than 100.")
    stop
  ]
  if A_job + A_tax + A_reg + A_vis < 100
  [
    set A_other 100 - (A_job + A_tax + A_reg + A_vis)
  ]
  if B_job + B_tax + B_reg + B_vis < 100
  [
    set B_other 100 - (B_job + B_tax + B_reg + B_vis)
  ]
  if C_job + C_tax + C_reg + C_vis < 100
  [
    set C_other 100 - (C_job + C_tax + C_reg + C_vis)
  ]
  setup-people
  setup-spatially-clustered-network
  ask links
  [
    set color white
  ]
  if (show-initial-preferences = TRUE)
  [
    choose-preference
  ]
  reset-ticks
end

to random-setup
  clear-all
  if (perc_youth + perc_seniority > 100)
  [
    user-message (word
      "The sum of perc_youth and perc_seniority "
      "should not be greater than 100.")
    stop
  ]
  if (perc_satisfied + perc_dissatisfied > 100)
  [
    user-message (word
      "The sum of perc_satisfied and perc_dissatisfied "
      "should not be greater than 100.")
    stop
  ]
  set-random-percentage
  setup-people
  setup-spatially-clustered-network
  ask links
  [
    set color white
  ]
  if (show-initial-preferences = TRUE)
  [
    choose-preference
  ]
  reset-ticks
end

;; the 'random setup' procedure randomly sets the percentage values assigned to the variables of each mayor.

to go
  choose-preference
  influence
  tick-advance 0.3
  update-plots
end

to set-random-percentage
  set A_job 50
  set A_tax 50
  set A_reg 50
  set A_vis 50
  while [A_job + A_tax + A_reg + A_vis >= 100]
  [
    set A_job random 100
    set A_tax random 100
    set A_reg random 100
    set A_vis random 100
    set A_other (100 - A_job - A_tax - A_reg - A_vis)
  ]
  set B_job 50
  set B_tax 50
  set B_reg 50
  set B_vis 50
  while [B_job + B_tax + B_reg + B_vis >= 100]
  [
    set B_job random 100
    set B_tax random 100
    set B_reg random 100
    set B_vis random 100
    set B_other (100 - B_job - B_tax - B_reg - B_vis)
  ]
  set C_job 50
  set C_tax 50
  set C_reg 50
  set C_vis 50
  while [C_job + C_tax + C_reg + C_vis >= 100]
  [
    set C_job random 100
    set C_tax random 100
    set C_reg random 100
    set C_vis random 100
    set C_other (100 - C_job - C_tax - C_reg - C_vis)
  ]
end

;; The 'set-random-percentage' procedure focuses on setting the 'other' variables in such a way that the sum of
;; the percentages of all variables for each mayor equals 100.

to setup-people
  set-default-shape turtles "person"
  ;; with the following procedure we create the people who will choose a preference.
  create-people (number-of-citizens - initial_A_side - initial_B_side - initial_C_side)
  [
    setxy (random-xcor * 0.95) (random-ycor * 0.95) ;; multipling by 0.95 for not to be too close to the edge
    set size 1.5
    become-impartial ;; at the time it is generated, each person is set, for simplicity's sake, impartial.
    set young? false ;; at the time it is generated, each person is set, for simplicity's sake, not young.
    set senior? false ;; at the time it is generated, each person is set, for simplicity's sake, not senior.
  ]
  ;; We now set the desired number of young and old people.
  ask n-of (perc_youth / 100 * count people) people
  [
    become-young
  ]
  ask n-of (perc_seniority / 100 * count people) people with [young? = FALSE]
  [
    become-senior
  ]
  ;; with the following procedure, we create the people who belong to the electoral list of Mayor A.
  create-candidates initial_A_side
  [
    setxy (random-xcor * 0.95) (random-ycor * 0.95) ;; multipling by 0.95 for not to be too close to the edge
    set size 1.5
    become-A_side
    set A_utility 100
    set B_utility 0
    set C_utility 0
  ]
  ;; with the following procedure, we create the people who belong to the electoral list of Mayor B.
  create-candidates initial_B_side
  [
    setxy (random-xcor * 0.95) (random-ycor * 0.95) ;; multipling by 0.95 for not to be too close to the edge
    set size 1.5
    become-B_side
    set A_utility 0
    set B_utility 100
    set C_utility 0
  ]
  ;; with the following procedure, we create the people who belong to the electoral list of Mayor C.
  create-candidates initial_C_side
  [
    setxy (random-xcor * 0.95) (random-ycor * 0.95) ;; multipling by 0.95 for not to be too close to the edge
    set size 1.5
    become-C_side
    set A_utility 0
    set B_utility 0
    set C_utility 100
  ]
  ;; with the following procedure we ask people to choose an initial preference based on their age and the weights
  ;; they each give to the variables.
  ask people
  [
    if (young? = TRUE)
    [
      setup-preference-youth
    ]
    if (senior? = TRUE)
    [
      setup-preference-seniority
    ]
    if (senior? = FALSE and young? = FALSE)
    [
      setup-preference
    ]
    set A_utility (p1 * A_job / 10 + p2 * A_tax / 10 + p3 * A_reg / 10 + p4 * A_vis / 10 + p5 * A_other / (number-other-variables * 10))
    set B_utility (p1 * B_job / 10 + p2 * B_tax / 10 + p3 * B_reg / 10 + p4 * B_vis / 10 + p5 * B_other / (number-other-variables * 10))
    set C_utility (p1 * C_job / 10 + p2 * C_tax / 10 + p3 * C_reg / 10 + p4 * C_vis / 10 + p5 * C_other / (number-other-variables * 10))
  ]
  ask turtles
  [
    set charisma random-float 1
    set cogency ( nw:eigenvector-centrality + charisma ) ;; congency feature for each person is made up of his notoriety
                                                         ;; (eigenvector centrality) and his cherisma.
    set weakness (random-float 1)
    set social (random-float 1) ;;
  ]
  ;; in the event that one of the three candidate mayors is the current mayor, the satisfied persons will have an increase in the
  ;; corresponding utility function of an addend that can at most reach a value of 10 (as well as all other addends of the utility
  ;; function).
  if (current_mayor? = TRUE)
  [
    ask people [
      set satisfied? false
      set dissatisfied? false
    ]
    ask n-of (perc_satisfied / 100 * count people) people
    [
      become-satisfied
    ]
    ask n-of (perc_dissatisfied / 100 * count people) people with [satisfied? = FALSE]
    [
      become-dissatisfied
    ]
    if (current_mayor = "A")
    [
      ask people with [satisfied?]
      [
        let satisfaction_value random-float 10
        set A_utility (A_utility + satisfaction_value)
      ]
      ask people with [dissatisfied?]
      [
        let dissatisfaction_value random-float 10
        set A_utility (A_utility - dissatisfaction_value)
      ]
    ]
    if (current_mayor = "B")
    [
      ask people with [satisfied?]
      [
        let satisfaction_value random-float 10
        set B_utility (B_utility + satisfaction_value)
      ]
      ask people with [dissatisfied?]
      [
        let dissatisfaction_value random-float 10
        set B_utility (B_utility - dissatisfaction_value)
      ]
    ]
    if (current_mayor = "C")
    [
      ask people with [satisfied?]
      [
        let satisfaction_value random-float 10
        set C_utility (C_utility + satisfaction_value)
      ]
      ask people with [dissatisfied?]
      [
        let dissatisfaction_value random-float 10
        set C_utility (C_utility - dissatisfaction_value)
      ]
    ]
  ]
end

;; the following procedures generate the coefficients (weights) that each person gives to each variable, they differ from each other based on
;; the age of the persons. The procedures are such that the sum of the percentages equals 100.

to setup-preference
  set p1 0.5
  set p2 0.5
  set p3 0.5
  set p4 0.5
  while [p1 + p2 + p3 + p4 >= 1] ;; older people give more weight to urban regeneration variable than job and visibility ones.
  [
    set p1 random-float 1 ;; weight associated to job variable
    set p2 random-float 1 ;; weight associated to tax variable
    set p3 random-float 1 ;; weight associated to urban regeneration variable
    set p4 random-float 1 ;; weight associated to visibility variable
    set p5 (1 - p1 - p2 - p3 - p4) ;; weight associated to other variable
  ]
end

to setup-preference-seniority
  set p1 0.5
  set p2 0.5
  set p3 0.5
  set p4 0.5
  while [p1 + p2 + p3 + p4 >= 1 or p3 <= p1 or p3 <= p4] ;; older people give more weight to urban regeneration variable than job
  [                                                      ;; and visibility ones.
    set p1 random-float 1 ;; weight associated to job variable
    set p2 random-float 1 ;; weight associated to tax variable
    set p3 random-float 1 ;; weight associated to urban regeneration variable
    set p4 random-float 1 ;; weight associated to visibility variable
    set p5 (1 - p1 - p2 - p3 - p4) ;; weight associated to other variable
  ]
end

to setup-preference-youth
  set p1 0.5
  set p2 0.5
  set p3 0.5
  set p4 0.5
  while [p1 + p2 + p3 + p4 >= 1 or p1 <= p3 or p4 <= p3] ;; the youth give more weight to job and visibility variables than urban regeneration one.
  [
    set p1 random-float 1 ;; weight associated to job variable
    set p2 random-float 1 ;; weight associated to tax variable
    set p3 random-float 1 ;; weight associated to urban regeneration variable
    set p4 random-float 1 ;; weight associated to visibility variable
    set p5 (1 - p1 - p2 - p3 - p4) ;; weight associated to other variable
  ]
end

to setup-spatially-clustered-network
  let num-links (average-node-degree * number-of-citizens) / 2
  while [count links < num-links ]
  [
    ask one-of turtles
    [
      let choice (min-one-of (other turtles with [not link-neighbor? myself])
                   [distance myself])
      if choice != nobody [ create-link-with choice ]
    ]
  ]
end

to choose-preference
  ask people
  [
    ifelse (A_utility > B_utility)
    [
      ifelse (A_utility > C_utility)
      [
        become-A_side
      ]
      [
        become-C_side
      ]
    ]
    [
      ifelse (B_utility > C_utility)
      [
        become-B_side
      ]
      [
        become-C_side
      ]
    ]
    if (
      abs (A_utility - B_utility) <= (p1 + p2 + p3 + p4 + p5) / 5 or
      abs (C_utility - B_utility) <= (p1 + p2 + p3 + p4 + p5) / 5 or
      abs (A_utility - B_utility) <= (p1 + p2 + p3 + p4 + p5) / 5 )
    [
      become-impartial
    ]
  ]
end

;; the 'choise-preference' procedure makes people rational. In fact, they satisfy the completeness property, i.e. they are able to choose their preference for each pair of values
;; assumed by the utility functions, and the transitive property.

to influence
  ask people with [A_side?]
  [
    ask n-of ceiling (count link-neighbors * influence-neighbors / 100) link-neighbors
    [
      if ([weakness] of self < [cogency] of myself)
      [
        set A_utility (A_utility + (social) * ([cogency] of myself - [weakness] of self)); each person update his utility functions based on the influence of his neighbors
      ]
    ]
  ]
  ask people with [B_side?]
  [
    ask n-of ceiling (count link-neighbors * influence-neighbors / 100) link-neighbors
    [
      if ([weakness] of self < [cogency] of myself)
      [
        set B_utility (B_utility + (social) * ([cogency] of myself - [weakness] of self)); each person update his utility functions based on the influence of his neighbors
      ]
    ]
  ]
  ask people with [C_side?]
  [
    ask n-of ceiling (count link-neighbors * influence-neighbors / 100) link-neighbors
    [
      if ([weakness] of self < [cogency] of myself)
      [
        set C_utility (C_utility + (social) * ([cogency] of myself - [weakness] of self)); each person update his utility functions based on the influence of his neighbors
      ]
    ]
  ]
end

;; the 'influence' procedure initiates influence between people. Influence between two individuals is successful if the 'cogency' value of the person to be convinced
;; exceeds the 'weakness' value of the target person.

to watch-most-influential
  ask max-one-of turtles [cogency]
  [
    set size 2 watch-me
  ]
end

;; the following procedure emulates a situation in which news of a scandal concerning one of the mayors running for office (whether it is real news or fake-news) comes into the town.

to scandal
  if (mayor_scandal = "A")
  [
    if (scandal-intesity = "low")
    [
      ask n-of (scandal-popularity / 100 * count people) people
      [
        let scandal-value (25 / 100 * A_utility)
        set A_utility (A_utility - random-float scandal-value) ;; a low scandal could decrease a voter's interest in a mayor A by at most 25 percent of the initial interest.
      ]
    ]
    if (scandal-intesity = "medium")
    [
      ask n-of (scandal-popularity / 100 * count people) people
      [
        let scandal-value (50 / 100 * A_utility)
        set A_utility (A_utility - random-float scandal-value) ;; a medium scandal could decrease a voter's interest in a mayor A by at most 50 percent of the initial interest.
      ]
    ]
    if (scandal-intesity = "high")
    [
      ask n-of (scandal-popularity / 100 * count people) people
      [
        let scandal-value (80 / 100 * A_utility)
        set A_utility (A_utility - random-float scandal-value) ;; a high scandal could decrease a voter's interest in a mayor A by at most 80 percent of the initial interest.
      ]
    ]
  ]
  if (mayor_scandal = "B")
  [
    if (scandal-intesity = "low")
    [
      ask n-of (scandal-popularity / 100 * count people) people
      [
        let scandal-value (25 / 100 * B_utility)
        set B_utility (B_utility - random-float scandal-value) ;; a low scandal could decrease a voter's interest in a mayor B by at most 25 percent of the initial interest.
      ]
    ]
    if (scandal-intesity = "medium")
    [
      ask n-of (scandal-popularity / 100 * count people) people
      [
        let scandal-value (50 / 100 * B_utility)
        set B_utility (B_utility - random-float scandal-value) ;; a medium scandal could decrease a voter's interest in a mayor B by at most 50 percent of the initial interest.
      ]
    ]
    if (scandal-intesity = "high")
    [
      ask n-of (scandal-popularity / 100 * count people) people
      [
        let scandal-value (80 / 100 * B_utility)
        set B_utility (B_utility - random-float scandal-value) ;; a high scandal could decrease a voter's interest in a mayor B by at most 80 percent of the initial interest.
      ]
    ]
  ]
  if (mayor_scandal = "C")
  [
    if (scandal-intesity = "low")
    [
      ask n-of (scandal-popularity / 100 * count people) people
      [
        let scandal-value (25 / 100 * C_utility)
        set C_utility (C_utility - random-float scandal-value) ;; a low scandal could decrease a voter's interest in a mayor C by at most 25 percent of the initial interest.
      ]
    ]
    if (scandal-intesity = "medium")
    [
      ask n-of (scandal-popularity / 100 * count people) people
      [
        let scandal-value (50 / 100 * C_utility)
        set C_utility (C_utility - random-float scandal-value) ;; a medium scandal could decrease a voter's interest in a mayor C by at most 50 percent of the initial interest.
      ]
    ]
    if (scandal-intesity = "high")
    [
      ask n-of (scandal-popularity / 100 * count people) people
      [
        let scandal-value (80 / 100 * C_utility)
        set C_utility (C_utility - random-float scandal-value) ;; a high scandal could decrease a voter's interest in a mayor C by at most 80 percent of the initial interest.
      ]
    ]
  ]
end

to become-satisfied
  set satisfied? true
  set dissatisfied? false
end

to become-dissatisfied
  set satisfied? false
  set dissatisfied? true
end

to become-young
  set young? true
  set senior? false
end

to become-senior
  set young? false
  set senior? true
end

to become-impartial
  set impartial? true
  set A_side? false
  set B_side? false
  set C_side? false
  set color blue
end

to become-A_side
  set impartial? false
  set A_side? true
  set B_side? false
  set C_side? false
  set color red
end

to become-B_side
  set impartial? false
  set A_side? false
  set B_side? true
  set C_side? false
  set color yellow
end

to become-C_side
  set impartial? false
  set A_side? false
  set B_side? false
  set C_side? true
  set color green
end
@#$#@#$#@
GRAPHICS-WINDOW
400
10
1878
907
-1
-1
14.56
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
-30
30
0
0
1
ticks
30.0

SLIDER
0
43
198
76
initial_A_side
initial_A_side
4
20
13.0
1
1
NIL
HORIZONTAL

BUTTON
200
755
318
804
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

SLIDER
0
10
399
43
number-of-citizens
number-of-citizens
500
1500
785.0
5
1
NIL
HORIZONTAL

SLIDER
199
76
399
109
average-node-degree
average-node-degree
5
25
13.0
1
1
NIL
HORIZONTAL

SLIDER
0
76
199
109
initial_B_side
initial_B_side
4
20
14.0
1
1
NIL
HORIZONTAL

SLIDER
198
43
399
76
initial_C_side
initial_C_side
4
20
12.0
1
1
NIL
HORIZONTAL

SLIDER
0
606
200
639
A_job
A_job
0
100
15.0
1
1
%
HORIZONTAL

SLIDER
0
639
200
672
B_job
B_job
0
100
15.0
1
1
%
HORIZONTAL

SLIDER
0
672
200
705
C_job
C_job
0
100
19.0
1
1
%
HORIZONTAL

SLIDER
200
606
399
639
A_tax
A_tax
0
100
36.0
1
1
%
HORIZONTAL

SLIDER
0
705
200
738
A_reg
A_reg
0
100
5.0
1
1
%
HORIZONTAL

SLIDER
0
804
200
837
A_vis
A_vis
0
100
30.0
1
1
%
HORIZONTAL

SLIDER
200
639
399
672
B_tax
B_tax
0
100
44.0
1
1
%
HORIZONTAL

SLIDER
200
672
399
705
C_tax
C_tax
0
100
17.0
1
1
%
HORIZONTAL

SLIDER
0
738
200
771
B_reg
B_reg
0
100
14.0
1
1
%
HORIZONTAL

SLIDER
0
771
200
804
C_reg
C_reg
0
100
33.0
1
1
%
HORIZONTAL

SLIDER
0
837
200
870
B_vis
B_vis
0
100
11.0
1
1
%
HORIZONTAL

SLIDER
0
870
200
903
C_vis
C_vis
0
100
13.0
1
1
%
HORIZONTAL

BUTTON
318
755
399
804
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
0

PLOT
0
276
399
438
Temporary Scores
time
# scores
0.0
10.0
0.0
100.0
true
true
"" ""
PENS
"A_side" 1.0 0 -2674135 true "" "plot count turtles with [A_side?]"
"B_side" 1.0 0 -1184463 true "" "plot count turtles with [B_side?]"
"C_side" 1.0 0 -10899396 true "" "plot count turtles with [C_side?]"
"Impartial" 1.0 0 -13345367 true "" "plot count turtles with [impartial?]"

MONITOR
0
438
57
483
A_side
count turtles with [A_side?]
17
1
11

MONITOR
57
438
114
483
B_side
count turtles with [B_side?]
17
1
11

MONITOR
114
438
171
483
C_side
count turtles with [C_side?]
17
1
11

MONITOR
171
438
242
483
impartial
count turtles with [impartial?]
17
1
11

BUTTON
199
705
399
755
NIL
random-setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
211
483
305
528
% voters
(count (turtles with [A_side?]) + count (turtles with [B_side?]) + count (turtles with [C_side?])) / count turtles * 100
2
1
11

MONITOR
305
483
399
528
% no voters
count turtles with [impartial?] / count turtles * 100
2
1
11

SLIDER
0
142
399
175
influence-neighbors
influence-neighbors
0
100
80.0
1
1
%
HORIZONTAL

MONITOR
200
805
261
850
NIL
A_other
17
1
11

MONITOR
261
803
334
848
NIL
B_other
17
1
11

MONITOR
334
803
399
848
NIL
C_other
17
1
11

INPUTBOX
200
848
399
908
number-other-variables
6.0
1
0
Number

SWITCH
200
231
399
264
show-initial-preferences
show-initial-preferences
0
1
-1000

BUTTON
242
438
399
483
NIL
watch-most-influential
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
198
109
399
142
perc_youth
perc_youth
0
100
45.0
1
1
%
HORIZONTAL

SWITCH
0
176
200
209
current_mayor?
current_mayor?
1
1
-1000

CHOOSER
200
187
399
232
current_mayor
current_mayor
"A" "B" "C"
2

SLIDER
0
209
200
242
perc_satisfied
perc_satisfied
0
100
22.0
1
1
%
HORIZONTAL

SLIDER
0
242
200
275
perc_dissatisfied
perc_dissatisfied
0
100
35.0
1
1
%
HORIZONTAL

SLIDER
0
109
199
142
perc_seniority
perc_seniority
0
100
30.0
1
1
%
HORIZONTAL

MONITOR
0
483
104
528
young
count people with [young?]
17
1
11

MONITOR
104
483
211
528
senior
count people with [senior?]
17
1
11

BUTTON
200
573
399
606
scandal
scandal
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
0
528
200
561
scandal-popularity
scandal-popularity
0
100
60.0
1
1
%
HORIZONTAL

CHOOSER
200
528
399
573
mayor_scandal
mayor_scandal
"A" "B" "C"
2

CHOOSER
0
561
200
606
scandal-intesity
scandal-intesity
"low" "medium" "high"
2

@#$#@#$#@
## WHAT IS IT?

The model seeks to emulate the election campaign of three mayoral candidates in a municipality. Voting citizens, taken as rational individuals, will have to choose their preference, represented by the maximization of a linear utility function, among the three mayors. 

The model is constructed using the algebraic structure of an undirected graph, in which nodes represent each citizen and edges represent the ties between two people in the country (friendship, kinship, etc.). The concept of node centrality was also exploited, which is that property of each node that represents its importance in the graph.

## WHAT IS THE GOAL?

The goal of the model is to visualize and analyze how voter preference is affected by neighboring preferences and by past (what might be, in the case of one of the three being the outgoing mayor, the management of the country during the term just passed) and current (e.g., a scandal or fake news in the middle of the election campaign) events.

## HOW DOES IT WORK?

All commands (sliders, choosers, switchers, etc.) are placed non-randomly above and below the plot. 

The commands above the plot, which must be set before pressing 'setup', configure the characteristics of the network representing the city. In particular, it is possible to configure:
- the number of inhabitants of the city
-the number of people running for election for each mayor
-the average number of neighbors (family members, friends, etc.) that each person has in the city
-the percentage of neighbors who can influence each voter
-the percentage of young (under 35) and old (over 65) people in the town
-whether a mayoral candidate is running for re-election again. In that case, it is possible to configure which of the three is the outgoing mayor and the percentage of people satisfied and dissatisfied in the term just passed.

The commands below the plot configure each mayor's election program, that is, through the use of sliders, it is possible to set the percentage of importance that each mayor, in his or her election program, gives to the four main variables. It is also possible to specify the number of other nonprincipal variabilli.
The sliders just described must be configured before pressing the 'setup' button. There is also a 'random setup' button that randomly allows these to be configured.

Also below the plot we find other controls that set the target and intensity of a possible scandal during the campaign. The 'scandal' button must be pressed subsequent to 'go'.

## QUESTIONS OF INTEREST

How much does the electoral program influence each citizen's preference?

Does the most influential (central) citizen always belong to the winning list?

How important is the influence of neighbors in voting?

Can the presence of clusters (families) that are formed in the graph be an index that a mayor can exploit to win elections?
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
NetLogo 6.2.2
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
