// 设置 rotor1 和 rotor2 的扭矩限制
SET part TO ship:partsdubbed("rotor1")[0].
SET moduleRotor1 TO part:getmodule("ModuleRoboticServoRotor").

SET part TO ship:partsdubbed("rotor2")[0].
SET moduleRotor2 TO part:getmodule("ModuleRoboticServoRotor").

// 获取 Torque_Limite_Con1
SET part TO ship:partsdubbed("Torque_Limite_Con1")[0].
SET moduleTorqueCon1 TO part:getmodule("ModuleRoboticController").

// 获取 propDeployAngleCon1 控制器
SET part TO ship:partsdubbed("propDeployAngleCon1")[0].
SET moduleAngleCon1 TO part:getmodule("ModuleRoboticController").

// 初始化变量
SET playPosition TO 0.
SET kPlayPosition TO 30.
SET activeVelocity TO 45.
SET maxSpeed TO 270 - activeVelocity.
SET minSpeed TO 100. // 开始减少扭矩的速度
SET maxSpeedTorque TO 290. // 扭矩最低点对应的速度

// 无限循环控制 play position 和 torque limit
UNTIL FALSE {
    SET currentSpeed TO ship:velocity:SURFACE:MAG.

    // 计算 play position（桨叶角度）
    IF currentSpeed < activeVelocity {
        SET playPosition TO 0.
    } ELSE {
        SET playPosition TO ((currentSpeed - activeVelocity) / maxSpeed) * kPlayPosition.
    }

    // 计算 torque limit(%)，范围 100% - 60%
    IF currentSpeed < minSpeed {
        SET torqueLimit TO 100.
    } ELSE IF currentSpeed > maxSpeedTorque {
        SET torqueLimit TO 60.
    } ELSE {
        SET torqueLimit TO 100 - ((currentSpeed - minSpeed) / (maxSpeedTorque - minSpeed)) * (100 - 60).
    }

    // 映射 torqueLimit 到 Torque_Limite_Con1 (0-100)
    IF moduleTorqueCon1:HASFIELD("play position") {
        moduleTorqueCon1:SETFIELD("play position", torqueLimit).
    }

    // 只有在 moduleAngleCon1 存在并且包含 "play position" 时才设置 play position
    IF moduleAngleCon1:HASFIELD("play position") {
        moduleAngleCon1:SETFIELD("play position", playPosition).
    }

    // 应用 torque limit 到 rotors
    IF moduleRotor1:HASFIELD("torque limit(%)") {
        moduleRotor1:SETFIELD("torque limit(%)", torqueLimit).
    }
    IF moduleRotor2:HASFIELD("torque limit(%)") {
        moduleRotor2:SETFIELD("torque limit(%)", torqueLimit).
    }

    // 调试信息
    PRINT "Speed: " + currentSpeed + " | Play Position: " + playPosition + " | Torque Limit: " + torqueLimit.

    WAIT 0.1. // 避免 CPU 过载
}
