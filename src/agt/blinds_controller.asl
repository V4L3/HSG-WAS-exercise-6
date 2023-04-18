// blinds controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds (was:Blinds)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/blinds.ttl").

// the agent initially believes that the blinds are "lowered"
blinds("lowered").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Blinds is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", Url) <-
    makeArtifact("blinds", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], BlindsId);
    focus(BlindsId);
    .print("Hello world").

@raise_blinds_plan
+!raise_blinds : blinds("lowered") <-
    !set_state("raised");
    .print("The blinds have been raised").

@blinds_already_raised_plan
+!raise_blinds : blinds("raised") <-
    .print("Received command to raise blinds but blinds are already raised").

@lower_blinds_plan
+!lower_blinds : blinds("raised") <-
    !set_state("lowered");
    .print("The blinds have been lowered").

@blinds_already_lowered_plan
+!lower_blinds : blinds("lowered") <-
    .print("Received command to lower blinds but blinds are already lowered").

@set_blinds_state_plan
+!set_state(State)[source(Self)] : true <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState",[State])[BlindsId];
    -+blinds(State);
    .send(personal_assistant, tell, blinds(state)).

@answer_with_proposal_plan
+call_for_wake_up_proposal : blinds("lowered") <-
    .send(personal_assistant, tell, proposed_wake_up_method("blinds"));
    -call_for_wake_up_proposal[source(personal_assistant)].

@answer_with_refusal_plan
+call_for_wake_up_proposal : blinds("raised") <-
    .send(personal_assistant, tell, refuse_proposal("blinds"));
    -call_for_wake_up_proposal[source(personal_assistant)].

@proposal_accepted_plan
+proposal_accepted : true <-
    .print("Proposal was accepted, raisind the blinds.");
    !raise_blinds;
    .send(personal_assistant, tell, inform_done("blinds"));
    -proposal_accepted.

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }