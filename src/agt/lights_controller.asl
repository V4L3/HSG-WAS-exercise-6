// lights controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights (was:Lights)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/lights.ttl").

// The agent initially believes that the lights are "off"
lights("off").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Lights is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", Url) <-
    makeArtifact("lights", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], LightsId);
    focus(LightsId);
    .print("Hello world").

@turn_on_lights_plan
+!turn_on_lights : lights("off") <-
    !set_state("on");
    .print("The lights have been turnd on.").

@lights_already_on_plan
+!turn_on_lights : lights("on") <-
    .print("Received command to turn on the lights but the lights are already on").

@turn_off_lights_plan
+!turn_off_the_lights : lights("on") <-
    !set_state("off");
    .print("The lights have been turned off").

@lights_already_off_plan
+!turn_off_the_lights : lights("off") <-
    .print("Received command to turn off the lights, but the light are already off").

@set_lights_state_plan
+!set_state(State) : true <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState",[State])[LightsId];
    -+lights(State);
    .send(personal_assistant, tell, lights(state)).

@answer_with_proposal_plan
+call_for_wake_up_proposal : lights("off") <-
    // .print("received CFP, answer: PROPOSE");
    -call_for_wake_up_proposal[source(personal_assistant)];
    .send(personal_assistant, tell, proposed_wake_up_method("lights")).

@answer_with_refusal_plan
+call_for_wake_up_proposal : lights("on") <-
    // .print("received CFP, answer: REFUSE");
    -call_for_wake_up_proposal[source(personal_assistant)];
    .send(personal_assistant, tell, refuse_proposal("lights")).

@proposal_accepted_plan
+proposal_accepted : true <-
    .print("Proposal was accepted, turning on the lights.");
    !turn_on_lights;
    .send(personal_assistant, tell, inform_done("lights")).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }