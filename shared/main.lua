Config = {}

Config.jobPoint = vector3(871.6325, -1146.0212, 25.9895)
Config.truckSpawn = vector4(841.1216, -1155.5209, 25.3286, 272.1108)
Config.returnCoords = vector3(985.3557, -1159.0940, 25.4040)

Config.MultiplayerBonus = 10 -- % of total pay

Config.DistancePenalty = {
    enable = true,
    minDistance = 1000,
    penalty = 20 -- % of total pay
}

Config.blipSettings = {
    Sprite = 477,
    Scale = 0.8,
    Colour = 81,
    ShortRange = true
}

Config.markerSettings = {
    Type = 21,
    Size = vector3(1.0, 1.0, 1.0),
    Color = {r = 253, g = 152, b = 0},
    DrawDistance = 10.0
}

Config.safetyChecks = {
    vector3(-1.9, 5.8, -1.9),
    vector3(-1.7, -1, -1.8),
    vector3(0, -6.7, -1.8),
    vector3(1.7, -0.7, -1.8),
    vector3(1.7, 4.2, -1.9)
}

Config.InspectScenarios = {"WORLD_HUMAN_SECURITY_SHINE_TORCH", "WORLD_HUMAN_CLIPBOARD", "WORLD_HUMAN_HAMMERING"}

Config.Penalities = {
    onPavement = {
        enabled = true,
        label = "driving on Pavement",
        penalty = 4, -- % of total pay
    },
    ranRedLight = {
        enabled = true,
        label = "running a red light",
        penalty = 6, -- % of total pay
    },
    hitVehicle = {
        enabled = true,
        label = "hitting a vehicle",
        penalty = 5, -- % of total pay
    },
    againstTraffic = {
        enabled = true,
        label = "drving against traffic",
        penalty = 2, -- % of total pay
    },
    speeding = {
        enabled = true,
        label = "Speeding",
        limits = {
            city = 30,
            highway = 55
        },
        penalty = 3, -- % of total pay
    },
}

Config.deliveryTypes = {
    food = {
        label = "Food",
        allowedVehicles = {"mule"},
        types = {"general"},
        trailers = false,
        rewards = {cashMin = 100, cashMax = 200, xp = 1000},
        maxDrops = 3,
        xp = 0
    },
    materials = {
        label = "Materials",
        allowedVehicles = {"hauler", "packer", "phantom", "phantom3"},
        types = {"general", "industrial"},
        trailers = {"trailers", "trailers2", "trailers3", "trailers4", "trailerlogs", "trailers5"},
        rewards = {cashMin = 500, cashMax = 1000, xp = 1000},
        maxDrops = 3,
        xp = 5000
    },
    fuel = {
        label = "Fuel",
        allowedVehicles = {"hauler", "packer", "phantom", "phantom3"},
        types = {"fuel"},
        maxDrops = 3,
        trailers = {"tanker", "tanker2"},
        rewards = {cashMin = 1000, cashMax = 2000, xp = 1500},
        xp = 10000
    },
    cars = {
        label = "Cars",
        allowedVehicles = {"packer", "phantom", "phantom3"},
        rewards = {cashMin = 2000, cashMax = 4000, xp = 1500},
        maxDrops = 1,
        xp = 30000
    },
    millitary = {
        label = "Millitary",
        allowedVehicles = {"phantom", "phantom3"},
        rewards = {cashMin = 4000, cashMax = 6000, xp = 1500},
        maxDrops = 1,
        xp = 50000
    }
}

Config.dropOffPoints = {
    general = {
        vector4(875.0670, -1657.1842, 30.5185, 270.1987),
        vector4(966.0221, -1698.9272, 29.8359, 357.0065),
        vector4(935.7771, -1816.0177, 31.1573, 267.4857),
        vector4(948.1600, -2370.0137, 29.8283, 264.5170),
        vector4(794.8875, -2541.6353, 20.4759, 265.3627),
        vector4(645.8887, 2781.9668, 41.9337, 354.7617),
        vector4(766.4565, 2570.6304, 75.2047, 70.5886),
        vector4(1566.5991, 6468.3555, 24.1791, 206.1936),
        vector4(808.2120, 1274.9689, 360.4932, 86.5090),
        vector4(-174.9747, -1438.5753, 31.3760, 330.7205),
        vector4(2113.5903, 10.9410, 216.8511, 323.5697),
        vector4(3411.0044, 3757.5969, 30.5659, 305.7756)
    },
    industrial = {
        vector4(742.0578, -1351.7549, 26.5153, 92.8528),
        vector4(923.8186, -1576.2625, 30.7884, 271.7451),
        vector4(856.3112, -2347.3149, 29.6295, 84.0988),
        vector4(774.6216, -2512.6582, 19.2577, 174.1827),
        vector4(558.5180, -2749.7417, 5.3574, 329.8157),
        vector4(561.4969, 2635.6848, 42.1558, 293.3147),
        vector4(203.7150, 6379.3491, 31.4386, 9.1690),
        vector4(12.0701, 761.5197, 201.9708, 341.5440),
        vector4(-70.6997, 6562.0171, 31.4908, 227.3384),
        vector4(2291.8926, 5537.0215, 51.1641, 256.1178),
        vector4(-587.5668, 5299.5288, 70.2144, 154.3934),
        vector4(1273.7538, 3132.6816, 40.4141, 284.0936),
        vector4(-2992.3638, 3418.6726, 10.2280, 153.2670),
        vector4(-1132.3898, 4305.3892, 86.7339, 230.7038),
        vector4(-3017.2908, 365.8484, 14.6554, 348.4772)
    },
    fuel = {
        vector4(837.1342, -1045.3372, 27.7441, 268.3029),
        vector4(905.4066, -2476.3193, 27.5834, 83.1171),
        vector4(636.8415, -2760.6890, 5.3901, 121.8060),
        vector4(1189.3702, -1387.1122, 35.1038, 356.8657),
        vector4(-2524.5544, 2344.4326, 33.0599, 215.6419),
        vector4(66.6594, 2786.4182, 57.8782, 319.0773),
        vector4(1205.8043, 2641.2161, 37.7406, 141.4938),
        vector4(1426.1097, 3616.8760, 34.9442, 27.8458),
        vector4(199.0759, 6627.3066, 31.5505, 0.9166),
        vector4(167.5033, -1519.2063, 29.1410, 225.9381),
        vector4(-40.1709, 4547.9771, 118.0213, 224.6840),
        vector4(1341.6863, 2747.4036, 51.7395, 70.1348)
    },
}

Config.pickupPoints = {
    general = {
        vector4(908.4949, -1222.2174, 25.7487, 183.1919),
        vector4(842.1476, -1231.8077, 26.4600, 272.4371),
        vector4(942.3488, -1220.8885, 25.9467, 129.8493),
        vector4(938.8381, -1142.6827, 25.2837, 180.5955),
        vector4(1003.0000, -1193.7814, 25.6432, 94.0386),
        vector4(-3076.3088, 1393.5864, 20.7430, 160.7814),
        vector4(563.7327, 2807.7612, 42.1910, 270.5370),
        vector4(745.9420, 2530.9312, 73.1191, 186.3373),
        vector4(1485.5574, 3576.9170, 35.2501, 23.3474),
        vector4(-407.2032, 1227.3939, 325.6413, 163.7497),
        vector4(740.6877, 1199.7365, 326.2660, 251.3775),
        vector4(-1171.5002, -892.8386, 13.9077, 27.8065),
        vector4(-203.3035, 6544.8462, 11.0979, 155.5933),
        vector4(-2140.5537, 2689.2258, 2.9286, 347.2691),
        vector4(-2349.1714, 3439.3455, 29.7504, 65.5201)
    },
    industrial = {
        vector4(728.6974, -1361.9805, 26.5921, 89.3512),
        vector4(708.9582, -1395.3000, 26.5715, 287.0621),
        vector4(703.8763, -1373.2783, 26.3805, 282.0625),
        vector4(822.8375, -1368.4370, 26.3696, 2.3485),
        vector4(832.5436, -1369.6476, 26.3691, 1.2258),
        vector4(1009.1306, -2525.1702, 27.6062, 355.9741),
        vector4(555.5917, -3037.9465, 5.3666, 357.8700),
        vector4(153.1234, 6436.2305, 31.3072, 131.8810),
        vector4(150.2618, -1281.5845, 29.1271, 203.7272),
        vector4(-589.1259, -1183.0372, 17.5034, 85.5423),
        vector4(548.0297, -210.1631, 53.5930, 161.0560),
        vector4(-744.9357, 5818.7656, 17.4131, 256.5994),
        vector4(-610.1561, 337.7546, 85.1167, 266.0105),
        vector4(1656.8738, 52.6691, 172.2888, 301.3029)
    },
    fuel = {
        vector4(727.6035, -1318.1801, 26.2920, 87.7828),
        vector4(1203.7556, -1231.0474, 35.2267, 273.4839),
        vector4(727.4479, -1283.3674, 26.2842, 95.4725),
        vector4(838.3076, -1931.9120, 28.9769, 170.8231),
        vector4(-246.4148, -2663.3550, 6.0003, 17.9757),
        vector4(-2534.8882, 2342.1636, 33.0599, 207.8478),
        vector4(-281.4833, 2555.3779, 73.9124, 11.4888),
        vector4(41.9515, 2803.1226, 57.8781, 136.3526),
        vector4(233.1306, 2598.3889, 45.3304, 26.8837),
        vector4(1344.8193, 3611.4634, 34.8194, 197.3214),
        vector4(1981.9128, 3777.2959, 32.1808, 220.6197),
        vector4(149.9094, 6629.7104, 31.7034, 47.1063),
        vector4(-699.7095, -1115.0852, 14.5253, 313.5238),
        vector4(-1578.6387, 5157.7188, 19.7508, 297.5107)
    },
}

Config.trucks = {
    mule = {
        label = "Mule",
        xp = 0
    },
    hauler = {
        label = "Hauler",
        xp = 5000
    },
    packer = {
        label = "Packer",
        xp = 12000
    },
    phantom = {
        label = "Phantom",
        xp = 32000
    },
    phantom3 = {
        label = "Phantom Custom",
        xp = 55000
    }
}

