
set part to ship:partsdubbed("rotor1")[0].
set module to part:getmodule("moduleRoboticServoRotor").
 module:SETFIELD("torque limit(%)",100).

set part to ship:partsdubbed("rotor2")[0].
set module to part:getmodule("moduleRoboticServoRotor").
module:SETFIELD("torque limit(%)",100).

set part to ship:partsdubbed("propDeployAngleCon1")[0].
SET module TO part:GETMODULE("ModuleRoboticController").


set playPostion to 0.
set kPlayPostion to 30.
set activeVlocity to 45.
set maxspeed to 270 - activeVlocity.
until false{
    if ship:velocity:SURFACE:mag< activeVlocity{
        set playPostion to 0.
    }
    if ship:velocity:SURFACE:mag> activeVlocity{
        set playPostion to (ship:velocity:SURFACE:mag-activeVlocity)/maxspeed * kPlayPostion.
    }  
    module:SETFIELD("play position",playPostion).
}
