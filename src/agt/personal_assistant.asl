// personal assistant agent

best_option("lights") :- ranking_lights(RankingLights) 
    & ranking_blinds(RankingBlinds) 
    & is_highest_ranking(RankingLights, RankingBlinds).

best_option("blinds") :- ranking_blinds(RankingBlinds) 
    & ranking_lights(RankingLights) 
    & is_highest_ranking(RankingBlinds, RankingLights).

is_highest_ranking(X,Y) :- (X \== "methodUsed") & (X < Y).

all_methods_tried :- ranking_lights(RankingLights) 
    & ranking_blinds(RankingBlinds)
    & RankingLights == "methodUsed"
    & RankingBlinds == "methodUsed".

/* Initial goals */ 

// The agent has the goal to start
!start.

/* Initial beliefs */
ranking_blinds(0).
ranking_lights(1).

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: true (the plan is always applicable)
 * Body: greets the user
*/
@start_plan
+!start : true <-
    makeArtifact("dweetArtifact", "room.DweetArtifact", [], DweetArtifactId);
    .print("Hello world").

@send_message_plan
+!sendMessage : true <-
    sendMessage;
    .print("sent message to friend.").

@react_to_upcomming_event_plan
+upcoming_event("now") : owner_state("asleep") <-
    .wait(1000); // timeout to make owner_state has been communicated from the wristband
    !start_wake_up_routine.

@wish_user_enjoyment_plan
+upcoming_event("now") : owner_state("awake") <-
    .print("Enjoy your event").

@react_to_upcomming_event_without_owner_state_plan
+upcoming_event("now") : true <-
    .print("new event but probably no owner state, trying again in 1sec");
    .wait(1000);
    +upcoming_event("now").

@start_wake_up_routine
+!start_wake_up_routine : owner_state("asleep") <-
    .print("Starting wake-up routine");
    .broadcast(tell, call_for_wake_up_proposal);
    .print("Asking for proposals.").

@best_option_proposed_plan
+proposed_wake_up_method(Method)[source(Controller)] : best_option(Method) <-
    .print("Proposal received: ", Method, ", this is the best available option.");
    // .print(Method, " is the best available method, accepting proposal");
    !accept_proposal(Method)[proposed_wake_up_method(Method), source(Controller)].

@suboptimal_option_proposed_plan
+proposed_wake_up_method(Method)[source(Controller)] : not best_option(Method) <-
    .print("Proposal received: ", Method, ", this is not the best available option.");
    !reject_proposal(Method)[proposed_wake_up_method(Method), source(Controller)].

@everything_refused_message_friend_plan
+refuse_proposal(Method)[source(Controller)] : refuse_proposal("lights") & refuse_proposal("blinds") <-
    .print("All CFP were refused, contacting friend.");
    !sendMessage.

@accept_proposal_plan
+!accept_proposal(Proposal)[proposed_wake_up_method(Method), source(Controller)] : true <-
    .print("Accepting proposal of: ", Controller);
    .send(Controller, tell, proposal_accepted);
    -proposed_wake_up_method(Method)[source(Controller)].

@reject_proposal_plan
+!reject_proposal(Proposal)[proposed_wake_up_method(Method), source(Controller)] : true <-
    .print("Rejecting proposal of: ", Controller);
    .send(Controller, tell, proposal_rejected);
    -proposed_wake_up_method(Method)[source(Controller)].
    
@lights_proposal_success_plan
+inform_done(Proposal)[source(Controller)] : Controller == lights_controller <-
    -+ranking_lights("methodUsed");
    .print(Controller, " has successfully executed proposal.");
    !wake_up_owner.

@blinds_proposal_success_plan
+inform_done(Proposal)[source(Controller)] : Controller == blinds_controller <-
    -+ranking_blinds("methodUsed");
    .print(Controller, " has successfully executed proposal.");
    !wake_up_owner.

@proposal_failure_plan
+inform_failure(Proposal)[source(Controller)] : true <-
    .print(Controller, " has failed to executed proposal.").

@wake_up_routing_successfull_plan
+!wake_up_owner : owner_state("awake") <-
    .print("The owner has successfully been woken up.").

@wake_up_routing_not_successfull_plan
+!wake_up_owner : owner_state("asleep") <-
    .print("The owner is still asleep");
    .wait(1000);
    !start_wake_up_routine.

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }