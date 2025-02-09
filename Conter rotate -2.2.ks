// 设置 rotor1 的扭矩限制
SET part TO ship:partsdubbed("rotor1")[0].
SET module TO part:getmodule("ModuleRoboticServoRotor").
IF module:HASFIELD("torque limit(%)") {
    module:SETFIELD("torque limit(%)", 100).
}

// 设置 rotor2 的扭矩限制
SET part TO ship:partsdubbed("rotor2")[0].
SET module TO part:getmodule("ModuleRoboticServoRotor").
IF module:HASFIELD("torque limit(%)") {
    module:SETFIELD("torque limit(%)", 100).
}

// 获取 propDeployAngleCon1 的 ModuleRoboticController
SET part TO ship:partsdubbed("propDeployAngleCon1")[0].
SET module TO part:GETMODULE("ModuleRoboticController").

// 确保模块存在并且具有 "play position" 字段
IF NOT module:HASFIELD("play position") {
    PRINT "Error: ModuleRoboticController not found or missing play position field!".
    WAIT 5.
    LOCK THROTTLE TO 0.
    STAGE. // 可以触发一个紧急情况（例如分离）
    WAIT 10000. // 防止脚本继续运行
}

// 初始化变量
SET playPosition TO 0.
SET kPlayPosition TO 30.
SET activeVelocity TO 45.
SET maxSpeed TO 270 - activeVelocity.

// 无限循环控制 play position
UNTIL FALSE {
    SET currentSpeed TO ship:velocity:SURFACE:MAG.

    IF currentSpeed < activeVelocity {
        SET playPosition TO 0.
    } ELSE {
        SET playPosition TO ((currentSpeed - activeVelocity) / maxSpeed) * kPlayPosition.
    }

    // 只有在 module 存在并且包含 "play position" 时才设置
    IF module:HASFIELD("play position") {
        module:SETFIELD("play position", playPosition).
    }

    WAIT 0.1. // 避免 CPU 过载
}
