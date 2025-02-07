
main().


function p_Speed{
    parameter targetSpeed.
    SET eg TO 50.
    LOCK thrott TO eg * (targetSpeed - ship:velocity:SURFACE:mag)/targetSpeed.
    LOCK THROTTLE to thrott.
}

function main{
    LOCK STEERING TO R(0,0,-90) + HEADING(90,90).
    STAGE.
    until 0{
        p_Speed(120).
    }
}