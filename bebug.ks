

lock throttle to 1.
stage.

until ship:maxthrust > 0 { stage }

lock targetPitch to 88.963 - 1.03287 * alt:radar^0.409511.
set targetDirection to 90.
lock steering to heading(targetDirection, targetPitch).

lock availThrust to ship:avaiLablethrUST.
unless apoapsis > 100 {
  if ship:availablethrust < (availThrust - 10) {
    stage. wait 1.
    set availThrust to ship:availablethrust.
  }
}