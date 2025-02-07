main().

function main{
  wait 1.
  set part to ship:partsdubbed("rotorFL")[0].
  set moduleFL TO part:GETmodule("moduleRoboticServoRotor").
  moduleFL:SETFIELD("torque limit(%)",30).

  set part to ship:partsdubbed("rotorFR")[0].
  set moduleFR TO part:GETmodule("moduleRoboticServoRotor").
  moduleFR:SETFIELD("torque limit(%)",30).

  set part to ship:partsdubbed("rotorRL")[0].
  set moduleRL TO part:GETmodule("moduleRoboticServoRotor").
  moduleRL:SETFIELD("torque limit(%)",30).

  set part to ship:partsdubbed("rotorRR")[0].
  set moduleRR TO part:GETmodule("moduleRoboticServoRotor").
  moduleRR:SETFIELD("torque limit(%)",30).

  set HOVERPID to PIDLOOP(50,5,100,100,400).
  set VSpeed_PID_Loop to PIDLOOP(200,0.3,10,100,400).
  set X_AxisPID to PIDLOOP(1,0.1,3,-60,60).
  set Y_AxisPID to PIDLOOP(1,0.1,3,-60,60).
  set RoolPID to PIDLOOP(1,0.1,3,-30,30).
  
  set xInput to 0.
  set yInput to 0.
  //set Vx to 0.
  //set Vy to 0.
  //lock steering to heading(90, 90, 180).
  set target_pitch to 20.
  set target_yaw to 0.

  set altThrottle to 0.
  set xDif to 0.
  set yDif to 0.
  set target_alt to 100.
  set verBond to 20.
  set verSpeed to 15.
  set xSpeed to 5.

  until false{

    //calXYSpeed().
    pilotInput().
    set altThrottle to vertical_Control(target_alt,verSpeed).
    set xDif to X_Control(xInput).
    set yDif to Y_Control(yInput).
    print " ".
    print "xDif" + xDif.
    print "yFif" + yDif.
    print "SHIP:FACING * V(0,0,1): " + SHIP:FACING * V(0,0,1).
    moduleFL:SETFIELD("rpm limit",altThrottle + xDif + yDif).
    moduleFR:SETFIELD("rpm limit",altThrottle + xDif - yDif).
    moduleRL:SETFIELD("rpm limit",altThrottle - xDif + yDif).
    moduleRR:SETFIELD("rpm limit",altThrottle - xDif - yDif).
    
  }
}

function calXYSpeed{
    //print " ".
    //print "target_alt:" + target_alt.
    //print "altThrottle:" + altThrottle.
    //print "SHIP:VELOCITY:SURFACE" + (SHIP:VELOCITY:SURFACE:x).
    //print "SHIP:FACING" + (SHIP:FACING:ROLL).
    
    set theta to SHIP:FACING:ROLL.
    set x to SHIP:VELOCITY:SURFACE:x.
    set y to ship:VELOCITY:SURFACE:y.
    set Vx to (x^2 + y^2)^0.5 * sin((arctan(y/x) - theta)).
    set Vy to (x^2 + y^2)^0.5 * cos((arctan(y/x) - theta)).
    print "x" + x.
    print "Vx" + Vx.
    print "y" + y.
    print "Vy" + Vy.
}

function vertical_Control{
  parameter target_alt.
  parameter verSpeed.
  if (abs(alt:radar - target_alt) < verBond){
    //print "set alt".
    return Alt_PID(target_alt).
  }
  //Up
  if ((alt:radar - target_alt) < -verBond) {
    //print "up".
    return VSpeed_PID(verSpeed).
    
  }
  //Down
  if ((alt:radar - target_alt) > verBond) {
    //print "down".
    return VSpeed_PID(-verSpeed).
  }
}

function Alt_PID{
  parameter target_alt.

  set HOVERPID:SETPOINT to target_alt.
  RETURN HOVERPID:UPDATE(TIME:SECONDS, alt:radar).
}

function VSpeed_PID{
  parameter VSpeed.

  set VSpeed_PID_Loop:SETPOINT to VSpeed.
  print  "SHIP:VERTICALSPEED:" + SHIP:VERTICALSPEED.
  RETURN VSpeed_PID_Loop:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED).
}

function X_Control{
  parameter pitchInput.
    set X_AxisPID:SETPOINT to target_yaw+30.
    set shipYaw to ship:FACING:yaw.
    if (ship:FACING:yaw > 180){
      set shipYaw to -(360 - shipYaw).
    }
    print "ship:FACING:yaw" + shipYaw.
    RETURN X_AxisPID:UPDATE(TIME:SECONDS, shipYaw).
}

function Y_Control{
    parameter yallInput.
    set Y_AxisPID:SETPOINT to target_pitch.
    set shipPitch to ship:FACING:pitch.
    if (ship:FACING:pitch > 180){
      set shipPitch to -(360 - shipPitch).
    }
    print "ship:FACING:pitch" + shipPitch.
    RETURN Y_AxisPID:UPDATE(TIME:SECONDS, shipPitch).
}

function pilotInput{
  set target_alt to target_alt - (ship:control:PILOTROLL)/5.
  set xInput to ship:control:PILOTPITCH.
}