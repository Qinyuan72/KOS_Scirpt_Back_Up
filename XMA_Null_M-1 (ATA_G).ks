// XMA_Null_M-1 (ATA_G).ks
PRINT "Initializing XMA_Null_M-1 (ATA_G) Missile Control...".

// 获取 `XMA_Shrimp_Solid_Booster` 部件
SET booster TO ship:partsdubbed("XMA_Shrimp_Solid_Booster").

// 初始化变量
SET detected TO TRUE.
SET missileSeparated TO FALSE.

// 无限循环扫描 "Active Engine"
UNTIL missileSeparated {
    WAIT 1.
    IF stage:resourcesLex["SolidFuel"]:amount <89 {
        PRINT "Engine Detected. Scanning...".
    } IF stage:resourcesLex["SolidFuel"]:amount > 88 AND  ship:velocity:SURFACE:MAG > 5{
        PRINT "Missile Separation Detected! Entering Flight Mode...".
        SET missileSeparated TO TRUE.
    }
}

// 进入导弹飞行控制
PRINT "Missile Guidance Engaged!".

WAIT 1.

// 锁定姿态
LOCK STEERING TO HEADING(30,20, 270).

// 维持导弹控制
UNTIL FALSE {
    PRINT "Missile Active: Speed " + round(ship:velocity:SURFACE:MAG, 1) + " m/s".
    WAIT 1.
}
