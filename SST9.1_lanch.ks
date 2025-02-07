
main().

function main{
    doLanch().
    doAscent().
    print "Time to APOAPSIS:" + SHIP:OBT:ETA:APOAPSIS.
    circ(SHIP:OBT:ETA:APOAPSIS).
    executeNode().
}

function doLanch{
    lock THROTTLE TO 1.0. 

    PRINT "Luanch sequnce start".
    PRINT "Counting down:".
    FROM {local countdown is 10.} UNTIL countdown = 6 STEP {SET countdown to countdown - 1.} DO {
        PRINT "T- " + countdown.
        WAIT 1.
    }
    doSafeStage(). PRINT "T- 5 Main Engines ignition". WAIT 1.
    PRINT "T- 4". WAIT 1.
    doSafeStage(). PRINT "T -3 Sloid Boosters ignition". WAIT 1.
    PRINT "T- 2". WAIT 1.
    PRINT "T- 1". WAIT 1.
    doSafeStage(). PRINT "T- 0 lift off".
}

function doAscent{
    set targetPitch to 85.
    set targetDirection to 90.
    set targetRoll to 180.
    lock steering to heading(targetDirection, targetPitch, targetRoll).

    set oldThrust to ship:availablethrust.
    set eng1 to ship:partsdubbed("mainEng")[0].
    set eng2 to ship:partsdubbed("mainEng")[1].
    set eng3 to ship:partsdubbed("mainEng")[2].

    set swicthEng to true.

    UNTIL apoapsis > 120000 {
        if (alt:radar > 2500 and alt:radar < 55000) {
            lock targetPitch to 88.963 - 1.03287 * (alt:radar-2500)^0.40.
        }
        if (alt:radar > 55000){
            lock steering to prograde.
        }
        if ship:availablethrust < (oldThrust - 10){
            PRINT "Stage Solid Booster ".
            stage. wait 1.
            set oldThrust to ship:availablethrust.
        }
        if (stage:resourcesLex["SolidFuel"]:amount <200
        and stage:resourcesLex["LiquidFuel"]:amount < 15
        and stage:resourcesLex["LiquidFuel"]:amount > 1
        and swicthEng){
            eng1:shutdown.
            eng2:shutdown.
            eng3:shutdown.
            wait 0.5.
            PRINT "Stage External tank ".
            stage. wait 0.5.
            set swicthEng to false.
        }
    }
    lock THROTTLE TO 0. 
}

function doSafeStage {
  wait until stage:ready.
  stage.
}


function circ {
    parameter lead.

    set Vr to positionat(SHIP, TIME +lead) -BODY:POSITION.
    set Vb to velocityat(SHIP, TIME +lead):ORBIT.
    // set a rotation frame to fix up wacky KSP coordinates...
    set frame to -SHIP:PROGRADE
        *rotatefromto(Vb, OBT:VELOCITY:ORBIT).

    set Sc to sqrt(BODY:MU /Vr:mag). // circular speed
    set onorm to VCRS(Vb, Vr).
    set Vc to VCRS(Vr, onorm):normalized *Sc.
    set dV to frame *(Vc -Vb).
    if dV:mag > 0.1 {
        print "circ(): circularizing in "
            +round(lead,1) +"s   ".
        set cn to node(TIME:SECONDS +lead, dV:y, dV:x, dV:z).
        add cn.
        return cn.
    }
    return False.
}

function executeNode {
    set nd to nextnode.
    //print out node's basic parameters - ETA and deltaV
    print "Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).

    //calculate ship's max acceleration
    set max_acc to ship:maxthrust/ship:mass.
    set burn_duration to maneuverBurnTime(nd).

    print "Estimated burn duration: " + round(burn_duration) + "s".

    set np to nd:deltav. //points to node, don't care about the roll direction.
    lock steering to np.

    wait until nd:eta <= (burn_duration/2 + 60).

    //now we need to wait until the burn vector and ship's facing are aligned
    wait until vang(np, ship:facing:vector) < 0.25.

    //the ship is facing the right direction, let's wait for our burn time
    wait until nd:eta <= (burn_duration/2).
    //we only need to lock throttle once to a certain variable in the beginning of the loop, and adjust only the variable itself inside it
    set tset to 0.
    lock throttle to tset.

    set done to False.
    //initial deltav
    set dv0 to nd:deltav.
    until done
    {
        //recalculate current max_acceleration, as it changes while we burn through fuel
        set max_acc to ship:maxthrust/ship:mass.

        //throttle is 100% until there is less than 1 second of time left to burn
        //when there is less than 1 second - decrease the throttle linearly
        set tset to min(nd:deltav:mag/max_acc, 1).

        //here's the tricky part, we need to cut the throttle as soon as our nd:deltav and initial deltav start facing opposite directions
        //this check is done via checking the dot product of those 2 vectors
        if vdot(dv0, nd:deltav) < 0
        {
            print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            lock throttle to 0.
            break.
        }

        //we have very little left to burn, less then 0.1m/s
        if nd:deltav:mag < 0.1
        {
            print "Finalizing burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            //we burn slowly until our node vector starts to drift significantly from initial vector
            //this usually means we are on point
            wait until vdot(dv0, nd:deltav) < 0.5.

            lock throttle to 0.
            print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            set done to True.
        }
    }
    unlock steering.
    unlock throttle.
    wait 1.

    //we no longer need the maneuver node
    remove nd.

    //set throttle to 0 just in case.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
}

function maneuverBurnTime {
  parameter NodeDeltaV.
  local dV is NodeDeltaV:deltaV:mag.
  local g0 is 9.80665.
  local isp is 0.

  list engines in myEngines.
  for en in myEngines {
    if en:ignition and not en:flameout {
      set isp to isp + (en:isp * (en:maxThrust / ship:maxThrust)).
    }
  }

  local mf is ship:mass / constant():e^(dV / (isp * g0)).
  local fuelFlow is ship:maxThrust / (isp * g0).
  local t is (ship:mass - mf) / fuelFlow.

  return t.
}