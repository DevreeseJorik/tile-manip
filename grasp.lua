-------------------------------------------------
--                  grasp.lua                  --
--  [Glitchin Research and Speedrunning lua]   --
-------------------------------------------------

-------------------------------------------------
--              by RETIREglitch                --
-------------------------------------------------

-------------------------------------------------
--  base pointer addresses provided by Ganix   --
--  void/rng func based on MKdasher's scripts  --
-------------------------------------------------

-- simpler codes
readbyte,readword,readdword,readdwordsigned,writebyte,writeword,writedword = memory.readbyte,memory.readword,memory.readdword,memory.readdwordsigned,memory.writebyte,memory.writeword,memory.writedword
bor,band,lshift,rshift = bit.bor,bit.band,bit.lshift,bit.rshift

-- DATA TABLES

local map_id_list = {
	mystery_zone = {
		color = '#88888866',
		ids = {0}
	},
	blackout = {
		color = 'orange',
		ids = {332, 333}
	},
	movement = {
		color = 'purple',
		ids = {117, 177, 179, 181, 183, 192, 393,
            474, 475, 476, 477, 478, 479, 480, 481, 482, 483,
            484, 485, 486, 487, 488, 489, 490, 496}
	},
	warp = {
		color = 'yellow',
		ids = {105, 114, 337, 461, 516, 186, 187}
	},
	bsod_model = {
		color = 'red',
		ids = {35, 88, 93, 95, 122,133,154, 155, 156, 176, 178, 180, 182,
				184, 185, 188, 291, 293, 504, 505, 506, 507, 508, 509}
	},
	soft_lock = {
		color = 'red',
		ids = {150}
	},
	wrong_warp = {
		color = '#666fd',
		ids = {7,37,49,70,102,124,135,152,169,174,190,421,429,436,444,453,460,495}
	},
	jubilife_city = {
		color = '#66ffbbff',
		ids = {3}
	},
	goal = {
		color = '#f7bbf3',
		ids = {
			165, 215, 347
			--383, 386, 387, 406,40, 442, 450, 457, 499, 501,342, 406, 501, 502, 503
			--67, 68 , 28, --, 45
			-- 224, 356, 362, 363, 366, 382, 433, 442,
			-- 400, 401, 402, 403, 404, 405, 450, 469, 262,
			-- 132, 276, 277,
			-- 11, 12, 13, 14, 15, 16, 17,
			-- 125, 126, 164, 393,
			-- 188, 406, 407, 408, 409, 457, 470, 471, 473,
			-- 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100,
			-- 167,
			-- 33, 320, 388, 260, 288,
			-- 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100
		}
		},
	chain = {
		color = '#DfA',
		ids = {2, 200, 214, 220, 347, 510, 65, 200, 203, 348, 365,113, 116, 119, 146, 160, 166, 167, 168, 170, 171, 195, 278, 342, 361, 418, 440
	}
	},

	default = {
		color = '#00bb00ff',
		ids = {}
	},
}

map_ids = {}

for k,v in pairs(map_id_list) do
	for i=1,#map_id_list[k]['ids'] do
		map_ids[map_id_list[k]['ids'][i]] = map_id_list[k]['color']
	end
end

local tile_names = {
			"nothing","nothing","Grass","Grass","4","Cave","Cave","7","Ground enc","9","10", "Indoor enc","Cave wall","13","14","15",
			"Pond","Water","Water","WaterF","Water","Water","Puddle","ShallW","24","Water","26","27","28","29","30","31",
			"Ice","Sand","Water","35","Cave","Cave","38","39","40","41","Water","43","44","45","46","47",
			"No R mov","No L mov","No U mov","No D mov","No R/U mov","No L/U mov","No R/D mov","No L/D mov","Ledge (R)","Ledge (L)","Ledge (U)","Ledge (D)","60","61","62","Ledge Corner",
			"Spin (R)","Spin (L)","Spin (U)","Spin (D)","68","69","70","71","72","No U/D mov","No L/R mov","Rockclimb (V)","Rockclimb (H)","77","78","79",
			"Water","Water","Water","Water","84","85","Raised Model","Raised Model","Raised Model","Raised Model","90","91","92","93","Warp","Warp",
			"Warp","Warp","Doormat","Doormat","Doormat","Doormat","Warp","Warp","Warp","Warp","Warp","Warp","Warp","Warp","Warp","Warp",
			"Start Bridge","Bridge","Bridge (C)","Bridge (W)","Bridge","Bridge (Sn)","Bike Bridge","Bike Bridge","Bike Bridge","Bike Bridge","Bike Bridge","Bike Bridge (G)","Bike Bridge (W)","Bike Bridge","126","127",
			"Counter","129","130","PC","132","Map","Television","135","Bookcases","137","138","139","140","141","Book","143",
			"144","145","146","147","148","149","150","151","152","153","154","155","156","157","158","159",
			"Soil","Deep Snow 1","Deep Snow 2","Deep Snow 3","Mud","Mud (B)","Mud Grass","Mud Grass (B)","Snow","Melting snow","170","171","172","173","174","175",
			"176","177","178","179","180","181","182","183","184","185","186","187","188","189","190","191",
			"192","193","194","195","196","197","198","199","200","201","202","203","204","205","206","207",
			"208","209","210","211","212","213","214","Bike ramp (R)","Bikeramp (L)","Slope top","Slope bottom","Bikestall","220","221","222","223",
			"Bookcases","Bookcases","Bookcases","227","Thrashbin","Misc Objects","230","231","232","233","234","235","236","237","238","239",
			"240","241","242","243","244","245","246","247","248","249","250","251","252","253","254","Unloaded"
} -- 6 is tree in HGSS

tile_id_list = {
	grass = {
        color = '#40a',
        ids = {0x2,0x7B}
    },
	default = {
        color = nil,
        ids = {0xff}
    },
	warps = {
        color = '#f03',
        ids ={0x5E,0x5f,0x62,0x63,0x69,0x65,0x6f,0x6D,0x6A,0x6C,0x6E}
	},
	cave = {
        color = '#bb7410',
        ids = {0x6,0x8,0xC}
	},
	water = {
        color = '#4888f',
        ids = {0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x19,0x22,0x2A,0x7C}
    },
    sand = {
        color = '#e3c',
        ids = {0x21,0x21}
	},
	deep_snow1 = {
        color = '#8da9cb',
        ids = {0xA1}
    },
    deep_snow2 = {
        color = '#6483a7',
        ids = {0xA2}
    },
    deep_snow3 = {
        color = '#52749d',
        ids = {0xA3}
	},
    mud = {
        color = '#92897',
        ids = {0xA4}
    },
    mud_block = {
        color = '#92704',
        ids = {0xA5}
    },
    mud_grass = {
        color = '#4090',
        ids = {0xA6}
    },
    mud_grass_block = {
        color = '#55906',
        ids = {0xA7}
	},
    snow = {
        color = '#b9d0eb',
        ids = {0xA8}
	},
	tall_grass = {
        color = '#2aa615',
        ids = {0x3}		
	},
	misc_obj = {
        color = 'white',
        ids = {0xE5,0X8E,0X8f}
    },
	spin_tile = {
        color = '#ffd',
        ids = {0x40,0x41,0x42,0x43}
    },
	ice = {
        color = '#56b3e0',
        ids = {0x20,0x20}
    },
	ice_stair = {
        color = '#ffd',
        ids = {0x49,0x4A}
    },
	circle_warp = {
        color = '#a0a',
        ids = {0x67}
    },
	model_fl = {
        color = '#afb',
       ids = {0x56,0x57,0x58,} 
    },
	model_floor = {
        color = '#a090f',
       ids = {0x59}
    },
	special_collision = {
        color = '#a090f',
       ids = {0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37}
    },
	bike_stall = {
        color = '#0690a',
       ids = {0xDB}
    },
	counter = {
        color = '#f7a',
        ids = {0x80}
    },
	pc = {
       color = '#0690b',
       ids = {0x83}
    },
	map = {
       color = '#00eee',
       ids = {0x85}
    },
	tv = {
       color = '#4290e',
       ids = {0x86}
    },
	bookcases = {
        color = '#0ddd7',
        ids = {0x88,0xE1,0xE0,0xE2}
    },
	bin = {
        color = '#06b04',
       ids = {0xE4}
	},
    indoor_encounter = {
        color = '#A292BC',
        ids = {0xB}
    },
    ledge = {
        color = '#D3A',
        ids = {0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,0x3F}
    },
    rock_climb = {
        color = '#C76',
        ids = {0x4B,0x4C}
    },
    bridge = {
        color = '#C79',
        ids = {0x71,0x72,0x73,0x74,0x75}
	},
	start_bridge = {
		color= "#C7B", 
		ids = {0x70}
	},
    bike_bridge = {
        color = '#C7A55',
        ids = {0x76,0x77,0x78,0x79,0x7A,0x7D}
		-- BikeBridge 0x7C moves to water, 0x7B moved to grass
	},
    soil = {
        color = '#b2703',
        ids = {0xA0}
    },
    bike_ramp = {
        color = '#B890',
        ids = {0xD7,0xD8}
	},
    quick_sand = {
        color = '#A880',
        ids = {0xD9,0xDA}
    },
	-- trees = {
    --     color = '#CCCCC',
    --     ids = {0x6}
    -- }, -- HGSS, remove 0x6 from cave list if used
}

tile_ids = {}

for k,v in pairs(tile_id_list) do
	for i=1,#tile_id_list[k]['ids'] do
		tile_ids[tile_id_list[k]['ids'][i]] = tile_id_list[k]['color']
	end
end

script_commands = {
	[0x0] = {color = '#222222', script_command = 'Nop', parameters = {}},
	[0x1] = {color = '#444444', script_command = 'Dummy', parameters = {}},
	[0x2] = {color = 'orange', script_command = 'End', parameters = {}},
	[0x3] = {color = '#5555FFF', script_command = 'TimeWait', parameters = {'num', 'num', 'wkid', 'wkid'}},
	[0x4] = {color = '#5555FFF', script_command = 'LoadRegValue', parameters = {'reg', 'val'}},
	[0x5] = {color = '#5555FFF', script_command = 'LoadRegWData', parameters = {'reg', 'dat', 'dat', 'dat', 'dat'}},
	[0x6] = {color = '#5555FFF', script_command = 'LoadRegAdrs', parameters = {'reg', 'adr', 'adr', 'adr', 'adr'}},
	[0x7] = {color = '#5555FFF', script_command = 'LoadAdrsValue', parameters = {'adr', 'adr', 'adr', 'adr', 'val'}},
	[0x8] = {color = '#5555FFF', script_command = 'LoadAdrsReg', parameters = {'adr', 'adr', 'adr', 'adr', 'reg'}},
	[0x9] = {color = '#5555FFF', script_command = 'LoadRegReg', parameters = {'tg', 'src'}},
	[0xa] = {color = '#5555FFF', script_command = 'LoadAdrsAdrs', parameters = {'tg', 'tg', 'tg', 'tg', 'src', 'src', 'src', 'src'}},
	[0xb] = {color = '#5555FFF', script_command = 'CmpRegReg', parameters = {'r1', 'r2'}},
	[0xc] = {color = '#5555FFF', script_command = 'CmpRegValue', parameters = {'reg', 'val'}},
	[0xd] = {color = '#5555FFF', script_command = 'CmpRegAdrs', parameters = {'reg', 'adr', 'adr', 'adr', 'adr'}},
	[0xe] = {color = '#5555FFF', script_command = 'CmpAdrsReg', parameters = {'adr', 'adr', 'adr', 'adr', 'reg'}},
	[0xf] = {color = '#5555FFF', script_command = 'CmpAdrsValue', parameters = {'adr', 'adr', 'adr', 'adr', 'val'}},
	[0x10] = {color = '#5555FFF', script_command = 'CmpAdrsAdrs', parameters = {'ad1', 'ad1', 'ad1', 'ad1', 'ad2', 'ad2', 'ad2', 'ad2'}},
	[0x11] = {color = '#5555FFF', script_command = 'CmpWkValue', parameters = {'var', 'var', 'val', 'val'}},
	[0x12] = {color = '#5555FFF', script_command = 'CmpWkWk', parameters = {'wk1', 'wk1', 'wk2', 'wk2'}},
	[0x13] = {color = '#5555FFF', script_command = 'VMMachineAdd', parameters = {'id', 'id'}},
	[0x14] = {color = '#5555FFF', script_command = 'ChangeCommonScr', parameters = {'val', 'val'}},
	[0x15] = {color = '#5555FFF', script_command = 'ChangeLocalScr', parameters = {}},
	[0x16] = {color = '#00BB22', script_command = 'GlobalJump', parameters = {'pos', 'pos', 'pos', 'pos'}, jump = 1},
	[0x17] = {color = '#00BB22', script_command = 'ObjIDJump', parameters = {'id', 'pos', 'pos', 'pos', 'pos'}, jump = 1},
	[0x18] = {color = '#00BB22', script_command = 'BgIDJump', parameters = {'id', 'pos', 'pos', 'pos', 'pos'}, jump = 1},
	[0x19] = {color = '#00BB22', script_command = 'PlayerDirJump', parameters = {'val', 'pos', 'pos', 'pos', 'pos'}, jump = 1},
	[0x1a] = {color = '#00BB22', script_command = 'GlobalCall', parameters = {'val', 'val', 'val', 'val'}, jump = 1},
	[0x1b] = {color = 'orange', script_command = 'Ret', parameters = {}},
	[0x1c] = {color = '#00BB22', script_command = 'IfJump', parameters = {'r', 'pos', 'pos', 'pos', 'pos'}, jump = 1},
	[0x1d] = {color = '#00BB22', script_command = 'IfCall', parameters = {'r', 'pos', 'pos', 'pos', 'pos'}, jump = 1},
	[0x1e] = {color = '#5555FFF', script_command = 'FlagSet', parameters = {'flg', 'flg'}},
	[0x1f] = {color = '#5555FFF', script_command = 'FlagReset', parameters = {'flg', 'flg'}},
	[0x20] = {color = '#5555FFF', script_command = 'FlagCheck', parameters = {'flg', 'flg'}},
	[0x21] = {color = '#5555FFF', script_command = 'FlagCheckWk', parameters = {'wk', 'wk', 'rwk', 'rwk'}},
	[0x22] = {color = '#5555FFF', script_command = 'FlagSetWk', parameters = {'wk', 'wk'}},
	[0x23] = {color = '#5555FFF', script_command = 'TrainerFlagSet', parameters = {'flg', 'flg'}},
	[0x24] = {color = '#5555FFF', script_command = 'TrainerFlagReset', parameters = {'flg', 'flg'}},
	[0x25] = {color = '#5555FFF', script_command = 'TrainerFlagCheck', parameters = {'flg', 'flg'}},
	[0x26] = {color = '#5555FFF', script_command = 'WkAdd', parameters = {'wk', 'wk', 'val', 'val'}},
	[0x27] = {color = '#5555FFF', script_command = 'WkSub', parameters = {'wk', 'wk', 'val', 'val'}},
	[0x28] = {color = '#5555FFF', script_command = 'LoadWkValue', parameters = {'wk', 'wk', 'val', 'val'}},
	[0x29] = {color = '#5555FFF', script_command = 'LoadWkWk', parameters = {'wk1', 'wk1', 'wk2', 'wk2'}},
	[0x2a] = {color = '#5555FFF', script_command = 'LoadWkWkValue', parameters = {'wk', 'wk', 'val', 'val'}},
	[0x2b] = {color = '#5555FFF', script_command = 'TalkMsgAllPut', parameters = {'msg', 'msg'}},
	[0x2c] = {color = '#5555FFF', script_command = 'TalkMsg', parameters = {'msg'}},
	[0x2d] = {color = '#5555FFF', script_command = 'TalkMsgSp', parameters = {'msg', 'msg'}},
	[0x2e] = {color = '#5555FFF', script_command = 'TalkMsgNoSkip', parameters = {'msg', 'msg'}},
	[0x2f] = {color = '#5555FFF', script_command = 'TalkConSioMsg', parameters = {'msg'}},
	[0x30] = {color = '#5555FFF', script_command = 'ABKeyWait', parameters = {}},
	[0x31] = {color = '#5555FFF', script_command = 'LastKeyWait', parameters = {}},
	[0x32] = {color = '#5555FFF', script_command = 'NextAnmLastKeyWait', parameters = {}},
	[0x33] = {color = '#5555FFF', script_command = 'TalkWinOpen', parameters = {}},
	[0x34] = {color = '#5555FFF', script_command = 'TalkWinClose', parameters = {}},
	[0x35] = {color = '#5555FFF', script_command = 'TalkWinCloseNoClear', parameters = {}},
	[0x36] = {color = '#5555FFF', script_command = 'BoardMake', parameters = {'msg', 'typ', 'map', 'map', 'wk', 'wk'}},
	[0x37] = {color = '#5555FFF', script_command = 'InfoBoardMake', parameters = {'typ', 'map', 'map'}},
	[0x38] = {color = '#5555FFF', script_command = 'BoardReq', parameters = {'req'}},
	[0x39] = {color = '#5555FFF', script_command = 'BoardWait', parameters = {}},
	[0x3a] = {color = '#5555FFF', script_command = 'BoardMsg', parameters = {'msg', 'wk', 'wk'}},
	[0x3b] = {color = '#5555FFF', script_command = 'BoardEndWait', parameters = {'wk', 'wk'}},
	[0x3c] = {color = '#5555FFF', script_command = 'MenuReq', parameters = {}},
	[0x3d] = {color = '#5555FFF', script_command = 'BgScroll_vertical', parameters = {'r0', 't0', 'r1', 'r2', 't1', 'r3'}},
	[0x3e] = {color = '#5555FFF', script_command = 'YesNoWin', parameters = {'wkid', 'wkid'}},
	[0x3f] = {color = '#5555FFF', script_command = 'GuinnessWin', parameters = {}},
	[0x40] = {color = '#5555FFF', script_command = 'BmpMenuInit', parameters = {'xx', 'yy', 'cur', 'can', 'wkid', 'wkid'}},
	[0x41] = {color = '#5555FFF', script_command = 'BmpMenuInitEx', parameters = {'xx', 'yy', 'cur', 'can', 'wkid', 'wkid'}},
	[0x42] = {color = '#5555FFF', script_command = 'BmpMenuMakeList', parameters = {'msg', 'prm'}},
	[0x43] = {color = '#5555FFF', script_command = 'BmpMenuStart', parameters = {}},
	[0x44] = {color = '#5555FFF', script_command = 'BmpListInit', parameters = {'xx', 'yy', 'cur', 'can', 'wkid', 'wkid'}},
	[0x45] = {color = '#5555FFF', script_command = 'BmpListInitEx', parameters = {'xx', 'yy', 'cur', 'can', 'wkid', 'wkid'}},
	[0x46] = {color = '#5555FFF', script_command = 'BmpListMakeList', parameters = {}},
	[0x47] = {color = '#5555FFF', script_command = 'BmpListStart', parameters = {}},
	[0x48] = {color = '#5555FFF', script_command = 'BmpMenuHVStart', parameters = {'max', 'max'}},
	[0x49] = {color = '#5555FFF', script_command = 'SePlay', parameters = {'snd', 'snd'}},
	[0x4a] = {color = '#5555FFF', script_command = 'SeStop', parameters = {'snd', 'snd'}},
	[0x4b] = {color = '#5555FFF', script_command = 'SeWait', parameters = {'snd', 'snd'}},
	[0x4c] = {color = '#5555FFF', script_command = 'VoicePlay', parameters = {'sp', 'sp','vol','vol'}},
	[0x4d] = {color = '#5555FFF', script_command = 'VoicePlayWait', parameters = {}},
	[0x4e] = {color = '#5555FFF', script_command = 'MePlay', parameters = {'snd', 'snd'}},
	[0x4f] = {color = '#5555FFF', script_command = 'MeWait', parameters = {}},
	[0x50] = {color = '#5555FFF', script_command = 'BgmPlay', parameters = {'sid', 'sid'}},
	[0x51] = {color = '#5555FFF', script_command = 'BgmStop', parameters = {}},
	[0x52] = {color = '#5555FFF', script_command = 'BgmNowMapPlay', parameters = {}},
	[0x53] = {color = '#5555FFF', script_command = 'BgmSpecialSet', parameters = {'sp', 'sp'}},
	[0x54] = {color = '#5555FFF', script_command = 'BgmFadeOut', parameters = {'vol', 'vol', 'frm', 'frm'}},
	[0x55] = {color = '#5555FFF', script_command = 'BgmFadeIn', parameters = {'frm', 'frm'}},
	[0x56] = {color = '#5555FFF', script_command = 'BgmPlayerPause', parameters = {'ply', 'flg'}},
	[0x57] = {color = '#5555FFF', script_command = 'PlayerFieldDemoBgmPlay', parameters = {'dem', 'dem'}},
	[0x58] = {color = '#5555FFF', script_command = 'CtrlBgmFlagSet', parameters = {'flg'}},
	[0x59] = {color = '#5555FFF', script_command = 'PerapDataCheck', parameters = {'wk', 'wk'}},
	[0x5a] = {color = '#5555FFF', script_command = 'PerapRecStart', parameters = {'wk', 'wk'}},
	[0x5b] = {color = '#5555FFF', script_command = 'PerapRecStop', parameters = {}},
	[0x5c] = {color = '#5555FFF', script_command = 'PerapSave', parameters = {}}, 
	[0x5d] = {color = '#5555FFF', script_command = 'SndClimaxDataLoad', parameters = {}},
	[0x5e] = {color = '#5555FFF', script_command = 'ObjAnime', parameters = {'obj', 'obj', 'pos', 'pos', 'pos', 'pos'}},
	[0x5f] = {color = '#5555FFF', script_command = 'ObjAnimeWait', parameters = {}},
	[0x60] = {color = '#5555FFF', script_command = 'ObjPauseAll', parameters = {}},
	[0x61] = {color = '#5555FFF', script_command = 'ObjPauseClearAll', parameters = {}},
	[0x62] = {color = '#5555FFF', script_command = 'ObjPause', parameters = {'obj', 'obj'}},
	[0x63] = {color = '#5555FFF', script_command = 'ObjPauseClear', parameters = {'obj', 'obj'}},
	[0x64] = {color = '#5555FFF', script_command = 'ObjAdd', parameters = {'obj', 'obj'}},
	[0x65] = {color = '#5555FFF', script_command = 'ObjDel', parameters = {'obj', 'obj'}},
	[0x66] = {color = '#5555FFF', script_command = 'VanishDummyObjAdd', parameters = {'xx', 'xx', 'zz', 'zz'}},
	[0x67] = {color = '#5555FFF', script_command = 'VanishDummyObjDel', parameters = {}},
	[0x68] = {color = '#5555FFF', script_command = 'ObjTurn', parameters = {}},
	[0x69] = {color = '#5555FFF', script_command = 'PlayerPosGet', parameters = {'xx','xx','zz', 'zz'}},
	[0x6a] = {color = '#5555FFF', script_command = 'ObjPosGet', parameters = {'xx', 'zz'}},
	[0x6b] = {color = '#5555FFF', script_command = 'PlayerPosOffsetSet', parameters = {'xx', 'xx', 'yy', 'yy', 'zz', 'zz'}},
	[0x6c] = {color = '#5555FFF', script_command = 'NotZoneDelSet', parameters = {'obj', 'obj', 'flg'}},
	[0x6d] = {color = '#5555FFF', script_command = 'MoveCodeChange', parameters = {'obj', 'obj', 'cod', 'cod'}},
	[0x6e] = {color = '#5555FFF', script_command = 'PairObjIdSet', parameters = {}},
	[0x6f] = {color = '#5555FFF', script_command = 'AddGold', parameters = {'val', 'val', 'val', 'val'}},
	[0x70] = {color = '#5555FFF', script_command = 'SubGold', parameters = {'val', 'val', 'val', 'val'}},
	[0x71] = {color = '#5555FFF', script_command = 'CompGold', parameters = {'wk', 'wk', 'val', 'val', 'val', 'val'}},
	[0x72] = {color = '#5555FFF', script_command = 'GoldWinWrite', parameters = {'xx', 'xx', 'yy', 'yy'}},
	[0x73] = {color = '#5555FFF', script_command = 'GoldWinDel', parameters = {}},
	[0x74] = {color = '#5555FFF', script_command = 'GoldWrite', parameters = {}},
	[0x75] = {color = '#5555FFF', script_command = 'CoinWinWrite', parameters = {'xx', 'xx', 'zz', 'zz'}},
	[0x76] = {color = '#5555FFF', script_command = 'CoinWinDel', parameters = {}},
	[0x77] = {color = '#5555FFF', script_command = 'CoinWrite', parameters = {}},
	[0x78] = {color = '#5555FFF', script_command = 'CheckCoin', parameters = {'wk', 'wk'}},
	[0x79] = {color = '#5555FFF', script_command = 'AddCoin', parameters = {'val', 'val'}},
	[0x7a] = {color = '#5555FFF', script_command = 'SubCoin', parameters = {'val', 'val'}},
	[0x7b] = {color = '#5555FFF', script_command = 'AddItem', parameters = {'itm', 'itm', 'num', 'num', 'wk', 'wk'}},
	[0x7c] = {color = '#5555FFF', script_command = 'SubItem', parameters = {'itm', 'itm', 'num', 'num', 'wk', 'wk'}},
	[0x7d] = {color = '#5555FFF', script_command = 'AddItemChk', parameters = {'itm', 'itm', 'num', 'num', 'wk', 'wk'}},
	[0x7e] = {color = '#5555FFF', script_command = 'CheckItem', parameters = {'itm', 'itm', 'num', 'num', 'wk', 'wk'}},
	[0x7f] = {color = '#5555FFF', script_command = 'WazaMachineItemNoCheck', parameters = {'itm', 'itm', 'wk', 'wk'}},
	[0x80] = {color = '#5555FFF', script_command = 'GetPocketNo', parameters = {'itm', 'itm', 'wk', 'wk'}},
	[0x81] = {color = '#5555FFF', script_command = 'AddPCBoxItem', parameters = {}},
	[0x82] = {color = '#5555FFF', script_command = 'CheckPCBoxItem', parameters = {}},
	[0x83] = {color = '#5555FFF', script_command = 'AddGoods', parameters = {'gds', 'gds', 'num', 'num', 'wk', 'wk'}},
	[0x84] = {color = '#5555FFF', script_command = 'SubGoods', parameters = {'gds', 'gds', 'num', 'num', 'wk', 'wk'}},
	[0x85] = {color = '#5555FFF', script_command = 'AddGoodsChk', parameters = {'gds', 'gds', 'num', 'num', 'wk', 'wk'}},
	[0x86] = {color = '#5555FFF', script_command = 'CheckGoods', parameters = {'gds', 'gds', 'num', 'num', 'wk', 'wk'}},
	[0x87] = {color = '#5555FFF', script_command = 'AddTrap', parameters = {'trp', 'trp', 'num', 'num', 'wk', 'wk'}},
	[0x88] = {color = '#5555FFF', script_command = 'SubTrap', parameters = {'trp', 'trp', 'num', 'num', 'wk', 'wk'}},
	[0x89] = {color = '#5555FFF', script_command = 'AddTrapChk', parameters = {'trp', 'trp', 'num', 'num', 'wk', 'wk'}},
	[0x8a] = {color = '#5555FFF', script_command = 'CheckTrap', parameters = {'trp', 'trp', 'num', 'num', 'wk', 'wk'}},
	[0x8b] = {color = '#5555FFF', script_command = 'AddTreasure', parameters = {'trs', 'trs', 'num', 'num', 'wk', 'wk'}},
	[0x8c] = {color = '#5555FFF', script_command = 'SubTreasure', parameters = {'trs', 'trs', 'num', 'num', 'wk', 'wk'}},
	[0x8d] = {color = '#5555FFF', script_command = 'AddTreasureChk', parameters = {'trs', 'trs', 'num', 'num', 'wk', 'wk'}},
	[0x8e] = {color = '#5555FFF', script_command = 'CheckTreasure', parameters = {'trs', 'trs', 'num', 'num', 'wk', 'wk'}},
	[0x8f] = {color = '#5555FFF', script_command = 'AddTama', parameters = {'sph', 'sph', 'num', 'num', 'wk', 'wk'}},
	[0x90] = {color = '#5555FFF', script_command = 'SubTama', parameters = {'sph', 'sph', 'num', 'num', 'wk', 'wk'}},
	[0x91] = {color = '#5555FFF', script_command = 'AddTamaChk', parameters = {'sph', 'sph', 'num', 'num', 'wk', 'wk'}},
	[0x92] = {color = '#5555FFF', script_command = 'CheckTama', parameters = {'sph', 'sph', 'num', 'num', 'wk', 'wk'}},
	[0x93] = {color = '#5555FFF', script_command = 'CBItemNumGet', parameters = {'seal', 'seal', 'wk', 'wk'}},
	[0x94] = {color = '#5555FFF', script_command = 'CBItemNumAdd', parameters = {'seal', 'seal', 'num', 'num'}},
	[0x95] = {color = '#5555FFF', script_command = 'UnknownFormGet', parameters = {'pos', 'pos', 'wk', 'wk'}},
	[0x96] = {color = '#5555FFF', script_command = 'AddPokemon', parameters = {'sp', 'sp', 'lv', 'lv', 'itm', 'itm', 'wk', 'wk'}},
	[0x97] = {color = '#5555FFF', script_command = 'AddTamago', parameters = {'sp', 'sp', 'org', 'org'}},
	[0x98] = {color = '#5555FFF', script_command = 'ChgPokeWaza', parameters = {'pkm', 'pkm', 'ppi', 'ppi', 'mov', 'mov'}},
	[0x99] = {color = '#5555FFF', script_command = 'ChkPokeWaza', parameters = {'wk', 'wk', 'mov', 'mov', 'ppi', 'ppi'}},
	[0x9a] = {color = '#5555FFF', script_command = 'ChkPokeWazaGroup', parameters = {'wk', 'wk', 'mov', 'mov'}},
	[0x9b] = {color = '#5555FFF', script_command = 'RevengeTrainerSearch', parameters = {'tid', 'tid', 'wk', 'wk'}},
	[0x9c] = {color = '#5555FFF', script_command = 'SetWeather', parameters = {}},
	[0x9d] = {color = '#5555FFF', script_command = 'InitWeather', parameters = {}},
	[0x9e] = {color = '#5555FFF', script_command = 'UpdateWeather', parameters = {}},
	[0x9f] = {color = '#5555FFF', script_command = 'GetMapPosition', parameters = {'xx', 'xx', 'yy', 'yy'}},
	[0xa0] = {color = '#5555FFF', script_command = 'GetTemotiPokeNum', parameters = {}},
	[0xa1] = {color = '#5555FFF', script_command = 'SetMapProc', parameters = {}},
	[0xa2] = {color = '#5555FFF', script_command = 'WiFiAutoReg', parameters = {}},
	[0xa3] = {color = '#5555FFF', script_command = 'WiFiP2PMatchEventCall', parameters = {}},
	[0xa4] = {color = '#5555FFF', script_command = 'WiFiP2PMatchSetDel', parameters = {'wk', 'wk'}},
	[0xa5] = {color = '#5555FFF', script_command = 'MsgBoyEvent', parameters = {}},
	[0xa6] = {color = '#5555FFF', script_command = 'ImageClipSetProc', parameters = {}},
	[0xa7] = {color = '#5555FFF', script_command = 'ImageClipPreviewTvProc', parameters = {'ps'}},
	[0xa8] = {color = '#5555FFF', script_command = 'ImageClipPreviewConProc', parameters = {'ps'}},
	[0xa9] = {color = '#5555FFF', script_command = 'CustomBallEventCall', parameters = {}},
	[0xaa] = {color = '#5555FFF', script_command = 'TMapBGSetProc', parameters = {}},
	[0xab] = {color = '#5555FFF', script_command = 'BoxSetProc', parameters = {'mod'}},
	[0xac] = {color = '#5555FFF', script_command = 'OekakiBoardSetProc', parameters = {}},
	[0xad] = {color = '#5555FFF', script_command = 'CallTrCard', parameters = {}},
	[0xae] = {color = '#5555FFF', script_command = 'TradeListSetProc', parameters = {}},
	[0xaf] = {color = '#5555FFF', script_command = 'RecordCornerSetProc', parameters = {}},
	[0xb0] = {color = 'orange', script_command = 'DendouSetProc', parameters = {}},
	[0xb1] = {color = '#5555FFF', script_command = 'PcDendouSetProc', parameters = {}},
	[0xb2] = {color = '#5555FFF', script_command = 'WorldTradeSetProc', parameters = {'no', 'no', 'wk', 'wk'}},
	[0xb3] = {color = '#5555FFF', script_command = 'DPWInitProc', parameters = {'wk', 'wk'}},
	[0xb4] = {color = '#5555FFF', script_command = 'FirstPokeSelectProc', parameters = {}},
	[0xb5] = {color = '#5555FFF', script_command = 'FirstPokeSelectSetAndDel', parameters = {}},
	[0xb6] = {color = '#5555FFF', script_command = 'EyeTrainerMoveSet', parameters = {'pos', 'pos'}},
	[0xb7] = {color = '#5555FFF', script_command = 'EyeTrainerMoveCheck', parameters = {'pos', 'pos', 'wk', 'wk'}},
	[0xb8] = {color = '#5555FFF', script_command = 'EyeTrainerTypeGet', parameters = {'wk', 'wk'}},
	[0xb9] = {color = '#5555FFF', script_command = 'EyeTrainerIdGet', parameters = {'pos', 'pos', 'wk', 'wk'}},
	[0xba] = {color = '#5555FFF', script_command = 'NameIn', parameters = {'wk', 'wk'}},
	[0xbb] = {color = '#5555FFF', script_command = 'NameInPoke', parameters = {'ppi', 'ppi', 'wk', 'wk'}},
	[0xbc] = {color = '#5555FFF', script_command = 'WipeFadeStart', parameters = {'div', 'div', 'syn', 'syn', 'typ', 'typ', 'col', 'col'}},
	[0xbd] = {color = '#5555FFF', script_command = 'WipeFadeCheck', parameters = {}},
	[0xbe] = {color = '#5555FFF', script_command = 'MapChange', parameters = {'map', 'map', 'door', 'door', 'xx', 'xx', 'zz', 'zz', 'dir', 'dir'}},
	[0xbf] = {color = '#5555FFF', script_command = 'KabeNobori', parameters = {'ppi', 'ppi'}},
	[0xc0] = {color = '#5555FFF', script_command = 'Naminori', parameters = {'ppi', 'ppi'}},
	[0xc1] = {color = '#5555FFF', script_command = 'Takinobori', parameters = {'ppi', 'ppi'}},
	[0xc2] = {color = '#5555FFF', script_command = 'Sorawotobu', parameters = {'map', 'map', 'xx', 'xx', 'zz', 'zz'}},
	[0xc3] = {color = '#5555FFF', script_command = 'HidenFlash', parameters = {}},
	[0xc4] = {color = '#5555FFF', script_command = 'HidenKiribarai', parameters = {}},
	[0xc5] = {color = '#5555FFF', script_command = 'CutIn', parameters = {'ppi', 'ppi'}},
	[0xc6] = {color = '#5555FFF', script_command = 'ConHeroChange', parameters = {}},
	[0xc7] = {color = '#5555FFF', script_command = 'BicycleCheck', parameters = {'wk', 'wk'}},
	[0xc8] = {color = '#5555FFF', script_command = 'BicycleReq', parameters = {'flg'}},
	[0xc9] = {color = '#5555FFF', script_command = 'CyclingRoadSet', parameters = {'flg'}},
	[0xca] = {color = '#5555FFF', script_command = 'PlayerFormGet', parameters = {'wk', 'wk'}},
	[0xcb] = {color = '#5555FFF', script_command = 'PlayerReqBitOn', parameters = {'bit', 'bit'}},
	[0xcc] = {color = '#5555FFF', script_command = 'PlayerReqStart', parameters = {}},
	[0xcd] = {color = '#5555FFF', script_command = 'PlayerName', parameters = {'idx'}},
	[0xce] = {color = '#5555FFF', script_command = 'RivalName', parameters = {'idx'}},
	[0xcf] = {color = '#5555FFF', script_command = 'SupportName', parameters = {'idx'}},
	[0xd0] = {color = '#5555FFF', script_command = 'PokemonName', parameters = {'idx', 'ppi', 'ppi'}},
	[0xd1] = {color = '#5555FFF', script_command = 'ItemName', parameters = {'idx', 'itm', 'itm'}},
	[0xd2] = {color = '#5555FFF', script_command = 'PocketName', parameters = {'idx', 'pkt', 'pkt'}},
	[0xd3] = {color = '#5555FFF', script_command = 'ItemWazaName', parameters = {'idx', 'itm', 'itm'}},
	[0xd4] = {color = '#5555FFF', script_command = 'WazaName', parameters = {'idx', 'mov', 'mov'}},
	[0xd5] = {color = '#5555FFF', script_command = 'NumberName', parameters = {'idx', 'num', 'num'}},
	[0xd6] = {color = '#5555FFF', script_command = 'NickName', parameters = {'idx', 'ppi', 'ppi'}},
	[0xd7] = {color = '#5555FFF', script_command = 'PoketchName', parameters = {'idx', 'app', 'app'}},
	[0xd8] = {color = '#5555FFF', script_command = 'TrTypeName', parameters = {'idx', 'typ', 'typ'}},
	[0xd9] = {color = '#5555FFF', script_command = 'MyTrTypeName', parameters = {'idx'}},
	[0xda] = {color = '#5555FFF', script_command = 'PokemonNameExtra', parameters = {'idx', 'mon', 'mon', 'sex', 'sex', 'flg'}},
	[0xdb] = {color = '#5555FFF', script_command = 'FirstPokemonName', parameters = {'idx'}},
	[0xdc] = {color = '#5555FFF', script_command = 'RivalPokemonName', parameters = {'idx'}},
	[0xdd] = {color = '#5555FFF', script_command = 'SupportPokemonName', parameters = {'idx'}},
	[0xde] = {color = '#5555FFF', script_command = 'FirstPokeNoGet', parameters = {'wk', 'wk'}},
	[0xdf] = {color = '#5555FFF', script_command = 'GoodsName', parameters = {'idx'}},
	[0xe0] = {color = '#5555FFF', script_command = 'TrapName', parameters = {'idx', 'trp', 'trp'}},
	[0xe1] = {color = '#5555FFF', script_command = 'TamaName', parameters = {'idx', 'sph', 'sph'}},
	[0xe2] = {color = '#5555FFF', script_command = 'ZoneName', parameters = {'idx', 'map', 'map'}},
	[0xe3] = {color = '#5555FFF', script_command = 'GenerateInfoGet', parameters = {'map', 'map', 'pkm', 'pkm'}},
	[0xe4] = {color = '#5555FFF', script_command = 'TrainerIdGet', parameters = {'wk', 'wk'}},
	[0xe5] = {color = '#5555FFF', script_command = 'TrainerBattleSet', parameters = {'tr0', 'tr0', 'tr1', 'tr1'}},
	[0xe6] = {color = '#5555FFF', script_command = 'TrainerMessageSet', parameters = {'tr', 'tr', 'knd', 'knd'}},
	[0xe7] = {color = '#5555FFF', script_command = 'TrainerTalkTypeGet', parameters = {'wk1', 'wk1', 'wk2', 'wk2', 'wk3', 'wk3'}},
	[0xe8] = {color = '#5555FFF', script_command = 'RevengeTrainerTalkTypeGet', parameters = {'wk1', 'wk1', 'wk2', 'wk2', 'wk3', 'wk3'}},
	[0xe9] = {color = '#5555FFF', script_command = 'TrainerTypeGet', parameters = {'wk', 'wk'}},
	[0xea] = {color = '#5555FFF', script_command = 'TrainerBgmSet', parameters = {'tr', 'tr'}},
	[0xeb] = {color = '#5555FFF', script_command = 'TrainerLose', parameters = {}},
	[0xec] = {color = '#5555FFF', script_command = 'TrainerLoseCheck', parameters = {'wk', 'wk'}},
	[0xed] = {color = '#5555FFF', script_command = 'SeacretPokeRetryCheck', parameters = {'wk', 'wk'}},
	[0xee] = {color = '#5555FFF', script_command = '2vs2BattleCheck', parameters = {'wk', 'wk'}},
	[0xef] = {color = '#5555FFF', script_command = 'DebugBattleSet', parameters = {}},
	[0xf0] = {color = '#5555FFF', script_command = 'DebugTrainerFlagSet', parameters = {}},
	[0xf1] = {color = '#5555FFF', script_command = 'DebugTrainerFlagOnJump', parameters = {'pos', 'pos', 'pos', 'pos'}},
	[0xf2] = {color = '#5555FFF', script_command = 'ConnectSelParentWin', parameters = {}},
	[0xf3] = {color = '#5555FFF', script_command = 'ConnectSelChildWin', parameters = {}},
	[0xf4] = {color = '#5555FFF', script_command = 'ConnectDebugParentWin', parameters = {'wkid', 'wkid'}},
	[0xf5] = {color = '#5555FFF', script_command = 'ConnectDebugChildWin', parameters = {'wkid', 'wkid'}},
	[0xf6] = {color = '#5555FFF', script_command = 'DebugSioEncount', parameters = {}},
	[0xf7] = {color = '#5555FFF', script_command = 'DebugSioContest', parameters = {}},
	[0xf8] = {color = '#5555FFF', script_command = 'ConSioTimingSend', parameters = {'tim', 'tim'}},
	[0xf9] = {color = '#5555FFF', script_command = 'ConSioTimingCheck', parameters = {'tim', 'tim'}},
	[0xfa] = {color = '#5555FFF', script_command = 'ConSystemCreate', parameters = {'rnk', 'rnk', 'typ', 'typ', 'mod', 'mod', 'ppi', 'ppi'}}, 
	[0xfb] = {color = '#5555FFF', script_command = 'ConSystemExit', parameters = {'ppi', 'ppi'}},
	[0xfc] = {color = '#5555FFF', script_command = 'ConJudgeNameGet', parameters = {'jdg', 'jdg', 'buf', 'buf'}},
	[0xfd] = {color = '#5555FFF', script_command = 'ConBreederNameGet', parameters = {'ent', 'ent', 'buf', 'buf'}},
	[0xfe] = {color = '#5555FFF', script_command = 'ConNickNameGet', parameters = {'ent', 'ent', 'buf', 'buf'}},
	[0xff] = {color = '#5555FFF', script_command = 'ConNumTagSet', parameters = {'num', 'num', 'buf', 'buf'}},
	[0x100] = {color = '#5555FFF', script_command = 'ConSioParamInitSet', parameters = {}},
	[0x101] = {color = '#5555FFF', script_command = 'ContestProc', parameters = {}},
	[0x102] = {color = '#5555FFF', script_command = 'ConRankNameGet', parameters = {'buf', 'buf'}},
	[0x103] = {color = '#5555FFF', script_command = 'ConTypeNameGet', parameters = {'buf', 'buf'}},
	[0x104] = {color = '#5555FFF', script_command = 'ConVictoryBreederNameGet', parameters = {'buf', 'buf'}},
	[0x105] = {color = '#5555FFF', script_command = 'ConVictoryItemNoGet', parameters = {'wk', 'wk'}},
	[0x106] = {color = '#5555FFF', script_command = 'ConVictoryNickNameGet', parameters = {'buf', 'buf'}},
	[0x107] = {color = '#5555FFF', script_command = 'ConRankingCheck', parameters = {'wk', 'wk'}},
	[0x108] = {color = '#5555FFF', script_command = 'ConVictoryEntryNoGet', parameters = {'wk', 'wk'}},
	[0x109] = {color = '#5555FFF', script_command = 'ConMyEntryNoGet', parameters = {'wk', 'wk'}},
	[0x10a] = {color = '#5555FFF', script_command = 'ConObjCodeGet', parameters = {'ent', 'ent', 'wk', 'wk'}},
	[0x10b] = {color = '#5555FFF', script_command = 'ConPopularityGet', parameters = {'ent', 'ent', 'wk', 'wk'}},
	[0x10c] = {color = '#5555FFF', script_command = 'ConDeskModeGet', parameters = {'wk', 'wk'}},
	[0x10d] = {color = '#5555FFF', script_command = 'ConHaveRibbonCheck', parameters = {'wk', 'wk'}},
	[0x10e] = {color = '#5555FFF', script_command = 'ConRibbonNameGet', parameters = {'buf', 'buf'}},
	[0x10f] = {color = '#5555FFF', script_command = 'ConAcceNoGet', parameters = {'wk', 'wk'}},
	[0x110] = {color = '#5555FFF', script_command = 'ConEntryParamGet', parameters = {'rnk', 'rnk', 'typ', 'typ', 'mod', 'mod', 'ppi', 'ppi'}},
	[0x111] = {color = '#5555FFF', script_command = 'ConCameraFlashSet', parameters = {'ent', 'ent'}},
	[0x112] = {color = '#5555FFF', script_command = 'ConCameraFlashCheck', parameters = {}},
	[0x113] = {color = '#5555FFF', script_command = 'ConHBlankStop', parameters = {}},
	[0x114] = {color = '#5555FFF', script_command = 'ConHBlankStart', parameters = {}},
	[0x115] = {color = '#5555FFF', script_command = 'ConEndingSkipCheck', parameters = {'wk', 'wk'}},
	[0x116] = {color = '#5555FFF', script_command = 'ConRecordDisp', parameters = {}},
	[0x117] = {color = '#5555FFF', script_command = 'ConMsgPrintFlagSet', parameters = {}},
	[0x118] = {color = '#5555FFF', script_command = 'ConMsgPrintFlagReset', parameters = {}},
	[0x119] = {color = '#5555FFF', script_command = 'ChkTemotiPokerus', parameters = {'wk', 'wk'}},
	[0x11a] = {color = '#5555FFF', script_command = 'TemotiPokeSexGet', parameters = {'ppi', 'ppi', 'wk', 'wk'}},
	[0x11b] = {color = '#5555FFF', script_command = 'SpLocationSet', parameters = {'map', 'map', 'door', 'door', 'xx', 'xx', 'zz', 'zz', 'dir', 'dir'}},
	[0x11c] = {color = '#5555FFF', script_command = 'ElevatorNowFloorGet', parameters = {'wk', 'wk'}},
	[0x11d] = {color = '#5555FFF', script_command = 'ElevatorFloorWrite', parameters = {'xx', 'yy', 'wk', 'wk'}},
	[0x11e] = {color = '#5555FFF', script_command = 'GetShinouZukanSeeNum', parameters = {'wk', 'wk'}},
	[0x11f] = {color = '#5555FFF', script_command = 'GetShinouZukanGetNum', parameters = {'wk', 'wk'}},
	[0x120] = {color = '#5555FFF', script_command = 'GetZenkokuZukanSeeNum', parameters = {'wk', 'wk'}},
	[0x121] = {color = '#5555FFF', script_command = 'GetZenkokuZukanGetNum', parameters = {'wk', 'wk'}},
	[0x122] = {color = '#5555FFF', script_command = 'ChkZenkokuZukan', parameters = {}},
	[0x123] = {color = '#5555FFF', script_command = 'GetZukanHyoukaMsgID', parameters = {'mod', 'wk', 'wk'}},
	[0x124] = {color = '#5555FFF', script_command = 'WildBattleSet', parameters = {'pkm', 'pkm', 'lv', 'lv'}},
	[0x125] = {color = '#5555FFF', script_command = 'FirstBattleSet', parameters = {'pkm', 'pkm', 'lv', 'lv'}},
	[0x126] = {color = '#5555FFF', script_command = 'CaptureBattleSet', parameters = {}},
	[0x127] = {color = '#5555FFF', script_command = 'HoneyTree', parameters = {}},
	[0x128] = {color = '#5555FFF', script_command = 'GetHoneyTreeState', parameters = {'wk', 'wk'}},
	[0x129] = {color = '#5555FFF', script_command = 'HoneyTreeBattleSet', parameters = {}},
	[0x12a] = {color = '#5555FFF', script_command = 'HoneyAfterTreeBattleSet', parameters = {}},
	[0x12b] = {color = '#5555FFF', script_command = 'TSignSetProc', parameters = {}},
	[0x12c] = {color = '#5555FFF', script_command = 'ReportSaveCheck', parameters = {'wk', 'wk'}},
	[0x12d] = {color = '#5555FFF', script_command = 'ReportSave', parameters = {'wk', 'wk'}},
	[0x12e] = {color = '#5555FFF', script_command = 'ImageClipTvSaveDataCheck', parameters = {'dat', 'dat', 'wk', 'wk'}},
	[0x12f] = {color = '#5555FFF', script_command = 'ImageClipConSaveDataCheck', parameters = {'dat', 'dat', 'wk', 'wk'}},
	[0x130] = {color = '#5555FFF', script_command = 'ImageClipTvSaveTitle', parameters = {'dat', 'dat'}},
	[0x131] = {color = '#5555FFF', script_command = 'GetPoketch', parameters = {}},
	[0x132] = {color = '#5555FFF', script_command = 'GetPoketchFlag', parameters = {'wk', 'wk'}},
	[0x133] = {color = '#5555FFF', script_command = 'PoketchAppAdd', parameters = {'app', 'app'}},
	[0x134] = {color = '#5555FFF', script_command = 'PoketchAppCheck', parameters = {'app', 'app', 'wk', 'wk'}},
	[0x135] = {color = '#5555FFF', script_command = 'CommTimingSyncStart', parameters = {'no', 'no'}},
	[0x136] = {color = '#5555FFF', script_command = 'CommTempDataReset', parameters = {}},
	[0x137] = {color = '#5555FFF', script_command = 'UnionParentCardTalkNo', parameters = {'wk', 'wk'}},
	[0x138] = {color = '#5555FFF', script_command = 'UnionGetInfoTalkNo', parameters = {'wk', 'wk'}},
	[0x139] = {color = '#5555FFF', script_command = 'UnionBeaconChange', parameters = {'mod', 'mod'}},
	[0x13a] = {color = '#5555FFF', script_command = 'UnionConnectTalkDenied', parameters = {}},
	[0x13b] = {color = '#5555FFF', script_command = 'UnionConnectTalkOk', parameters = {}},
	[0x13c] = {color = '#5555FFF', script_command = 'UnionTrainerNameRegist', parameters = {'typ', 'typ'}},
	[0x13d] = {color = '#5555FFF', script_command = 'UnionReturnSetUp', parameters = {}},
	[0x13e] = {color = '#5555FFF', script_command = 'UnionConnectCutRestart', parameters = {}},
	[0x13f] = {color = '#5555FFF', script_command = 'UnionGetTalkNumber', parameters = {'typ', 'typ', 'wk', 'wk'}},
	[0x140] = {color = '#5555FFF', script_command = 'UnionIdSet', parameters = {'wk', 'wk'}},
	[0x141] = {color = '#5555FFF', script_command = 'UnionResultGet', parameters = {'wk', 'wk'}},
	[0x142] = {color = '#5555FFF', script_command = 'UnionObjAllVanish', parameters = {}},
	[0x143] = {color = '#5555FFF', script_command = 'UnionScriptResultSet', parameters = {'typ', 'typ', 'num', 'num'}},
	[0x144] = {color = '#5555FFF', script_command = 'UnionParentStartCommandSet', parameters = {'wk', 'wk'}},
	[0x145] = {color = '#5555FFF', script_command = 'UnionChildSelectCommandSet', parameters = {'wk', 'wk'}},
	[0x146] = {color = '#5555FFF', script_command = 'UnionConnectStart', parameters = {'typ', 'typ', 'wk', 'wk'}},
	[0x147] = {color = '#5555FFF', script_command = 'ShopCall', parameters = {'id', 'id'}},
	[0x148] = {color = '#5555FFF', script_command = 'FixShopCall', parameters = {'id', 'id'}},
	[0x149] = {color = '#5555FFF', script_command = 'FixGoodsCall', parameters = {'id', 'id'}},
	[0x14a] = {color = '#5555FFF', script_command = 'FixSealCall', parameters = {'id', 'id'}},
	[0x14b] = {color = '#5555FFF', script_command = 'GameOverCall', parameters = {}},
	[0x14c] = {color = '#5555FFF', script_command = 'SetWarpId', parameters = {'id', 'id'}},
	[0x14d] = {color = '#5555FFF', script_command = 'GetMySex', parameters = {'wk', 'wk'}},
	[0x14e] = {color = '#5555FFF', script_command = 'PcKaifuku', parameters = {}},
	[0x14f] = {color = '#5555FFF', script_command = 'UgManShopNpcRandomPlace', parameters = {}},
	[0x150] = {color = '#5555FFF', script_command = 'CommDirectEnd', parameters = {}},
	[0x151] = {color = '#5555FFF', script_command = 'CommDirectEnterBtlRoom', parameters = {}},
	[0x152] = {color = '#5555FFF', script_command = 'CommPlayerSetDir', parameters = {'dir', 'dir'}},
	[0x153] = {color = '#5555FFF', script_command = 'UnionMapChange', parameters = {}},
	[0x154] = {color = '#5555FFF', script_command = 'UnionViewSetUpTrainerTypeSelect', parameters = {}},
	[0x155] = {color = '#5555FFF', script_command = 'UnionViewGetTrainerType', parameters = {'ans', 'ans', 'wk', 'wk'}},
	[0x156] = {color = '#5555FFF', script_command = 'UnionViewMyStatusSet', parameters = {'typ', 'typ'}},
	[0x157] = {color = '#5555FFF', script_command = 'SysFlagZukanGet', parameters = {'wk', 'wk'}},
	[0x158] = {color = '#5555FFF', script_command = 'SysFlagZukanSet', parameters = {}},
	[0x159] = {color = '#5555FFF', script_command = 'SysFlagShoesGet', parameters = {'wk', 'wk'}},
	[0x15a] = {color = '#5555FFF', script_command = 'SysFlagShoesSet', parameters = {}},
	[0x15b] = {color = '#5555FFF', script_command = 'SysFlagBadgeGet', parameters = {'no', 'no', 'wk', 'wk'}},
	[0x15c] = {color = '#5555FFF', script_command = 'SysFlagBadgeSet', parameters = {'no', 'no'}},
	[0x15d] = {color = '#5555FFF', script_command = 'SysFlagBadgeCount', parameters = {'wk', 'wk'}},
	[0x15e] = {color = '#5555FFF', script_command = 'SysFlagBagGet', parameters = {'wk', 'wk'}},
	[0x15f] = {color = '#5555FFF', script_command = 'SysFlagBagSet', parameters = {}},
	[0x160] = {color = '#5555FFF', script_command = 'SysFlagPairGet', parameters = {'wk', 'wk'}},
	[0x161] = {color = '#5555FFF', script_command = 'SysFlagPairSet', parameters = {}},
	[0x162] = {color = '#5555FFF', script_command = 'SysFlagPairReset', parameters = {}},
	[0x163] = {color = '#5555FFF', script_command = 'SysFlagOneStepGet', parameters = {'wk', 'wk'}},
	[0x164] = {color = '#5555FFF', script_command = 'SysFlagOneStepSet', parameters = {}},
	[0x165] = {color = '#5555FFF', script_command = 'SysFlagOneStepReset', parameters = {}},
	[0x166] = {color = '#5555FFF', script_command = 'SysFlagGameClearGet', parameters = {'wk', 'wk'}},
	[0x167] = {color = '#5555FFF', script_command = 'SysFlagGameClearSet', parameters = {}},
	[0x168] = {color = '#5555FFF', script_command = 'SetUpDoorAnime', parameters = {'bx', 'bx', 'bz', 'bz', 'lx', 'lx', 'lz', 'lz', 'ent'}},
	[0x169] = {color = '#5555FFF', script_command = 'Wait3DAnime', parameters = {'ent'}},
	[0x16a] = {color = '#5555FFF', script_command = 'Free3DAnime', parameters = {'ent'}},
	[0x16b] = {color = '#5555FFF', script_command = 'OpenDoor', parameters = {'ent'}},
	[0x16c] = {color = '#5555FFF', script_command = 'CloseDoor', parameters = {'ent'}},
	[0x16d] = {color = '#5555FFF', script_command = 'GetSodateyaName', parameters = {}},
	[0x16e] = {color = '#5555FFF', script_command = 'GetSodateyaZiisan', parameters = {'wk', 'wk'}},
	[0x16f] = {color = '#5555FFF', script_command = 'InitWaterGym', parameters = {}},
	[0x170] = {color = '#5555FFF', script_command = 'PushWaterGymButton', parameters = {}},
	[0x171] = {color = '#5555FFF', script_command = 'InitGhostGym', parameters = {}}, 
	[0x172] = {color = '#5555FFF', script_command = 'MoveGhostGymLift', parameters = {}},
	[0x173] = {color = '#5555FFF', script_command = 'InitSteelGym', parameters = {}},
	[0x174] = {color = '#5555FFF', script_command = 'InitCombatGym', parameters = {}},
	[0x175] = {color = '#5555FFF', script_command = 'InitElecGym', parameters = {'room'}},
	[0x176] = {color = '#5555FFF', script_command = 'RotElecGymGear', parameters = {'rot'}},
	[0x177] = {color = '#5555FFF', script_command = 'GetPokeCount', parameters = {'wk', 'wk'}},
	[0x178] = {color = '#5555FFF', script_command = 'BagSetProc', parameters = {'mod'}},
	[0x179] = {color = '#5555FFF', script_command = 'BagGetResult', parameters = {'wk', 'wk'}},
	[0x17a] = {color = '#5555FFF', script_command = 'PocketCheck', parameters = {'pkt', 'pkt', 'wk', 'wk'}},
	[0x17b] = {color = '#5555FFF', script_command = 'NutsName', parameters = {'idx', 'nut', 'nut', 'cnt', 'cnt'}},
	[0x17c] = {color = '#5555FFF', script_command = 'SeikakuName', parameters = {'idx', 'nat', 'nat'}},
	[0x17d] = {color = '#5555FFF', script_command = 'SeedGetStatus', parameters = {'wk', 'wk'}},
	[0x17e] = {color = '#5555FFF', script_command = 'SeedGetType', parameters = {'wk', 'wk'}},
	[0x17f] = {color = '#5555FFF', script_command = 'SeedGetCompost', parameters = {'wk', 'wk'}},
	[0x180] = {color = '#5555FFF', script_command = 'SeedGetGroundStatus', parameters = {'wk', 'wk'}},
	[0x181] = {color = '#5555FFF', script_command = 'SeedGetNutsCount', parameters = {'wk', 'wk'}},
	[0x182] = {color = '#5555FFF', script_command = 'SeedSetCompost', parameters = {'mul', 'mul'}},
	[0x183] = {color = '#5555FFF', script_command = 'SeedSetNuts', parameters = {'nut', 'nut'}},
	[0x184] = {color = '#5555FFF', script_command = 'SeedSetWater', parameters = {'swt', 'swt'}},
	[0x185] = {color = '#5555FFF', script_command = 'SeedTakeNuts', parameters = {}},
	[0x186] = {color = '#5555FFF', script_command = 'SxyPosChange', parameters = {'id', 'id', 'gx', 'gx', 'gz', 'gz'}},
	[0x187] = {color = '#5555FFF', script_command = 'ObjPosChange', parameters = {'obj', 'obj', 'xx', 'xx', 'yy', 'yy', 'zz', 'zz', 'dir', 'dir'}},
	[0x188] = {color = '#5555FFF', script_command = 'SxyMoveCodeChange', parameters = {'id', 'id', 'mv', 'mv'}},
	[0x189] = {color = '#5555FFF', script_command = 'SxyDirChange', parameters = {'id', 'id', 'dir', 'dir'}},
	[0x18a] = {color = '#5555FFF', script_command = 'SxyExitPosChange', parameters = {'id', 'id', 'xx', 'xx', 'zz', 'zz'}},
	[0x18b] = {color = '#5555FFF', script_command = 'SxyBgPosChange', parameters = {'id', 'id', 'xx', 'xx', 'zz', 'zz'}},
	[0x18c] = {color = '#5555FFF', script_command = 'ObjDirChange', parameters = {'obj', 'obj', 'dir', 'dir'}},
	[0x18d] = {color = '#5555FFF', script_command = 'TimeWaitIconAdd', parameters = {}},
	[0x18e] = {color = '#5555FFF', script_command = 'TimeWaitIconDel', parameters = {}},
	[0x18f] = {color = '#5555FFF', script_command = 'ReturnScriptWkSet', parameters = {'num', 'num'}},
	[0x190] = {color = '#5555FFF', script_command = 'ABKeyTimeWait', parameters = {'wk', 'wk'}},
	[0x191] = {color = '#5555FFF', script_command = 'PokeListSetProc', parameters = {}},
	[0x192] = {color = '#5555FFF', script_command = 'UnionPokeListSetProc', parameters = {}},
	[0x193] = {color = '#5555FFF', script_command = 'PokeListGetResult', parameters = {'wk', 'wk'}},
	[0x194] = {color = '#5555FFF', script_command = 'ConPokeListSetProc', parameters = {'pos', 'pos', 'rnk', 'rnk', 'typ', 'typ', 'sio', 'sio'}},
	[0x195] = {color = '#5555FFF', script_command = 'ConPokeListGetResult', parameters = {'wk', 'wk', 'mod', 'mod'}},
	[0x196] = {color = '#5555FFF', script_command = 'ConPokeStatusSetProc', parameters = {'pos', 'pos'}},
	[0x197] = {color = '#5555FFF', script_command = 'PokeStatusGetResult', parameters = {'wk', 'wk'}},
	[0x198] = {color = '#5555FFF', script_command = 'TemotiMonsNo', parameters = {'iwk', 'iwk', 'owk', 'owk'}},
	[0x199] = {color = '#5555FFF', script_command = 'MonsOwnChk', parameters = {'iwk', 'iwk', 'owk', 'owk'}},
	[0x19a] = {color = '#5555FFF', script_command = 'GetPokeCount2', parameters = {'wk', 'wk'}},
	[0x19b] = {color = '#5555FFF', script_command = 'GetPokeCount3', parameters = {'wk', 'wk', 'num', 'num'}},
	[0x19c] = {color = '#5555FFF', script_command = 'GetPokeCount4', parameters = {'wk', 'wk'}},
	[0x19d] = {color = '#5555FFF', script_command = 'GetTamagoCount', parameters = {'wk', 'wk'}},
	[0x19e] = {color = '#5555FFF', script_command = 'UgShopMenuInit', parameters = {'typ', 'typ', 'wkid', 'wkid'}},
	[0x19f] = {color = '#5555FFF', script_command = 'UgShopTalkStart', parameters = {'msg', 'msg'}},
	[0x1a0] = {color = '#5555FFF', script_command = 'UgShopTalkEnd', parameters = {}},
	[0x1a1] = {color = '#5555FFF', script_command = 'UgShopTalkRegisterItemName', parameters = {'idx', 'typ', 'typ'}},
	[0x1a2] = {color = '#5555FFF', script_command = 'UgShopTalkRegisterTrapName', parameters = {'idx', 'typ', 'typ'}},
	[0x1a3] = {color = '#5555FFF', script_command = 'SubMyGold', parameters = {'gld', 'gld'}},
	[0x1a4] = {color = '#5555FFF', script_command = 'HikitoriPoke', parameters = {'wk', 'wk', 'no', 'no'}},
	[0x1a5] = {color = '#5555FFF', script_command = 'HikitoriList', parameters = {'wk', 'wk'}},
	[0x1a6] = {color = '#5555FFF', script_command = 'MsgSodateyaAishou', parameters = {}},
	[0x1a7] = {color = '#5555FFF', script_command = 'MsgExpandBuf', parameters = {}},
	[0x1a8] = {color = '#5555FFF', script_command = 'DelSodateyaEgg', parameters = {}},
	[0x1a9] = {color = '#5555FFF', script_command = 'GetSodateyaEgg', parameters = {}},
	[0x1aa] = {color = '#5555FFF', script_command = 'HikitoriRyoukin', parameters = {'wk', 'wk', 'no', 'no'}},
	[0x1ab] = {color = '#5555FFF', script_command = 'CompMyGold', parameters = {'wk', 'wk', 'gld', 'gld'}},
	[0x1ac] = {color = '#5555FFF', script_command = 'TamagoDemo', parameters = {}},
	[0x1ad] = {color = '#5555FFF', script_command = 'SodateyaPokeList', parameters = {'wk', 'wk'}},
	[0x1ae] = {color = '#5555FFF', script_command = 'SodatePokeLevelStr', parameters = {'wk', 'wk', 'no', 'no'}},
	[0x1af] = {color = '#5555FFF', script_command = 'MsgAzukeSet', parameters = {'wkno', 'wkno', 'no', 'no', 'wk', 'wk'}},
	[0x1b0] = {color = '#5555FFF', script_command = 'SetSodateyaPoke', parameters = {'ppi'}},
	[0x1b1] = {color = '#5555FFF', script_command = 'ObjVisible', parameters = {'obj', 'obj'}},
	[0x1b2] = {color = '#5555FFF', script_command = 'ObjInvisible', parameters = {'obj', 'obj'}},
	[0x1b3] = {color = '#5555FFF', script_command = 'MailBox', parameters = {}},
	[0x1b4] = {color = '#5555FFF', script_command = 'GetMailBoxDataNum', parameters = {'wk', 'wk'}},
	[0x1b5] = {color = '#5555FFF', script_command = 'RankingView', parameters = {}},
	[0x1b6] = {color = '#5555FFF', script_command = 'GetTimeZone', parameters = {'wk', 'wk'}},
	[0x1b7] = {color = '#5555FFF', script_command = 'GetRand', parameters = {'wk', 'wk', 'lim', 'lim'}},
	[0x1b8] = {color = '#5555FFF', script_command = 'GetRandNext', parameters = {'wk', 'wk', 'lim', 'lim'}},
	[0x1b9] = {color = '#5555FFF', script_command = 'GetNatsuki', parameters = {'wk', 'wk', 'ppi', 'ppi'}},
	[0x1ba] = {color = '#5555FFF', script_command = 'AddNatsuki', parameters = {'add', 'add', 'ppi', 'ppi'}},
	[0x1bb] = {color = '#5555FFF', script_command = 'SubNatsuki', parameters = {'add', 'add', 'ppi', 'ppi'}},
	[0x1bc] = {color = '#5555FFF', script_command = 'HikitoriListNameSet', parameters = {'bf1', 'bf1', 'bf2', 'bf2', 'bf3', 'bf3', 'no', 'no'}},
	[0x1bd] = {color = '#5555FFF', script_command = 'PlayerDirGet', parameters = {'dir', 'dir'}},
	[0x1be] = {color = '#5555FFF', script_command = 'GetSodateyaAishou', parameters = {'wk', 'wk'}},
	[0x1bf] = {color = '#5555FFF', script_command = 'GetSodateyaTamagoCheck', parameters = {'wk', 'wk'}},
	[0x1c0] = {color = '#5555FFF', script_command = 'TemotiPokeChk', parameters = {'wk', 'wk', 'pkm', 'pkm'}},
	[0x1c1] = {color = '#5555FFF', script_command = 'OokisaRecordChk', parameters = {'wk', 'wk', 'num', 'num'}},
	[0x1c2] = {color = '#5555FFF', script_command = 'OokisaRecordSet', parameters = {'num', 'num'}},
	[0x1c3] = {color = '#5555FFF', script_command = 'OokisaTemotiSet', parameters = {'bf1', 'bf1', 'bf2', 'bf2', 'num', 'num'}},
	[0x1c4] = {color = '#5555FFF', script_command = 'OokisaKirokuSet', parameters = {'bf1', 'bf1', 'bf2', 'bf2', 'pkm', 'pkm'}},
	[0x1c5] = {color = '#5555FFF', script_command = 'OokisaKurabeInit', parameters = {}},
	[0x1c6] = {color = '#5555FFF', script_command = 'WazaListSetProc', parameters = {'ppi', 'ppi'}},
	[0x1c7] = {color = '#5555FFF', script_command = 'WazaListGetResult', parameters = {'wk', 'wk'}},
	[0x1c8] = {color = '#5555FFF', script_command = 'WazaCount', parameters = {'wk', 'wk', 'ppi', 'ppi'}}, 
	[0x1c9] = {color = '#5555FFF', script_command = 'WazaDel', parameters = {'ppi', 'ppi', 'mov', 'mov'}},
	[0x1ca] = {color = '#5555FFF', script_command = 'TemotiWazaNo', parameters = {'wk', 'wk', 'ppi', 'ppi', 'mov', 'mov'}},
	[0x1cb] = {color = '#5555FFF', script_command = 'TemotiWazaName', parameters = {'idx', 'ppi', 'ppi', 'mov', 'mov'}},
	[0x1cc] = {color = '#5555FFF', script_command = 'FNoteStartSet', parameters = {}},
	[0x1cd] = {color = '#5555FFF', script_command = 'FNoteDataMake', parameters = {'id', 'id', 'wk1', 'wk1', 'wk2', 'wk2', 'wk3', 'wk3', 'wk4', 'wk4'}},
	[0x1ce] = {color = '#5555FFF', script_command = 'FNoteDataSave', parameters = {}},
	[0x1cf] = {color = '#5555FFF', script_command = 'SysFlagKairiki', parameters = {'mod', 'wk', 'wk'}},
	[0x1d0] = {color = '#5555FFF', script_command = 'SysFlagFlash', parameters = {'mod', 'wk', 'wk'}},
	[0x1d1] = {color = '#5555FFF', script_command = 'SysFlagKiribarai', parameters = {'mod', 'wk', 'wk'}},
	[0x1d2] = {color = '#5555FFF', script_command = 'ImcAcceAddItem', parameters = {'acc', 'acc', 'num', 'num'}},
	[0x1d3] = {color = '#5555FFF', script_command = 'ImcAcceAddItemChk', parameters = {'acc', 'acc', 'num', 'num', 'wk', 'wk'}},
	[0x1d4] = {color = '#5555FFF', script_command = 'ImcAcceCheckItem', parameters = {'acc', 'acc', 'num', 'num', 'wk', 'wk'}},
	[0x1d5] = {color = '#5555FFF', script_command = 'ImcBgAddItem', parameters = {'bg', 'bg'}},
	[0x1d6] = {color = '#5555FFF', script_command = 'ImcBgCheckItem', parameters = {'bg', 'bg', 'wk', 'wk'}},
	[0x1d7] = {color = '#5555FFF', script_command = 'NutMixerProc', parameters = {}},
	[0x1d8] = {color = '#5555FFF', script_command = 'NutMixerPlayStateCheck', parameters = {'wk', 'wk'}},
	[0x1d9] = {color = '#5555FFF', script_command = 'BTowerAppSetProc', parameters = {}},
	[0x1da] = {color = '#5555FFF', script_command = 'BattleTowerWorkClear', parameters = {}},
	[0x1db] = {color = '#5555FFF', script_command = 'BattleTowerWorkInit', parameters = {'ini', 'ini', 'mod', 'mod'}},
	[0x1dc] = {color = '#5555FFF', script_command = 'BattleTowerWorkRelease', parameters = {}},
	[0x1dd] = {color = '#5555FFF', script_command = 'BattleTowerTools', parameters = {'com', 'com', 'prm', 'prm', 'wk', 'wk'}},
	[0x1de] = {color = '#5555FFF', script_command = 'BattleTowerGetSevenPokeData', parameters = {'id', 'id', 'idx', 'idx', 'pkm', 'pkm', 'mov', 'mov'}},
	[0x1df] = {color = '#5555FFF', script_command = 'BattleTowerIsPrizeGet', parameters = {'wkid', 'wkid'}},
	[0x1e0] = {color = '#5555FFF', script_command = 'BattleTowerIsPrizemanSet', parameters = {'wkid', 'wkid'}},
	[0x1e1] = {color = '#5555FFF', script_command = 'BattleTowerSendBuf', parameters = {'mod', 'mod', 'prm', 'prm'}},
	[0x1e2] = {color = '#5555FFF', script_command = 'BattleTowerRecvBuf', parameters = {'mod', 'mod', 'wkid', 'wkid'}},
	[0x1e3] = {color = '#5555FFF', script_command = 'BattleTowerGetLeaderRoomID', parameters = {'rt1', 'rt1', 'rt2', 'rt2'}},
	[0x1e4] = {color = '#5555FFF', script_command = 'BattleTowerIsLeaderDataExist', parameters = {'wk', 'wk'}},
	[0x1e5] = {color = '#5555FFF', script_command = 'RecordInc', parameters = {'rec', 'rec'}},
	[0x1e6] = {color = '#5555FFF', script_command = 'RecordGet', parameters = {'rec', 'rec', 'hwk', 'hwk', 'lwk', 'lwk'}},
	[0x1e7] = {color = '#5555FFF', script_command = 'RecordSet', parameters = {'rec', 'rec', 'vl1', 'vl1', 'vl2', 'vl2', 'mod'}},
	[0x1e8] = {color = '#5555FFF', script_command = 'ZukanChkShinou', parameters = {'wk', 'wk'}},
	[0x1e9] = {color = '#5555FFF', script_command = 'ZukanChkNational', parameters = {'wk', 'wk'}},
	[0x1ea] = {color = '#5555FFF', script_command = 'ZukanRecongnizeShinou', parameters = {}},
	[0x1eb] = {color = '#5555FFF', script_command = 'ZukanRecongnizeNational', parameters = {}},
	[0x1ec] = {color = '#5555FFF', script_command = 'UrayamaEncountSet', parameters = {}},
	[0x1ed] = {color = '#5555FFF', script_command = 'UrayamaEncountNoChk', parameters = {'wk', 'wk'}},
	[0x1ee] = {color = '#5555FFF', script_command = 'PokeMailChk', parameters = {'wk', 'wk', 'ppi', 'ppi'}},
	[0x1ef] = {color = '#5555FFF', script_command = 'PaperplaneSet', parameters = {'wk', 'wk'}},
	[0x1f0] = {color = '#5555FFF', script_command = 'PokeMailDel', parameters = {'ppi', 'ppi'}},
	[0x1f1] = {color = '#5555FFF', script_command = 'KasekiCount', parameters = {'wk', 'wk'}},
	[0x1f2] = {color = '#5555FFF', script_command = 'ItemListSetProc', parameters = {}},
	[0x1f3] = {color = '#5555FFF', script_command = 'ItemListGetResult', parameters = {}},
	[0x1f4] = {color = '#5555FFF', script_command = 'ItemNoToMonsNo', parameters = {'wk', 'wk', 'itm', 'itm'}},
	[0x1f5] = {color = '#5555FFF', script_command = 'KasekiItemNo', parameters = {'wki', 'wki', 'wkm', 'wkm', 'tno', 'tno'}},
	[0x1f6] = {color = '#5555FFF', script_command = 'PokeLevelChk', parameters = {'wk', 'wk', 'lv', 'lv'}},
	[0x1f7] = {color = '#5555FFF', script_command = 'ApprovePoisonDead', parameters = {'wk', 'wk', 'ppi', 'ppi'}},
	[0x1f8] = {color = '#5555FFF', script_command = 'FinishMapProc', parameters = {}},
	[0x1f9] = {color = '#5555FFF', script_command = 'DebugWatch', parameters = {'val', 'val'}},
	[0x1fa] = {color = '#5555FFF', script_command = 'TalkMsgAllPutOtherArc', parameters = {'arc', 'arc', 'msg', 'msg'}},
	[0x1fb] = {color = '#5555FFF', script_command = 'TalkMsgOtherArc', parameters = {'arc', 'arc', 'msg', 'msg'}},
	[0x1fc] = {color = '#5555FFF', script_command = 'TalkMsgAllPutPMS', parameters = {'typ', 'typ', 'id', 'id', 'wd0', 'wd0', 'wd1', 'wd1'}},
	[0x1fd] = {color = '#5555FFF', script_command = 'TalkMsgPMS', parameters = {'typ', 'typ', 'id', 'id', 'wd0', 'wd0', 'wd1', 'wd1'}},
	[0x1fe] = {color = '#5555FFF', script_command = 'TalkMsgTowerApper', parameters = {'tr', 'tr'}},
	[0x1ff] = {color = '#5555FFF', script_command = 'TalkMsgNgPokeName', parameters = {'msg', 'pkn', 'pkn', 'sex', 'sex', 'flg'}},
	[0x200] = {color = '#5555FFF', script_command = 'GetBeforeZoneID', parameters = {'wk', 'wk'}},
	[0x201] = {color = '#5555FFF', script_command = 'GetNowZoneID', parameters = {'wk', 'wk'}},
	[0x202] = {color = '#5555FFF', script_command = 'SafariControl', parameters = {'flg'}},
	[0x203] = {color = '#5555FFF', script_command = 'ColosseumMapChangeIn', parameters = {'map', 'map', 'door', 'door', 'xx', 'xx', 'zz', 'zz', 'dir', 'dir'}},
	[0x204] = {color = '#5555FFF', script_command = 'ColosseumMapChangeOut', parameters = {}},
	[0x205] = {color = '#5555FFF', script_command = 'WifiEarthSetProc', parameters = {}},
	[0x206] = {color = '#5555FFF', script_command = 'CallSafariScope', parameters = {}},
	[0x207] = {color = '#5555FFF', script_command = 'CommGetCurrentID', parameters = {'wk', 'wk'}},
	[0x208] = {color = '#5555FFF', script_command = 'PokeWindowPut', parameters = {'pkm', 'pkm', 'sex', 'sex'}},
	[0x209] = {color = '#5555FFF', script_command = 'PokeWindowDel', parameters = {}},
	[0x20a] = {color = '#5555FFF', script_command = 'BtlSearcherEventCall', parameters = {'wkid', 'wkid'}},
	[0x20b] = {color = '#5555FFF', script_command = 'BtlSearcherDirMvSet', parameters = {}},
	[0x20c] = {color = '#5555FFF', script_command = 'MsgAutoGet', parameters = {}},
	[0x20d] = {color = '#5555FFF', script_command = 'ClimaxDemoCall', parameters = {'id', 'wk', 'wk'}},
	[0x20e] = {color = '#5555FFF', script_command = 'InitSafariTrain', parameters = {}},
	[0x20f] = {color = '#5555FFF', script_command = 'MoveSafariTrain', parameters = {'pos', 'pos', 'typ', 'typ'}},
	[0x210] = {color = '#5555FFF', script_command = 'CheckSafariTrain', parameters = {'pos', 'pos', 'wk', 'wk'}},
	[0x211] = {color = '#5555FFF', script_command = 'PlayerHeightValid', parameters = {'vld'}},
	[0x212] = {color = '#5555FFF', script_command = 'GetPokeSeikaku', parameters = {'wk', 'wk', 'ppi', 'ppi'}},
	[0x213] = {color = '#5555FFF', script_command = 'ChkPokeSeikakuAll', parameters = {'wk', 'wk', 'nat', 'nat'}},
	[0x214] = {color = '#5555FFF', script_command = 'UnderGroundTalkCount', parameters = {'wk', 'wk'}},
	[0x215] = {color = '#5555FFF', script_command = 'NaturalParkWalkCountClear', parameters = {}},
	[0x216] = {color = '#5555FFF', script_command = 'NaturalParkWalkCountGet', parameters = {'wk', 'wk'}},
	[0x217] = {color = '#5555FFF', script_command = 'NaturalParkAccessoryNoGet', parameters = {'wk', 'wk', 'pkm', 'pkm'}},
	[0x218] = {color = '#5555FFF', script_command = 'GetNewsPokeNo', parameters = {'wk', 'wk'}},
	[0x219] = {color = '#5555FFF', script_command = 'NewsCountSet', parameters = {'num', 'num'}},
	[0x21a] = {color = '#5555FFF', script_command = 'NewsCountChk', parameters = {'wk', 'wk'}},
	[0x21b] = {color = '#5555FFF', script_command = 'StartGenerate', parameters = {}},
	[0x21c] = {color = '#5555FFF', script_command = 'AddMovePoke', parameters = {'pkm'}},
	[0x21d] = {color = '#5555FFF', script_command = 'RandomGroup', parameters = {'swt', 'swt', 'gid', 'gid', 'wk', 'wk'}},
	[0x21e] = {color = '#5555FFF', script_command = 'OshieWazaCount', parameters = {'wk', 'wk', 'ppi', 'ppi'}},
	[0x21f] = {color = '#5555FFF', script_command = 'RemaindWazaCount', parameters = {'wk', 'wk', 'ppi', 'ppi'}},
	[0x220] = {color = '#5555FFF', script_command = 'OshieWazaListSetProc', parameters = {}},
	[0x221] = {color = '#5555FFF', script_command = 'RemaindWazaListSetProc', parameters = {'ppi', 'ppi'}},
	[0x222] = {color = '#5555FFF', script_command = 'OshieWazaListGetResult', parameters = {}},
	[0x223] = {color = '#5555FFF', script_command = 'RemaindWazaListGetResult', parameters = {'wk', 'wk'}},
	[0x224] = {color = '#5555FFF', script_command = 'NormalWazaListSetProc', parameters = {'ppi', 'ppi', 'mov', 'mov'}},
	[0x225] = {color = '#5555FFF', script_command = 'NormalWazaListGetResult', parameters = {'wk', 'wk'}},
	[0x226] = {color = '#5555FFF', script_command = 'FldTradeAlloc', parameters = {'trd'}},
	[0x227] = {color = '#5555FFF', script_command = 'FldTradeMonsno', parameters = {'wk', 'wk'}},
	[0x228] = {color = '#5555FFF', script_command = 'FldTradeChgMonsno', parameters = {'wk', 'wk'}},
	[0x229] = {color = '#5555FFF', script_command = 'FldTradeEvent', parameters = {'ppi', 'ppi'}},
	[0x22a] = {color = '#5555FFF', script_command = 'FldTradeDel', parameters = {}},
	[0x22b] = {color = '#5555FFF', script_command = 'ZukanTextVerUp', parameters = {}},
	[0x22c] = {color = '#5555FFF', script_command = 'ZukanSexVerUp', parameters = {}},
	[0x22d] = {color = '#5555FFF', script_command = 'ZenkokuZukanFlag', parameters = {'mod', 'wk', 'wk'}},
	[0x22e] = {color = '#5555FFF', script_command = 'ChkRibbonCount', parameters = {'wk', 'wk', 'ppi', 'ppi'}},
	[0x22f] = {color = '#5555FFF', script_command = 'ChkRibbonCountAll', parameters = {'wk', 'wk'}},
	[0x230] = {color = '#5555FFF', script_command = 'ChkRibbon', parameters = {'wk', 'wk', 'ppi', 'ppi', 'rib', 'rib'}},
	[0x231] = {color = '#5555FFF', script_command = 'SetRibbon', parameters = {'ppi', 'ppi', 'rib', 'rib'}},
	[0x232] = {color = '#5555FFF', script_command = 'RibbonName', parameters = {'idx', 'rib', 'rib'}},
	[0x233] = {color = '#5555FFF', script_command = 'ChkPrmExp', parameters = {'wk', 'wk', 'ppi', 'ppi'}},
	[0x234] = {color = '#5555FFF', script_command = 'ChkWeek', parameters = {'wk', 'wk'}},
	[0x235] = {color = '#5555FFF', script_command = 'BroadcastTV', parameters = {'swt', 'swt', '??', '??', '??', '??', '??', '??'}},
	[0x236] = {color = '#5555FFF', script_command = 'TVEntryWatchHideItem', parameters = {}},
	[0x237] = {color = '#5555FFF', script_command = 'TVInterview', parameters = {'swt', 'swt', 'id', 'id', '??', '??', '??', '??'}},
	[0x238] = {color = '#5555FFF', script_command = 'TVInterviewerCheck', parameters = {'id', 'id', 'wk', 'wk'}},
	[0x239] = {color = '#5555FFF', script_command = 'RegulationListCall', parameters = {}},
	[0x23a] = {color = '#5555FFF', script_command = 'AshiatoChk', parameters = {'wk1', 'wk1', 'wk2', 'wk2', 'ppi', 'ppi'}},
	[0x23b] = {color = '#5555FFF', script_command = 'PcRecoverAnm', parameters = {}},
	[0x23c] = {color = '#5555FFF', script_command = 'ElevatorAnm', parameters = {'dir', 'dir', 'loo', 'loo'}},
	[0x23d] = {color = '#5555FFF', script_command = 'CallShipDemo', parameters = {'sdi', 'pdi', 'map', 'map', 'xx', 'xx', 'yy', 'yy'}},
	[0x23e] = {color = '#5555FFF', script_command = 'MysteryPostMan', parameters = {'swt', 'swt', '??', '??', '??', '??'}},
	[0x23f] = {color = '#5555FFF', script_command = 'DebugPrintWork', parameters = {}},
	[0x240] = {color = '#5555FFF', script_command = 'DebugPrintFlag', parameters = {}},
	[0x241] = {color = '#5555FFF', script_command = 'DebugPrintWorkStationed', parameters = {'wk', 'wk'}},
	[0x242] = {color = '#5555FFF', script_command = 'DebugPrintFlagStationed', parameters = {'flg', 'flg'}},
	[0x243] = {color = '#5555FFF', script_command = 'PMSInputSingleProc', parameters = {'dmy', 'dmy', 'wk', 'wk', 'ans', 'ans'}},
	[0x244] = {color = '#5555FFF', script_command = 'PMSInputDoubleProc', parameters = {'dmy', 'dmy', 'wk', 'wk', 'an1', 'an1', 'an2', 'an2'}},
	[0x245] = {color = '#5555FFF', script_command = 'PMSBuf', parameters = {'buf', 'buf', 'wrd', 'wrd'}},
	[0x246] = {color = '#5555FFF', script_command = 'PMVersionGet', parameters = {'wk', 'wk'}}, 
	[0x247] = {color = '#5555FFF', script_command = 'FrontPokemon', parameters = {'wk', 'wk'}},
	[0x248] = {color = '#5555FFF', script_command = 'TemotiPokeType', parameters = {'wk1', 'wk1', 'wk2', 'wk2', 'tr', 'tr'}},
	[0x249] = {color = '#5555FFF', script_command = 'AikotobaKabegamiSet', parameters = {'wk', 'wk', 'ak1', 'ak1', 'ak2', 'ak2', 'ak3', 'ak3', 'ak4', 'ak4'}},
	[0x24a] = {color = '#5555FFF', script_command = 'GetUgHataNum', parameters = {'wk', 'wk'}},
	[0x24b] = {color = '#5555FFF', script_command = 'SetUpPasoAnime', parameters = {'ent'}},
	[0x24c] = {color = '#5555FFF', script_command = 'StartPasoOnAnime', parameters = {'ent'}},
	[0x24d] = {color = '#5555FFF', script_command = 'StartPasoOffAnime', parameters = {'ent'}},
	[0x24e] = {color = '#5555FFF', script_command = 'GetKujiAtariNum', parameters = {'wk', 'wk'}},
	[0x24f] = {color = '#5555FFF', script_command = 'KujiAtariChk', parameters = {'wk1', 'wk1', 'wk2', 'wk2', 'wk3', 'wk3', 'num', 'num'}},
	[0x250] = {color = '#5555FFF', script_command = 'KujiAtariInit', parameters = {}},
	[0x251] = {color = '#5555FFF', script_command = 'NickNamePC', parameters = {'idx', 'num', 'num'}},
	[0x252] = {color = '#5555FFF', script_command = 'PokeBoxCountEmptySpace', parameters = {'wk', 'wk'}},
	[0x253] = {color = '#5555FFF', script_command = 'PokeParkControl', parameters = {'mod', 'mod'}},
	[0x254] = {color = '#5555FFF', script_command = 'PokeParkDepositCount', parameters = {'wk', 'wk'}},
	[0x255] = {color = '#5555FFF', script_command = 'PokeParkTransMons', parameters = {}},
	[0x256] = {color = '#5555FFF', script_command = 'PokeParkGetScore', parameters = {'sco', 'sco', 'wk', 'wk'}},
	[0x257] = {color = '#5555FFF', script_command = 'AcceShopCall', parameters = {}},
	[0x258] = {color = '#5555FFF', script_command = 'ReportDrawProcSet', parameters = {}},
	[0x259] = {color = '#5555FFF', script_command = 'ReportDrawProcDel', parameters = {}},
	[0x25a] = {color = '#5555FFF', script_command = 'DendouBallAnm', parameters = {'num', 'num'}},
	[0x25b] = {color = '#5555FFF', script_command = 'InitFldLift', parameters = {}},
	[0x25c] = {color = '#5555FFF', script_command = 'MoveFldLift', parameters = {}},
	[0x25d] = {color = '#5555FFF', script_command = 'CheckFldLift', parameters = {'wk', 'wk'}},
	[0x25e] = {color = '#5555FFF', script_command = 'SetupRAHCyl', parameters = {}},
	[0x25f] = {color = '#5555FFF', script_command = 'StartRAHCyl', parameters = {}},
	[0x260] = {color = '#5555FFF', script_command = 'AddScore', parameters = {'sco', 'sco'}},
	[0x261] = {color = '#5555FFF', script_command = 'AcceName', parameters = {'idx', 'acc', 'acc'}},
	[0x262] = {color = '#5555FFF', script_command = 'PartyMonsNoCheck', parameters = {'pk', 'pk', 'wk', 'wk'}},
	[0x263] = {color = '#5555FFF', script_command = 'PartyDeokisisuFormChange', parameters = {'frm', 'frm'}},
	[0x264] = {color = '#5555FFF', script_command = 'CheckMinomuchiComp', parameters = {'wk', 'wk'}},
	[0x265] = {color = '#5555FFF', script_command = 'PoketchHookSet', parameters = {}},
	[0x266] = {color = '#5555FFF', script_command = 'PoketchHookReset', parameters = {}},
	[0x267] = {color = '#5555FFF', script_command = 'SlotMachine', parameters = {'id', 'id'}},
	[0x268] = {color = '#5555FFF', script_command = 'GetNowHour', parameters = {'wk', 'wk'}},
	[0x269] = {color = '#5555FFF', script_command = 'ObjShakeAnm', parameters = {'obj', 'obj', 'cnt', 'cnt', 'spd', 'spd', 'ofx', 'ofx', 'ofz', 'ofz'}},
	[0x26a] = {color = '#5555FFF', script_command = 'ObjBlinkAnm', parameters = {'obj', 'obj', 'cnt', 'cnt', 'time', 'time'}},
	[0x26b] = {color = '#5555FFF', script_command = '_D20R0106Legend_IsUnseal', parameters = {'ret', 'ret'}},
	[0x26c] = {color = '#5555FFF', script_command = 'DressingImcAcceCheck', parameters = {'wk', 'wk'}},
	[0x26d] = {color = '#5555FFF', script_command = 'TalkMsgUnknownFont', parameters = {'mid'}},
	[0x26e] = {color = '#5555FFF', script_command = 'AgbCartridgeVerGet', parameters = {'wk', 'wk'}},
	[0x26f] = {color = '#5555FFF', script_command = 'UnderGroundTalkCountClear', parameters = {}},
	[0x270] = {color = '#5555FFF', script_command = 'HideMapStateChange', parameters = {'map', 'map', 'flg'}},
	[0x271] = {color = '#5555FFF', script_command = 'NameInStone', parameters = {'wk', 'wk'}},
	[0x272] = {color = '#5555FFF', script_command = 'MonumantName', parameters = {'idx'}},
	[0x273] = {color = '#5555FFF', script_command = 'ImcBgNameSet', parameters = {'idx', 'bg', 'bg'}},
	[0x274] = {color = '#5555FFF', script_command = 'CompCoin', parameters = {'wk', 'wk', 'val', 'val', 'val', 'val'}},
	[0x275] = {color = '#5555FFF', script_command = 'SlotRentyanChk', parameters = {'wk', 'wk'}},
	[0x276] = {color = '#5555FFF', script_command = 'AddCoinChk', parameters = {'wk', 'wk', 'val', 'val'}},
	[0x277] = {color = '#5555FFF', script_command = 'LevelJijiiNo', parameters = {'wk', 'wk'}},
	[0x278] = {color = '#5555FFF', script_command = 'PokeLevelGet', parameters = {'wk', 'wk', 'ppi', 'ppi'}},
	[0x279] = {color = '#5555FFF', script_command = 'ImcAcceSubItem', parameters = {'acc', 'acc', 'num', 'num'}},
	[0x27a] = {color = '#5555FFF', script_command = 'c08r0801ScopeCameraSet', parameters = {}},
	[0x27b] = {color = '#5555FFF', script_command = 'LevelJijiiInit', parameters = {}},
	[0x27c] = {color = '#5555FFF', script_command = 'TVEntryParkInfo', parameters = {'swt', 'swt', '??', '??'}},
	[0x27d] = {color = '#5555FFF', script_command = 'NewNankaiWordSet', parameters = {'wk', 'wk', 'buf', 'buf'}},
	[0x27e] = {color = '#5555FFF', script_command = 'RegularCheck', parameters = {'wk', 'wk'}},
	[0x27f] = {color = '#5555FFF', script_command = 'NankaiWordCompleteCheck', parameters = {'wk', 'wk'}},
	[0x280] = {color = '#5555FFF', script_command = 'NumberNameEx', parameters = {'idx', 'num', 'num', 'typ', 'keta'}},
	[0x281] = {color = '#5555FFF', script_command = 'TemotiPokeContestStatusGet', parameters = {'ppi', 'ppi', 'con', 'con', 'wk', 'wk'}},
	[0x282] = {color = '#5555FFF', script_command = 'BirthDayCheck', parameters = {'wk', 'wk'}},
	[0x283] = {color = '#5555FFF', script_command = 'SndInitialVolSet', parameters = {'num', 'num', 'vol', 'vol'}},
	[0x284] = {color = '#5555FFF', script_command = 'AnoonSeeNum', parameters = {'wk', 'wk'}},
	[0x285] = {color = '#5555FFF', script_command = 'D17SystemMapSelect', parameters = {'pt', 'pt', 'tot', 'tot'}},
	[0x286] = {color = '#5555FFF', script_command = 'UnderGroundToolGiveCount', parameters = {'wk', 'wk'}},
	[0x287] = {color = '#5555FFF', script_command = 'UnderGroundKasekiDigCount', parameters = {'wk', 'wk'}},
	[0x288] = {color = '#5555FFF', script_command = 'UnderGroundTrapHitCount', parameters = {'wk', 'wk'}},
	[0x289] = {color = '#5555FFF', script_command = 'PofinAdd', parameters = {'wk', 'wk', 'prm', 'tst'}},
	[0x28a] = {color = '#5555FFF', script_command = 'PofinAddCheck', parameters = {'wk', 'wk'}},
	[0x28b] = {color = '#5555FFF', script_command = 'IsHaihuEventEnable', parameters = {'id', 'wk', 'wk'}},
	[0x28c] = {color = '#5555FFF', script_command = 'PokeWindowPutPP', parameters = {'val', 'val'}},
	[0x28d] = {color = '#5555FFF', script_command = 'PokeWindowAnm', parameters = {}},
	[0x28e] = {color = '#5555FFF', script_command = 'PokeWindowAnmWait', parameters = {'wk', 'wk'}},
	[0x28f] = {color = '#5555FFF', script_command = 'DendouNumGet', parameters = {'wk', 'wk'}},
	[0x290] = {color = '#5555FFF', script_command = 'SodateyaPokeListSetProc', parameters = {'pos', 'pos'}},
	[0x291] = {color = '#5555FFF', script_command = 'SodateyaPokeListGetResult', parameters = {'wk', 'wk', 'mod', 'mod'}},
	[0x292] = {color = '#5555FFF', script_command = 'GetRandomHit', parameters = {'per', 'wk', 'wk'}},
	[0x293] = {color = '#5555FFF', script_command = 'UnderGroundTalkCount2', parameters = {'wk', 'wk'}},
	[0x294] = {color = '#5555FFF', script_command = 'BtlPointWinWrite', parameters = {'xx', 'yy'}},
	[0x295] = {color = '#5555FFF', script_command = 'BtlPointWinDel', parameters = {}},
	[0x296] = {color = '#5555FFF', script_command = 'BtlPointWrite', parameters = {}},
	[0x297] = {color = '#5555FFF', script_command = 'CheckBtlPoint', parameters = {'wk', 'wk'}},
	[0x298] = {color = '#5555FFF', script_command = 'AddBtlPoint', parameters = {'val', 'val'}},
	[0x299] = {color = '#5555FFF', script_command = 'SubBtlPoint', parameters = {'val', 'val'}},
	[0x29a] = {color = '#5555FFF', script_command = 'CompBtlPoint', parameters = {'val', 'val', 'wk', 'wk'}},
	[0x29b] = {color = '#5555FFF', script_command = 'GetBtlPointGift', parameters = {'lst', 'lst', 'idx', 'idx', 'itm', 'itm', 'bp', 'bp'}},
	[0x29c] = {color = '#5555FFF', script_command = 'UnionViewGetTrainerTypeNo', parameters = {'ans', 'ans', 'wk', 'wk'}},
	[0x29d] = {color = '#5555FFF', script_command = 'BmpMenuMakeList16', parameters = {'mid', 'pos'}},
	[0x29e] = {color = '#5555FFF', script_command = 'HidenEffStart', parameters = {'eff', 'eff', 'wk', 'wk'}},
	[0x29f] = {color = '#5555FFF', script_command = 'Zishin', parameters = {'pat', 'pat'}},
	[0x2a0] = {color = '#5555FFF', script_command = 'TrainerMultiBattleSet', parameters = {'tr0', 'tr0', 'tr1', 'tr1'}},
	[0x2a1] = {color = '#5555FFF', script_command = 'ObjAnimePos', parameters = {'obj', 'obj', 'tx', 'tx', 'tz', 'tz'}},
	[0x2a2] = {color = '#5555FFF', script_command = 'UgBallCheck', parameters = {'itm', 'itm'}},
	[0x2a3] = {color = '#5555FFF', script_command = 'CheckMyGSID', parameters = {'wk', 'wk'}},
	[0x2a4] = {color = '#5555FFF', script_command = 'GetFriendDataNum', parameters = {'wk', 'wk'}},
	[0x2a5] = {color = '#5555FFF', script_command = 'NpcTradePokeListSetProc', parameters = {}},
	[0x2a6] = {color = '#5555FFF', script_command = 'GetCoinGift', parameters = {'idx', 'idx', 'itm', 'itm', 'bp', 'bp'}},
	[0x2a7] = {color = '#5555FFF', script_command = 'AusuItemCheck', parameters = {'itm', 'itm', 'wk', 'wk'}},
	[0x2a8] = {color = '#5555FFF', script_command = 'SubWkCoin', parameters = {'cwk', 'cwk'}},
	[0x2a9] = {color = '#5555FFF', script_command = 'CompWkCoin', parameters = {'wk', 'wk', 'cwk', 'cwk'}},
	[0x2aa] = {color = '#5555FFF', script_command = 'AikotobaOkurimonoChk', parameters = {'wk', 'wk', 'w0', 'w0', 'w1', 'w1', 'w2', 'w2', 'w3', 'w3'}},
	[0x2ab] = {color = '#5555FFF', script_command = 'CBSealKindNumGet', parameters = {'wk', 'wk'}},
	[0x2ac] = {color = '#5555FFF', script_command = 'WifiHusiginaokurimonoOpenFlagSet', parameters = {}},
	[0x2ad] = {color = '#5555FFF', script_command = 'MoveCodeGet', parameters = {'wk', 'wk', 'obj', 'obj'}},
	[0x2ae] = {color = '#5555FFF', script_command = 'BgmPlayCheck', parameters = {'mus', 'mus', 'wk', 'wk'}},
	[0x2af] = {color = '#5555FFF', script_command = 'UnionGetCardTalkNo', parameters = {'wk', 'wk'}},
	[0x2b0] = {color = '#5555FFF', script_command = 'WirelessIconEasy', parameters = {}},
	[0x2b1] = {color = '#5555FFF', script_command = 'WirelessIconEasyEnd', parameters = {}},
	[0x2b2] = {color = '#5555FFF', script_command = 'SaveFieldObj', parameters = {}},
	[0x2b3] = {color = '#5555FFF', script_command = 'SealName', parameters = {'idx', 'seal', 'seal'}},
	[0x2b4] = {color = '#5555FFF', script_command = 'TalkObjPauseAll', parameters = {}},
	[0x2b5] = {color = '#5555FFF', script_command = 'SetEscapeLocation', parameters = {'map', 'map', 'xx', 'xx', 'zz', 'zz'}},
	[0x2b6] = {color = '#5555FFF', script_command = 'FieldObjBitSetFellowHit', parameters = {'obj', 'obj', 'flg'}},
	[0x2b7] = {color = '#5555FFF', script_command = 'DameTamagoChkAll', parameters = {'wk', 'wk'}},
	[0x2b8] = {color = '#5555FFF', script_command = 'TVEntryWatchChangeName', parameters = {'ppi', 'ppi'}},
	[0x2b9] = {color = '#5555FFF', script_command = 'UnionBmpMenuStart', parameters = {}},
	[0x2ba] = {color = '#5555FFF', script_command = 'UnionBattleStartCheck', parameters = {'wk', 'wk'}},
	[0x2bb] = {color = '#5555FFF', script_command = 'CommDirectEndTiming', parameters = {}},
	[0x2bc] = {color = '#5555FFF', script_command = 'HaifuPokeRetryCheck', parameters = {'wk', 'wk'}},
	[0x2bd] = {color = '#5555FFF', script_command = 'SpWildBattleSet', parameters = {'sp', 'sp', 'lv', 'lv'}},
	[0x2be] = {color = '#5555FFF', script_command = 'GetCardRank', parameters = {'wk', 'wk'}},
	[0x2bf] = {color = '#5555FFF', script_command = 'BicycleReqNonBgm', parameters = {}},
	[0x2c0] = {color = '#5555FFF', script_command = 'TalkMsgSpAuto', parameters = {'msg'}},
	[0x2c1] = {color = '#5555FFF', script_command = 'ReportInfoWinOpen', parameters = {}},
	[0x2c2] = {color = '#5555FFF', script_command = 'ReportInfoWinClose', parameters = {}},
	[0x2c3] = {color = '#5555FFF', script_command = 'FieldScopeModeSet', parameters = {'mod'}},
	[0x2c6] = {color = '#5555FFF', script_command = 'SpinTradeUnion', parameters = {}},
	[0x2c7] = {color = '#5555FFF', script_command = 'CheckVersionGame', parameters = {}},
	[0x2ca] = {color = '#5555FFF', script_command = 'FloralClockAnimation', parameters = {}},
	[0x328] = {color = '#5555FFF', script_command = 'PortalEffect', parameters = {}},
	[0x347] = {color = '#5555FFF', script_command = 'DisplayFloor', parameters = {}},
	[0x402] = {color = '#5555FFF', script_command = 'ExitMarsh', parameters = {}},
	default = {color = '#222222'}
}

pokemon_names =  {"0x0", "Bulbasaur", "Ivysaur", "Venusaur", "Charmander", "Charmeleon", "Charizard",
			"Squirtle", "Wartortle", "Blastoise", "Caterpie", "Metapod", "Butterfree",
			"Weedle", "Kakuna", "Beedrill", "Pidgey", "Pidgeotto", "Pidgeot", "Rattata", "Raticate",
			"Spearow", "Fearow", "Ekans", "Arbok", "Pikachu", "Raichu", "Sandshrew", "Sandslash",
			"Nidoran F", "Nidorina", "Nidoqueen", "Nidoran M", "Nidorino", "Nidoking",
			"Clefairy", "Clefable", "Vulpix", "Ninetales", "Jigglypuff", "Wigglytuff",
			"Zubat", "Golbat", "Oddish", "Gloom", "Vileplume", "Paras", "Parasect", "Venonat", "Venomoth",
			"Diglett", "Dugtrio", "Meowth", "Persian", "Psyduck", "Golduck", "Mankey", "Primeape",
			"Growlithe", "Arcanine", "Poliwag", "Poliwhirl", "Poliwrath", "Abra", "Kadabra", "Alakazam",
			"Machop", "Machoke", "Machamp", "Bellsprout", "Weepinbell", "Victreebel", "Tentacool", "Tentacruel",
			"Geodude", "Graveler", "Golem", "Ponyta", "Rapidash", "Slowpoke", "Slowbro",
			"Magnemite", "Magneton", "Farfetch'd", "Doduo", "Dodrio", "Seel", "Dewgong", "Grimer", "Muk",
			"Shellder", "Cloyster", "Gastly", "Haunter", "Gengar", "Onix", "Drowzee", "Hypno",
			"Krabby", "Kingler", "Voltorb", "Electrode", "Exeggcute", "Exeggutor", "Cubone", "Marowak",
			"Hitmonlee", "Hitmonchan", "Lickitung", "Koffing", "Weezing", "Rhyhorn", "Rhydon", "Chansey",
			"Tangela", "Kangaskhan", "Horsea", "Seadra", "Goldeen", "Seaking", "Staryu", "Starmie",
			"Mr. Mime", "Scyther", "Jynx", "Electabuzz", "Magmar", "Pinsir", "Tauros", "Magikarp", "Gyarados",
			"Lapras", "Ditto", "Eevee", "Vaporeon", "Jolteon", "Flareon", "Porygon", "Omanyte", "Omastar",
			"Kabuto", "Kabutops", "Aerodactyl", "Snorlax", "Articuno", "Zapdos", "Moltres",
			"Dratini", "Dragonair", "Dragonite", "Mewtwo", "Mew",
			"Chikorita", "Bayleef", "Meganium", "Cyndaquil", "Quilava", "Typhlosion",
			"Totodile", "Croconaw", "Feraligatr", "Sentret", "Furret", "Hoothoot", "Noctowl",
			"Ledyba", "Ledian", "Spinarak", "Ariados", "Crobat", "Chinchou", "Lanturn", "Pichu", "Cleffa",
			"Igglybuff", "Togepi", "Togetic", "Natu", "Xatu", "Mareep", "Flaaffy", "Ampharos", "Bellossom",
			"Marill", "Azumarill", "Sudowoodo", "Politoed", "Hoppip", "Skiploom", "Jumpluff", "Aipom",
			"Sunkern", "Sunflora", "Yanma", "Wooper", "Quagsire", "Espeon", "Umbreon", "Murkrow", "Slowking",
			"Misdreavus", "Unown", "Wobbuffet", "Girafarig", "Pineco", "Forretress", "Dunsparce", "Gligar",
			"Steelix", "Snubbull", "Granbull", "Qwilfish", "Scizor", "Shuckle", "Heracross", "Sneasel",
			"Teddiursa", "Ursaring", "Slugma", "Magcargo", "Swinub", "Piloswine", "Corsola", "Remoraid", "Octillery",
			"Delibird", "Mantine", "Skarmory", "Houndour", "Houndoom", "Kingdra", "Phanpy", "Donphan",
			"Porygon2", "Stantler", "Smeargle", "Tyrogue", "Hitmontop", "Smoochum", "Elekid", "Magby", "Miltank",
			"Blissey", "Raikou", "Entei", "Suicune", "Larvitar", "Pupitar", "Tyranitar", "Lugia", "Ho-Oh", "Celebi",
			"Treecko", "Grovyle", "Sceptile", "Torchic", "Combusken", "Blaziken", "Mudkip", "Marshtomp",
			"Swampert", "Poochyena", "Mightyena", "Zigzagoon", "Linoone", "Wurmple", "Silcoon", "Beautifly",
			"Cascoon", "Dustox", "Lotad", "Lombre", "Ludicolo", "Seedot", "Nuzleaf", "Shiftry",
			"Taillow", "Swellow", "Wingull", "Pelipper", "Ralts", "Kirlia", "Gardevoir", "Surskit",
			"Masquerain", "Shroomish", "Breloom", "Slakoth", "Vigoroth", "Slaking", "Nincada", "Ninjask",
			"Shedinja", "Whismur", "Loudred", "Exploud", "Makuhita", "Hariyama", "Azurill", "Nosepass",
			"Skitty", "Delcatty", "Sableye", "Mawile", "Aron", "Lairon", "Aggron", "Meditite", "Medicham",
			"Electrike", "Manectric", "Plusle", "Minun", "Volbeat", "Illumise", "Roselia", "Gulpin",
			"Swalot", "Carvanha", "Sharpedo", "Wailmer", "Wailord", "Numel", "Camerupt", "Torkoal",
			"Spoink", "Grumpig", "Spinda", "Trapinch", "Vibrava", "Flygon", "Cacnea", "Cacturne", "Swablu",
			"Altaria", "Zangoose", "Seviper", "Lunatone", "Solrock", "Barboach", "Whiscash", "Corphish",
			"Crawdaunt", "Baltoy", "Claydol", "Lileep", "Cradily", "Anorith", "Armaldo", "Feebas",
			"Milotic", "Castform", "Kecleon", "Shuppet", "Banette", "Duskull", "Dusclops", "Tropius",
			"Chimecho", "Absol", "Wynaut", "Snorunt", "Glalie", "Spheal", "Sealeo", "Walrein", "Clamperl",
			"Huntail", "Gorebyss", "Relicanth", "Luvdisc", "Bagon", "Shelgon", "Salamence", "Beldum",
			"Metang", "Metagross", "Regirock", "Regice", "Registeel", "Latias", "Latios", "Kyogre",
			"Groudon", "Rayquaza", "Jirachi", "Deoxys",
			"Turtwig", "Grotle", "Torterra", "Chimchar", "Monferno", "Infernape", "Piplup", "Prinplup",
			"Empoleon", "Starly", "Staravia", "Staraptor", "Bidoof", "Bibarel", "Kricketot", "Kricketune",
			"Shinx", "Luxio", "Luxray", "Budew", "Roserade", "Cranidos", "Rampardos", "Shieldon", "Bastiodon",
			"Burmy", "Wormadam", "Mothim", "Combee", "Vespiquen", "Pachirisu", "Buizel", "Floatzel", "Cherubi",
			"Cherrim", "Shellos", "Gastrodon", "Ambipom", "Drifloon", "Drifblim", "Buneary", "Lopunny",
			"Mismagius", "Honchkrow", "Glameow", "Purugly", "Chingling", "Stunky", "Skuntank", "Bronzor",
			"Bronzong", "Bonsly", "Mime Jr.", "Happiny", "Chatot", "Spiritomb", "Gible", "Gabite", "Garchomp",
			"Munchlax", "Riolu", "Lucario", "Hippopotas", "Hippowdon", "Skorupi", "Drapion", "Croagunk",
			"Toxicroak", "Carnivine", "Finneon", "Lumineon", "Mantyke", "Snover", "Abomasnow", "Weavile",
			"Magnezone", "Lickilicky", "Rhyperior", "Tangrowth", "Electivire", "Magmortar", "Togekiss",
			"Yanmega", "Leafeon", "Glaceon", "Gliscor", "Mamoswine", "Porygon-Z", "Gallade", "Probopass",
			"Dusknoir", "Froslass", "Rotom", "Uxie", "Mesprit", "Azelf", "Dialga", "Palkia", "Heatran",
			"Regigigas", "Giratina", "Cresselia", "Phione", "Manaphy", "Darkrai", "Shaymin", "Arceus",
}

nature_list = {"Hardy","Lonely","Brave","Adamant","Naughty",
			"Bold","Docile","Relaxed","Impish","Lax",
			"Timid","Hasty","Serious","Jolly","Naive",
			"Modest","Mild","Quiet","Bashful","Rash",
			"Calm","Gentle","Sassy","Careful","Quirky"
}

sprite_id_dp = {
	[0x00] = "LukasRun",
	[0x01] = "MaleKid",
	[0x02] = "FemaleKid",
	[0x03] = "Nerd",
	[0x04] = "Youngster",
	[0x05] = "Bug Catcher",
	[0x06] = "Fem Ace Trainer",
	[0x07] = "Fem Jogger",
	[0x08] = "Fem ?",
	[0x09] = "Male ?",
	[0x0A] = "Male ?",
	[0x0B] = "Male Ace trainer",
	[0x0C] = "Fem ?",
	[0x0D] = "Fem ?",
	[0x0E] = "Fem Ace Trainer",
	[0x0F] = "Balding Old Man",
	[0x10] = "Woman",
	[0x11] = "Daycare man",
	[0x12] = "Daycare Woman",
	[0x13] = "Collector",
	[0x14] = "Hiker",
	[0x15] = "LukasBike",
	[0x16] = "Fem Reporter",
	[0x17] = "Male Reporter",
	[0x18] = "Woman",
	[0x19] = "Woman",
	[0x1A] = "Nurse Joy",
	[0x1B] = "Nurse",
	[0x1C] = "Nurse",
	[0x1D] = "Male Scientist",
	[0x1E] = "Fem Scientist",
	[0x1F] = "Rough guy",
	[0x20] = "Male Skier",
	[0x21] = "Fem Skier",
	[0x22] = "Police",
	[0x23] = "Contest Woman",
	[0x24] = "Rich Man",
	[0x25] = "Rich Woman",
	[0x26] = "Male Cyclist",
	[0x27] = "Fem Cyclist",
	[0x28] = "UG worker",
	[0x29] = "Farmer Parent",
	[0x2A] = "Farmer Child",
	[0x2B] = "Clown",
	[0x2C] = "Artist",
	[0x2D] = "Male Jogger",
	[0x2E] = "Male Swimmer",
	[0x2F] = "Fem Swimster",
	[0x30] = "Fem Beach Kid",
	[0x31] = "Male Beach Kid",
	[0x32] = "Explorer",
	[0x33] = "Red Belt",
	[0x34] = "Camper Girl",
	[0x35] = "Camper Girl",
	[0x36] = "Fisherman",
	[0x37] = "Woman", -- umbrella
	[0x38] = "Sailor",
	[0x39] = "MissingNo",
	[0x3A] = "MissingNo",
	[0x3B] = "Rich Boy",
	[0x3C] = "Waitress",
	[0x3D] = "MissingNo",
	[0x3E] = "Rich Boy",
	[0x3F] = "Rich Girl",
	[0x40] = "Snow Guy",
	[0x41] = "Snow Girl",
	[0x42] = "MissingNo",
	[0x43] = "MissingNo",
	[0x44] = "Snow Woman",
	[0x45] = "Snow Woman",
	[0x46] = "Psychic",
	[0x47] = "Poke Kid",
	[0x48] = "Cleffa",
	[0x49] = "Jigglypuf",
	[0x4A] = "Psyduck",
	[0x4B] = "MissingNo",
	[0x4C] = "MissingNo",
	[0x4D] = "MissingNo",
	[0x4E] = "Torchic",
	[0x4F] = "Skitty",
	[0x50] = "MissingNo",
	[0x51] = "Baby Stroll",
	[0x52] = "Poketch Guy",
	[0x53] = "Woman",
	[0x54] = "Strength Boulder",
	[0x55] = "Rock Smash Rock",
	[0x56] = "Cut Sapling",
	[0x57] = "Pokéball",
	[0x58] = "Woman",
	[0x59] = "Woman",
	[0x5A] = "Woman",
	[0x5B] = "Invalid",
	[0x5C] = "Invalid",
	[0x5D] = "Invalid",
	[0x5E] = "Invalid",
	[0x5F] = "Invalid",
	[0x60] = "Lukas",
	[0x61] = "Dawn",
	[0x63]  = "Proff. Rowan",
	[0x64] = "Invalid",
	[0x65] = "Invalid",
	[0x66] = "Invalid",
	[0x67] = "Invalid",
	[0x68] = "Invalid",
	[0x69] = "Invalid",
	[0x6A] = "Invalid",
	[0x6B] = "Invalid",
	[0x6C] = "Invalid",
	[0x6D] = "Invalid",
	[0x6E] = "Invalid",
	[0x6F] = "Invalid",
	[0x70] = "Invalid",
	[0x71] = "Invalid",
	[0x72] = "Invalid",
	[0x73] = "Invalid",
	[0x74] = "Invalid",
	[0x75] = "Invalid",
	[0x76] = "Invalid",
	[0x77] = "Invalid",
	[0x78] = "Cyrus",
	[0x79] = "Mars",
	[0x7A] = "Saturn",
	[0x7B] = "Jupiter",
	[0x7C] = "MaleGalactic",
	[0x7D] = "FemaleGalactic",
	[0x7E] = "Roark",
	[0x7F] = "Gardenia",
	[0x80] = "Crasher Wake",
	[0x81] = "Maylene",
	[0x82] = "Fantina",
	[0x83] = "Candice",
	[0x84] = "Byron",
	[0x85] = "Volkner",
	[0x86] = "Aaron",
	[0x87] = "Bertha",
	[0x88] = "Flint",
	[0x89] = "Lucian",
	[0x8A] = "Cynthia",
	[0x8B] = "UnusedNPC",
	[0x8C] = "Mother",
	[0x8D] = "Cherryl",
	[0x8E] = "Riley",
	[0x8F] = "Marley",
	[0x90] = "Buck",
	[0x91] = "Mira",
	[0x92] = "MissingNo.",
	[0x93] = "MissingNo.",
	[0x94] = "Rival",
	[0x95] = "UnusedNPC",
	[0x96] = "UnusedNPC",
	[0x97] = "Uxie",
	[0x98] = "Mesprit",
	[0x99] = "Azelf",
	[0x9A] = "Dialga",
	[0x9B] = "Palkia",
	[0x9C] = "Arceus",
	[0x9D] = "Darkrai",
	[0x9E] = "Shaymin",
	[0x9F] = "Cresselia",
	[0xA0] = "Giratina",
	[0xA1] = "Heatran",
	[0xA2] = "MissingNo.",
	[0xA3] = "Reception",
	[0xA4] = "Old Man",
	[0xA5] = "Old Woman",
	[0xA6] = "Proff Oak",
	[0xA7] = "Hoenn girl", -- forgot name lol
	[0xA8] = "Nerd",
	[0xA9] = "Palmer",
	[0xAA] = "UnusedNPC",
	[0xAB] = "UnusedNPC",
	[0xAC] = "UnusedNPC",
	[0xAD] = "Starly",
	[0xAE] = "BriefCase",
	[0xAF] = "Waitress",
	[0xB0] = "LukasFlyAnim",
	[0xB1] = "DawnFlyAnim",
	[0xB2] = "LukasSurfAnim",
	[0xB3] = "DawnSurfAnim",
	[0xB4] = "LukasSprayAnim",
	[0xB5] = "DawnSprayAnim",
	[0xB6] = "Vent",
	[0xB7] = "Invalid",
	[0xB8] = "Regigigas",
	[0xB9] = "Drifloon",
	[0xBA] = "LukasContest",
	[0xBB] = "DawnContest",
	[0xBC] = "LukasFishAnim",
	[0xBD] = "DawnFishAnim",
	[0xBE] = "MossRock",
	[0xBF] = "IceRock",
	[0xC0] = "MetalCoat?", -- no clue
	[0xC1] = "DeliveryMan", -- mystery gift/wifi events
	[0xC2] = "NintendoPlayer",
	[0xC3] = "Magikarp",
	[0xC4] = "LukasPoketchAnim",
	[0xC5] = "DawnPoketchAnim",
	[0xC6] = "LukasClearPoketchAnim",
	[0xC7] = "DawnClearPoketchAnim",
	[0xC8] = "LukasObtainItemAnim",
	[0xC9] = "DawnObtainItemAnim",
	[0xCA] = "Elevator",
	[0xCB] = "LakeTrioWall",
	[0xCC] = "Pachirisu",
	[0xCD] = "Shroomish",
	[0xCE] = "Buneary",
	[0xCF] = "Happiny",
	[0xD0] = "Machop",
}

texture_data =	{
	{map_ids = {0, 1}, offsets = {0xae2b8,0xafce4,0xb1710,0xb313c}},
	{map_ids = {2}, offsets = {0xb97c8,0xbb1f4,0xbcc20,0xbe64c}},
	{map_ids = {332, 333, 410, 466}, offsets = {0xa1ce8,0xa3714,0xa5140,0xa6b6c}},
	{map_ids = {3, 206, 334, 342, 343, 344, 345, 391, 392, 411, 418, 467}, offsets = {0xaeb10,0xb053c,0xb1f68,0xb3994}},
	{map_ids = {45, 350, 353}, offsets = {0x96f00,0x9892c,0x9a358,0x9bd84}},
	{map_ids = {65, 200, 202, 204, 256, 346, 347, 349, 365, 426}, offsets = {0xa0c28,0xa2654,0xa4080,0xa5aac}},
	{map_ids = {86, 252, 354}, offsets = {0x927dc,0x94208,0x95c34,0x97660}},
	{map_ids = {224, 356, 362, 363, 366, 382, 433, 442}, offsets = {0x920dc,0x93b08,0x95534,0x96f60}},
	{map_ids = {132, 276, 277}, offsets = {0x951b8,0x96be4,0x98610,0x9a03c}},
	{map_ids = {120, 222, 367, 371, 287}, offsets = {0x8eedc,0x90908,0x92334,0x93d60}},
	{map_ids = {150, 468, 172, 274, 399, 472}, offsets = {0x9310c,0x94b38,0x96564,0x97f90}},
	{map_ids = {165, 210, 211, 243, 340, 383, 385, 317, 318}, offsets = {0x8ecf0,0x9071c,0x92148,0x93b74}},
	{map_ids = {33, 320, 388, 260, 288}, offsets = {0x8f218,0x90c44,0x92670,0x9409c}},
	{map_ids = {400, 401, 402, 403, 404, 405, 450, 469, 262}, offsets = {0x849e8,0x86414,0x87e40,0x8986c}},
	{map_ids = {266, 336, 341, 373, 380, 395}, offsets = {0x8e904,0x90330,0x91d5c,0x93788}},
	{map_ids = {188, 406, 407, 408, 409, 457, 470, 471, 473}, offsets = {0x8cf84,0x8e9b0,0x903dc,0x91e08}},
	{map_ids = {41, 42, 43, 44, 58, 60, 64, 81, 82, 83, 84, 106, 115, 127, 128, 129, 130, 131, 145, 146, 147, 148, 158, 159, 160, 161, 162, 163, 170, 171, 194, 195, 196, 257, 275, 348, 355, 364, 372, 375, 384, 386, 387, 394, 396, 397, 412, 413, 414, 415, 416, 417, 422, 423, 424, 425, 431, 432, 438, 439, 440, 441, 445, 446, 447, 448, 454, 455, 456, 464, 465, 491, 498, 499, 500, 502, 503, 514, 5, 23, 31, 32, 85, 335}, offsets = {0x9ab8c,0x9c5b8,0x9dfe4,0x9fa10}},
	{map_ids = {6, 7, 18, 36, 37, 48, 49, 69, 70, 101, 102, 105, 114, 123, 124, 134, 135, 142, 151, 152, 168, 169, 173, 174, 175, 189, 190, 327, 420, 421, 428, 429, 435, 436, 443, 444, 452, 453, 459, 460, 463, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 495, 496, 516}, offsets = {0x8cf34,0x8e960,0x9038c,0x91db8}},
	{map_ids = {4, 34, 46, 66, 71, 87, 121, 136, 137, 138, 139, 140, 141, 144, 153, 166, 191, 419, 427, 430, 434, 437, 451, 458}, offsets = {0x943f0,0x95e1c,0x97848,0x99274}},
	{map_ids = {122}, offsets = {0x776ac,0x790d8,0x7ab04,0x7c530}},
	{map_ids = {35}, offsets = {0x7c9a8,0x7e3d4,0x7fe00,0x8182c}},
	{map_ids = {47}, offsets = {0x7496c,0x76398,0x77dc4,0x797f0}},
	{map_ids = {67, 68}, offsets = {0x74b64,0x76590,0x77fbc,0x799e8}},
	{map_ids = {88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100}, offsets = {0x766f0,0x7811c,0x79b48,0x7b574}},
	{map_ids = {167}, offsets = {0x75754,0x77180,0x78bac,0x7a5d8}},
	{map_ids = {133}, offsets = {0x777ac,0x791d8,0x7ac04,0x7c630}},
	{map_ids = {154, 155, 156}, offsets = {0x86514,0x87f40,0x8996c,0x8b398}},
	{map_ids = {8, 9, 10, 19, 20, 21, 22, 24, 25, 26, 27, 29, 30, 38, 39, 40, 50, 51, 52, 53, 54, 55, 56, 57, 59, 61, 62, 63, 72, 73, 74, 75, 76, 77, 78, 79, 80, 103, 104, 107, 108, 109, 110, 111, 112, 113, 143, 149, 192, 193, 201, 351, 374, 381, 389, 390, 398, 501, 517, 304, 352}, offsets = {0xa2480,0xa3eac,0xa58d8,0xa7304}},
	{map_ids = {117, 118, 558}, offsets = {0xaace0,0xac70c,0xae138,0xafb64}},
	{map_ids = {324, 325, 326, 328, 329, 330, 331, 493}, offsets = {0xab830,0xad25c,0xaec88,0xb06b4}},
	{map_ids = {11, 12, 13, 14, 15, 16, 17}, offsets = {0xacdbc,0xae7e8,0xb0214,0xb1c40}},
	{map_ids = {119, 337, 338, 339, 368, 369, 370, 376, 377, 378, 379, 492}, offsets = {0xaadb4,0xac7e0,0xae20c,0xafc38}},
	{map_ids = {176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187}, offsets = {0x7f81c,0x81248,0x82c74,0x846a0}},
	{map_ids = {116}, offsets = {0xaae54,0xac880,0xae2ac,0xafcd8}},
	{map_ids = {157, 461, 462}, offsets = {0xab534,0xacf60,0xae98c,0xb03b8}},
	{map_ids = {125, 126, 164, 393}, offsets = {0xacdc8,0xae7f4,0xb0220,0xb1c4c}},
	{map_ids = {28}, offsets = {0x7bb54,0x7d580,0x7efac,0x809d8}},
	{map_ids = {323}, offsets = {0xaa53c,0xabf68,0xad994,0xaf3c0}},
	{map_ids = {357, 358, 359, 360, 361}, offsets = {0xab32c,0xacd58,0xae784,0xb01b0}},
	{map_ids = {207, 208, 209, 212, 213, 214, 215, 216, 217, 218, 219, 244, 245, 246, 247, 248, 249, 254, 258, 259, 284, 285, 286, 313, 316, 319, 512, 513}, offsets = {0x76204,0x77c30,0x7965c,0x7b088}},
	{map_ids = {203, 261, 321, 255}, offsets = {0x531d8,0x54c04,0x55490,0x7c6ac}},
	{map_ids = {198, 199, 289, 290, 291, 292, 293, 294, 197}, offsets = {0x7a550,0x7bf7c,0x7d9a8,0x7f3d4}},
	{map_ids = {225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 268, 269, 270, 271, 272, 273, 449, 515, 518, 519, 520, 521, 522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557}, offsets = {0x7b8a8,0x7d2d4,0x7ed00,0x8072c}},
	{map_ids = {263, 264, 265}, offsets = {0x742b4,0x75ce0,0x7770c,0x79138}},
	{map_ids = {305, 306, 307, 308, 309, 310}, offsets = {0xb563c,0xb7068,0xb8a94,0xba4c0}},
	{map_ids = {253}, offsets = {0x7ea04,0x80430,0x81e5c,0x83888}},
	{map_ids = {220, 221, 510, 511}, offsets = {0x83cd4,0x85700,0x8712c,0x88b58}},
	{map_ids = {251}, offsets = {0x51920,0x5334c,0x54d78,0x7b098}},
	{map_ids = {267, 311, 312, 314, 315}, offsets = {0x51e40,0x5386c,0x55298,0x55b24}},
	{map_ids = {223, 504, 505, 506, 507, 508, 509}, offsets = {0x55124,0x56b50,0x7c8f8,0x7e324}},
	{map_ids = {322}, offsets = {0x7f498,0x80ec4,0x828f0,0x8431c}},
	{map_ids = {278, 279, 280, 281, 282, 283}, offsets = {0x798b8,0x7b2e4,0x7cd10,0x7e73c}},
	{map_ids = {295, 296, 297, 298, 299, 300, 301, 302, 303}, offsets = {0xaf5d0,0xb0ffc,0xb2a28,0xb4454}},
	{map_ids = {205}, offsets = {0x78c48,0x7a674,0x7c0a0,0x7dacc}},
	{map_ids = {494, 497}, offsets = {0xb53a4,0xb6dd0,0xb87fc,0xba228}}
}

--missing berries
--signs

data_tables = {
	--1 DP and PD demo
	{	
		item_struct_offs = 0x838,
		step_counter_offs = 0x1384,
		menu_state_offs = 0x131F,

		-- start of structure offsets/structure data
		player_live_struct_offs = 0x1440,
		signature_offs = 0x5B15,
		signature_size = 0x600,
	
		mapdata_and_menu_struct_offs = 0x22964,
		chunk_calculation_ptr = 0x229F0,
		matrix_struct_offs = 0x22A84,
		matrix_size = 30,

		general_npc_struct_offs = 0x248C8,
		player_npc_struct_offs = 0x24A14,

		object_struct_offs = 0x23C80,
		object_struct_size = 0x14,
		warp_struct_size = 0xC,
		trigger_struct_size = 0x10,

		npc_struct_offs =  0x24B5C,
		npc_struct_size = 0x128,

		memory_shift = {
			UG=0x8104,
			BT=0x8104,
			OW=0x0
		},
		
		memory_state_check_offs = 0x22A00, -- 0x22A00,0x22A04,0x22A20
		opcode_pointer =  0x29500, -- affected by bt

		memory_state_check_val = 0x2C9EC,
	
		menu_data = 0x29434,
		current_pocket_index_offs = 0x2977C,
		hall_of_fame_struct_offs = 0x2C298,
		hall_of_fame_entry_size = 0x3C,


		ug_revealing_circle_struct_offs = 0x115150,
		ug_trap_struct_offs = 0x12B5B0,
		ug_trap_struct_size = 0x6,
		

		ug_cur_gem_ptr = 0x12DBC0,
		ug_gem_struct_offs = 0x12D5E0,
		ug_gem_struct_size = 0x6,
		ug_gem_count = 0xFA,

		ug_sphere_struct_offs = 0x12CEDC,
		ug_sphere_struct_size = 0x8,
		ug_max_sphere_count = 0xFF, -- I have no idea how many spheres there are, I'll just assume 255 for now

		ug_excavation_minigame_offs = 0x12DD36,
		ug_excavation_minigame_tile_count = 0x81, -- 13 col * 9 row of 1 byte each
		ug_excavation_minigame_visual_offs = 0x534C4,

		

		-- static addresses
		bag_hovering_data_ptr = 0x2106FAC,
		menu_addr = 0x21C45BC, -- also check for underground minigame

		ug_trap_count_addr= 0x222CAD7,

		ug_init_addr = 0x2250E86,
		ug_init_val = 0x1F,

		game_state = 0x21C45B8, -- 4 = wifiroom, 5 = underground, 6 = overworld, 0x10 = battle
		graphical_x = 0x21CEF5A,
		battle_check = 0x221885E
	},

	--2 DP KOREAN version
	{

	},
	--3 Pl
	{

	},
	--4 HGSS
	{
		item_struct_offs = 0x0,
		step_counter_offs = 0x0,

		-- start of structure offsets/structure data
		player_live_struct_offs = 0x1238, --
		signature_offs = 0x0,
		signature_size = 0x600,
	
		mapdata_and_menu_struct_offs = 0x22964,
		chunk_calculation_ptr = 0x24014,
		matrix_struct_offs = 0x24110,
		matrix_size = 30,

		general_npc_struct_offs = 0x25C14, --
		player_npc_struct_offs = 0x25D60, --

		object_struct_offs = 0x25114, --
		object_struct_size = 0x14,
		warp_struct_size = 0xC,
		trigger_struct_size = 0x10,

		npc_struct_offs = 0x25FD8,
		npc_struct_size = 0x12C,

		memory_shift = {
			UG=0x8104,
			BT=0x8104,
			OW=0x0
		},
		
		memory_state_check_offs = 0x22A00, -- 0x22A00,0x22A04,0x22A20
		opcode_pointer =  0x29500, -- affected by bt

		memory_state_check_val = 0x2C9EC,
	
		menu_data = 0x29434,
		current_pocket_index_offs = 0x2977C,
		hall_of_fame_struct_offs = 0x2C298,
		hall_of_fame_entry_size = 0x3C,


		ug_revealing_circle_struct_offs = 0x115150,
		ug_trap_struct_offs = 0x12B5B0,
		ug_trap_struct_size = 0x6,
		

		ug_cur_gem_ptr = 0x12DBC0,
		ug_gem_struct_offs = 0x12D5E0,
		ug_gem_struct_size = 0x6,
		ug_gem_count = 0xFA,

		ug_excavation_minigame_offs = 0x12DD36,
		ug_excavation_minigame_tile_count = 0x81, -- 13 col * 9 row of 1 byte each
		ug_excavation_minigame_visual_offs = 0x534C4,

		-- static addresses
		bag_hovering_data_ptr = 0x2106FAC,
		menu_addr = 0x21C45BC, -- also check for underground minigame

		ug_trap_count_addr= 0x222CAD7,

		ug_init_addr = 0x2250E86,
		ug_init_val = 0x1F,

		game_state = 0x21C45B8, -- 4 = wifiroom, 5 = underground, 6 = overworld, 0x10 = battle
		battle_check = 0x221885E
	},
}

demo = false
hgss = false

game_specific_data = {
	Y = {
		game_name = "DP Demo",
		demo = true,
		language_specific_data = {
			E = {base_addr=0x02106BAC,data_table_index=1,collision_check_addr=0x2056C06,catch_chance_addr=0x223C1F4} -- US/EU ENGLISH
		}
	},
	A = {
		game_name  = "DP",
		language_specific_data = {
			D = {base_addr=0x02107100,data_table_index=1,collision_check_addr=0x2056C76,catch_chance_addr=nil}, -- GERMAN
			E = {base_addr=0x02106FC0,data_table_index=1,collision_check_addr=0x2056C06,catch_chance_addr=0x223C1F4}, -- US/EU ENGLISH
			F = {base_addr=0x02107140,data_table_index=1,collision_check_addr=0x2056C76,catch_chance_addr=nil}, -- FRENCH
			I = {base_addr=0x021070A0,data_table_index=1,collision_check_addr=0x2056C76,catch_chance_addr=nil}, -- ITALIAN
			J = {base_addr=0x02108818,data_table_index=1,collision_check_addr=0x20593E0,catch_chance_addr=nil}, -- JAPANESE
			K = {base_addr=0x021045C0,data_table_index=2,collision_check_addr=0x20570DE,catch_chance_addr=nil}, -- KOREAN
			S = {base_addr=0x02107160,data_table_index=1,collision_check_addr=0x2056C76,catch_chance_addr=nil} -- SPANISH
		}
	},
	C = {
		game_name = "Pl",
		language_specific_data = {
			D = {base_addr=0x02101EE0,data_table_index=3,collision_check_addr=0x2060CC4,catch_chance_addr=nil}, -- GERMAN
			E = {base_addr=0x02101D40,data_table_index=3,collision_check_addr=0x2060C20,catch_chance_addr=0x224A75C}, -- US/EU ENGLISH
			F = {base_addr=0x02101F20,data_table_index=3,collision_check_addr=0x2060CC4,catch_chance_addr=nil}, -- FRENCH
			I = {base_addr=0x02101EA0,data_table_index=3,collision_check_addr=0x2060CC4,catch_chance_addr=nil}, -- ITALIAN
			J = {base_addr=0x02101140,data_table_index=3,collision_check_addr=0x20604E8,catch_chance_addr=nil}, -- JAPANESE
			K = {base_addr=0x02102C40,data_table_index=3,collision_check_addr=nil,catch_chance_addr=nil}, -- KOREAN
			S = {base_addr=0x02101F40,data_table_index=3,collision_check_addr=0x2060CC4,catch_chance_addr=nil} -- SPANISH
		}
	},
	I = {
		game_name = "HGSS",
		hgss = true,
		language_specific_data = {
			D = {base_addr = 0x02111860,data_table_index=4,collision_check_addr=0x205DB46,catch_chance_addr=nil}, -- GERMAN
			E = {base_addr = 0x02111880,data_table_index=4,collision_check_addr=0x205DAA2,catch_chance_addr=nil}, -- US/EU ENGLISH
			F = {base_addr = 0x021118A0,data_table_index=4,collision_check_addr=0x205DB46,catch_chance_addr=nil}, -- FRENCH
			I = {base_addr = 0x02111820,data_table_index=4,collision_check_addr=0x205DB46,catch_chance_addr=nil}, -- ITALIAN
			J = {base_addr = 0x02110DC0,data_table_index=4,collision_check_addr=0x205D36A,catch_chance_addr=nil}, -- JAPANESE
			K = {base_addr = 0x02112280,data_table_index=4,collision_check_addr=nil,catch_chance_addr=nil}, -- KOREAN
			S = {base_addr = 0x021118C0,data_table_index=4,collision_check_addr=0x205DB46,catch_chance_addr=nil} -- SPANISH
		}
	}

}

ver = readdword(0x023FFE0C)
if ver == 0 then
	ver = readdword(0x027FFE0C)
end

id = band(ver, 0xFF)
game_id = string.char(id)

lang_ascii = band(rshift(ver, 24), 0xFF)
lang = string.char(lang_ascii)

game_data = game_specific_data[game_id]
lang_data = game_data["language_specific_data"][lang]

data_table = data_tables[lang_data["data_table_index"]]


-- base struct
base_struct = {
	player_name=0x278,
	money = 0x28C,
}

-- live player struct
start_live_struct = data_table["player_live_struct_offs"]

live_struct = {
	step_counter = data_table["step_counter_offs"],
	
	map_id_32 = start_live_struct + 0xC,
	unknown_32 = start_live_struct + 0x10,
	x_pos_32_r = start_live_struct + 0x14,
	z_pos_32_r = start_live_struct + 0x18,
	y_pos_32_r = start_live_struct + 0x1C,

	map_id_last_warp_32 = start_live_struct + 0x20,
	unknown_last_warp_32 = start_live_struct + 0x24,
	x_pos_last_warp_32 = start_live_struct + 0x28,
	z_pos_last_warp_32  = start_live_struct + 0x2C,
	y_pos_last_warp_32  = start_live_struct + 0x30,

	map_id_last_warp_32 = start_live_struct + 0x34,
	unknown_last_warp_32_2 = start_live_struct + 0x24,
	x_pos_last_warp_32_2 = start_live_struct + 0x3C,
	z_pos_last_warp_32_2  = start_live_struct + 0x40,
	y_pos_last_warp_32_2  = start_live_struct + 0x44,

	map_id_stored_warp_16 = start_live_struct + 0x48,
	warp_id_stored_warp_32 = start_live_struct + 0x4C,
	x_stored_warp_16 = start_live_struct + 0x50,
	z_stored_warp_16 = start_live_struct + 0x54,
	y_stored_warp_16 = start_live_struct + 0x58,

	map_id_last_warp_from_overworld_32 = start_live_struct + 0x5C,
	unknown_last_warp_from_overworld_32 = start_live_struct + 0x60,
	x_pos_last_warp_from_overworld_32 = start_live_struct + 0x64,
	z_pos_last_warp_from_overworld_32  = start_live_struct + 0x68,
	y_pos_last_warp_from_overworld_32  = start_live_struct + 0x6C,

	maps_entered_8 = start_live_struct + 0x78, -- counts every time player changes map position in ram (in overworld, even when id remains unchanged)

	x_map_overworld_live_8 = start_live_struct + 0x7C,
	z_map_overworld_live_8 = start_live_struct + 0x7D,

	x_map_overworld_entered_1_8 = start_live_struct + 0x7E, -- updates when maps_entered_8 is set to 1
	z_map_overworld_entered_1_8 = start_live_struct + 0x7F, -- updates when maps_entered_8 is set to 1
	direction_map_entered_1_8 = start_live_struct + 0x80, -- updates when maps_entered_8 is set to 1
	unknown_entered_1_8 = start_live_struct + 0x81, -- updates when maps_entered_8 is set to 1

	x_map_overworld_entered_2_8 = start_live_struct + 0x82, -- updates when maps_entered_8 is set to 2
	z_map_overworld_entered_2_8 = start_live_struct + 0x83, -- updates when maps_entered_8 is set to 2
	direction_map_entered_2_8 = start_live_struct + 0x84, -- updates when maps_entered_8 is set to 2
	unknown_entered_2_8 = start_live_struct + 0x85, -- updates when maps_entered_8 is set to 2

	x_map_overworld_entered_3_8 = start_live_struct + 0x86, -- updates when maps_entered_8 is set to 3
	z_map_overworld_entered_3_8 = start_live_struct + 0x87, -- updates when maps_entered_8 is set to 3
	direction_map_entered_3_8 = start_live_struct + 0x88, -- updates when maps_entered_8 is set to 3
	unknown_entered_3_8 = start_live_struct + 0x89, -- updates when maps_entered_8 is set to 3

	x_map_overworld_entered_4_8 = start_live_struct + 0x8A, -- updates when maps_entered_8 is set to 4
	z_map_overworld_entered_4_8 = start_live_struct + 0x8B, -- updates when maps_entered_8 is set to 4
	direction_map_entered_4_8 = start_live_struct + 0x8C, -- updates when maps_entered_8 is set to 4
	unknown_entered_4_8 = start_live_struct + 0x8D, -- updates when maps_entered_8 is set to 4

	x_map_overworld_entered_5_8 = start_live_struct + 0x8E, -- updates when maps_entered_8 is set to 5
	z_map_overworld_entered_5_8 = start_live_struct + 0x8F, -- updates when maps_entered_8 is set to 5
	direction_map_entered_5_8 = start_live_struct + 0x90, -- updates when maps_entered_8 is set to 5
	unknown_entered_5_8 = start_live_struct + 0x91, -- updates when maps_entered_8 is set to 5

	x_map_overworld_entered_0_8 = start_live_struct + 0x92, -- updates when maps_entered_8 is set to 0
	z_map_overworld_entered_0_8 = start_live_struct + 0x93, -- updates when maps_entered_8 is set to 0
	direction_map_entered_0_8 = start_live_struct + 0x94, -- updates when maps_entered_8 is set to 0
	unknown_entered_0_8 = start_live_struct + 0x95, -- updates when maps_entered_8 is set to 0

	bike_gear_16 = start_live_struct + 0x98, -- 1 is fast, everything else slow
	unknown_mode_16 = start_live_struct + 0x9A,
	movement_mode_32 = start_live_struct + 0x9C, -- walk=0,bike=1,surf=2
	step_counter_max4_8 = start_live_struct + 0xA0, -- %4 performed
}

-- player's npc struct 
start_player_struct = data_table["player_npc_struct_offs"] -- add memory_shift

player_struct = {
	general_npc_data_ptr = start_player_struct + 0x8,
	general_player_data_ptr = start_player_struct + 0xC,
	sprite_id_32 = start_player_struct + 0x30,
	movement_32 = start_player_struct + 0x48, --crashes after 0x10
	facing_dir_32 = start_player_struct + 0x4C,
	movement_32_r = start_player_struct + 0x50,
	last_facing_dir_32 = start_player_struct + 0x54,

	-- last warp coords
	last_warp_x_32 = start_player_struct + 0x6C,
	last_warp_z_32 = start_player_struct + 0x70,
	last_warp_y_32 = start_player_struct + 0x74,

	-- final coords (updated last)
	x_32_r = start_player_struct + 0x78,
	y_32_r = start_player_struct + 0x7C,
	z_32_r = start_player_struct + 0x80,

	-- coords for interacting with terain/collision + position in ram
	x_phys_32 = start_player_struct + 0x84,
	y_phys_32 = start_player_struct + 0x88, 
	z_phys_32 = start_player_struct + 0x8C,

	-- coords used for camera position
	-- has subpixel precision
	x_cam_subpixel_16 = start_player_struct + 0x90,
	x_cam_16 = start_player_struct + 0x92,
	y_cam_subpixel_16 = start_player_struct + 0x94,
	y_cam_16 = start_player_struct + 0x96,
	z_cam_subpixel_16 = start_player_struct + 0x98,
	z_cam_16 = start_player_struct + 0x9A,

	tile_type_16_1 = start_player_struct + 0xCC,
	tile_type_16_2 = start_player_struct + 0xCE,
	sprite_ptr = start_player_struct + 0x12C,
}

start_general_npc_struct = data_table["general_npc_struct_offs"]

general_npc_struct = {
	max_npc_count = start_general_npc_struct + 0x24,
	npc_count = start_general_npc_struct + 0x28,
}

start_npc_struct = data_table["npc_struct_offs"]

generic_npc_struct = {
	sprite_id_16 = start_npc_struct + 0x10,
	obj_code_16 = start_npc_struct + 0x12,
	move_code_16 = start_npc_struct + 0x14,
	event_type_16 = start_npc_struct + 0x16,
	event_flag_16 = start_npc_struct + 0x18,
	
	event_index_16 = start_npc_struct + 0x20,
	movement_32 = start_npc_struct + 0x24, --crashes after 0x10
	facing_dir_32 = start_npc_struct + 0x28,
	movement_32_r = start_npc_struct + 0x2C,
	last_facing_dir_32 = start_npc_struct + 0x30,

	-- spawn location (?)
	x_spawn_32 = start_npc_struct + 0x4C,
	y_spawn_32 = start_npc_struct + 0x50,
	z_spawn_32 = start_npc_struct + 0x54,

	-- final coords (updated last)
	x_32 = start_npc_struct + 0x58,
	y_32 = start_npc_struct + 0x5C,
	z_32 = start_npc_struct + 0x60,

	-- coords for noticing player/talking to npc/collision
	x_phys_32 = start_npc_struct + 0x64,
	y_phys_32 = start_npc_struct + 0x68,
	z_phys_32 = start_npc_struct + 0x6C,

	-- coords used for camera position
	-- has subpixel precision
	x_cam_subpixel_16 = start_npc_struct + 0x70,
	x_cam_16 = start_npc_struct + 0x72,
	y_cam_subpixel_16 = start_npc_struct + 0x74,
	y_cam_16 = start_npc_struct + 0x76,
	z_cam_subpixel_16 = start_npc_struct + 0x78,
	z_cam_16 = start_npc_struct + 0x7A,

	tile_type_16_1 = start_npc_struct + 0xCC,
	tile_type_16_2 = start_npc_struct + 0xCE,

}

start_object_struct = data_table["object_struct_offs"]

object_struct = {
	warp_ptr_offs = start_object_struct + 0x38,
	trigger_ptr_offs = start_object_struct + 0x3C,
	object_count = start_object_struct + 0x40,
	runtime_index_32 = start_object_struct + 0x44,
	x_phys_32 = start_object_struct + 0x48,
	z_phys_32 = start_object_struct + 0x4C,
	y_phys_32 = start_object_struct + 0x50,
	unknown_32 = start_object_struct + 0x54
}

warp_struct = {
	warp_count = -0x4,
	x_phys_16 = 0x0,
	z_phys_16 = 0x2,
	map_id_16 = 0x4,
	warp_index_at_map_id_16 = 0x6, -- the index of the warp you will get out of at the map you teleport to
	unknown_32 = 0x8
}

trigger_struct = {
	trigger_count = -0x4,
	unknown_16 = 0x0,
	x_phys_16 = 0x2,
	z_phys_16 = 0x4,
	vert_count_16 = 0x6,
	hor_count_16 = 0x8,
	unknown_2_16 = 0xA,
	flag_index_32 = 0xC, -- not 100% certain
}


chunk_struct = {
	pointer_32 = 0x0,
	buffer_1 = {},
	buffer_2 = {},
	buffer_3 = {},
	buffer_4 = {},
	
	chunk_pointer_offs = {0x90,0x94,0x98,0x9C},
	current_chunk_8 = 0xAC,
	current_subchunk_8 = 0xAD,
	x_target_subpixel_16 = 0xCC,
	x_target_16 = 0xCE,
	y_target_subpixel_16 = 0xD0,
	y_target_16 = 0xD2,
	z_target_subpixel_16 = 0xD4,
	z_target_16 = 0xD6,
	load_state = 0xE4,
	
	
}

chunk_buffer_struct = {

}
start_item_struct = data_table["item_struct_offs"]

item_pocket_struct = {
	{"items_pocket",start_item_struct, start_item_struct + 0x294},
	{"medicine_pocket",start_item_struct + 0x51C,start_item_struct + 0x5BC},
	{"balls_pocket",start_item_struct + 0x6BC,start_item_struct + 0x6F8},
	{"tms_hms_pocket",start_item_struct + 0x35C,start_item_struct + 0x4EC},	
	{"berries_pocket",start_item_struct + 0x5BC,start_item_struct + 0x6BC},
	{"mails_pocket",start_item_struct + 0x4EC, start_item_struct + 0x51C},
	{"battle_items_pocket",start_item_struct + 0x6F8,start_item_struct + 0x9A1},
	{"key_items_pocket",start_item_struct + 0x294,start_item_struct + 0x35C}
}

selected_key_item = start_item_struct + 0xC25


item_struct = {
	item_id = 0x0,
	item_count = 0x4
}

start_ug_circle_struct = data_table["ug_revealing_circle_struct_offs"]

ug_circle_struct = {
	x_center_circle_32 = start_ug_circle_struct + 0x40,
	z_center_circle_32 = start_ug_circle_struct + 0x44,
	x_subpixel_center_circle_32 = start_ug_circle_struct + 0x48,
	z_subpixel_center_circle_32 = start_ug_circle_struct + 0x4C,
	anime_frame_count = start_ug_circle_struct + 0x50,

}

start_ug_gem_struct = data_table["ug_gem_struct_offs"]

ug_gem_struct = {
	x_phys_16 = start_ug_gem_struct,
	z_phys_16 = start_ug_gem_struct+0x2,
	unknown_16 = start_ug_gem_struct+0x4, -- something to do with interacting, crashes at 0xffff

}

start_ug_trap_struct = data_table["ug_trap_struct_offs"]

ug_trap_struct = {
	x_phys_16 = start_ug_trap_struct,
	z_phys_16 = start_ug_trap_struct+0x2,
	trap_type_id_8 = start_ug_trap_struct+0x4,
	trap_array_id_8 = start_ug_trap_struct+0x5, 
}

start_ug_sphere_struct = data_table["ug_sphere_struct_offs"]

ug_sphere_struct = {
	x_phys_16 = start_ug_sphere_struct + 0x0,
	z_phys_16 = start_ug_sphere_struct + 0x2,
	sphere_size = start_ug_sphere_struct + 0x2,
	sphere_type = start_ug_sphere_struct + 0x1,
	unknown_8 = start_ug_sphere_struct + 0x1 -- not sure, always 0x2? 
}

start_ug_excavation_minigame = data_table["ug_excavation_minigame_offs"]

ug_excavation_minigame_struct = {
	tiles_start = start_ug_excavation_minigame,
	play_state = start_ug_excavation_minigame + 0x82, -- playing=0x8,win/loss=0x0
	leftover_taps_8 = start_ug_excavation_minigame + 0x89,
	screen_offs_32 = start_ug_excavation_minigame + 0x8A, -- for the shaking effect when tapping
}

start_matrix_struct = data_table["matrix_struct_offs"]

matrix_struct = {
	matrix_width_8 = start_matrix_struct + 0x54,
	matrix_height_8 = start_matrix_struct + 0x55,
	matrix_center_16 = start_matrix_struct + 0x56,
}

start_mapdata_and_menu_struct = data_table["mapdata_and_menu_struct_offs"]

mapdata_and_menu_struct = {
	side_menu_state = start_mapdata_and_menu_struct + 0x78,
	menu_index = start_mapdata_and_menu_struct + 0xF4,
}

hovering_item_struct = {
	hovering_item_text_pointer = 0x358,
	hovering_item_id = 0x360,
	unknown_16 = 0x362,
	cursor_offset_16 = 0x364,
}

script_execution_struct = {
	opcode_pointer = data_table["opcode_pointer"]
}

start_hall_of_fame_struct = data_table["hall_of_fame_struct_offs"]
start_species_struct = 0x20

hall_of_fame_struct = {
	specie_struct = {
		species_id_16 = 0x4,
		level_16 = 0x6,
		pid_32 = 0x8,
		tid_16 = 0xC,
		sid_16 = 0xE,
		poke_name = 0x10,
		trainer_name = 0x26,
		move_1_16 = 0x36,
		move_2_16 = 0x38,
		move_3_16 = 0x3A,
		move_4_16 = 0x3C,
		dummy_16 = 0x3E
		},
	year_16 = 0x168,
	month_8 = 0x18A,
	day_8 = 0x18C
}

-- MATH, INPUT, FORMATTING, NON-GAMEPLAY RELATED FUNCTIONS

function fmt(arg,len)
    return string.format("%0"..len.."X", band(4294967295, arg))
end

function print_to_screen(x,y,txt,clr,screen)
	screen = screen or 1
	gui.text(x,screen_y[screen]+y,txt,clr)
end 

debug = true 

function debug_print(text)
	if debug then print(text) end 
end 

function draw_bounding_rectangle(x,y,width,height,fill,border_clr,screen)
	screen = screen or 1
	gui.box(x-(width/2),screen_y[screen]+y-(height/2),x+(width/2),screen_y[screen]+y+(height/2),fill,border_clr)
end 

function draw_rectangle(x,y,width,height,fill,border_clr,screen)
	screen = screen or 1
	gui.box(x,screen_y[screen]+y,x+width,screen_y[screen]+y+height,fill,border_clr)
end 

function draw_line(x,y,width,height,clr,screen)
	screen = screen or 1
	gui.line(x,screen_y[screen]+y,x+width,screen_y[screen]+y+height,clr)
end 


screen_options = {
	OW={-200,0},
	BT={-200,0},
	UG={0,-200}}

function set_screen_params(memory_state)
	return screen_options[memory_state]
end
	
-- INPUT FUNCTIONS 

key = {}
last_key = {}
joy = {}
last_joy = {}
stylus_ = {}
last_stylus = {}

function check_btn_ints()
	for i=0,9 do
		if check_key(""..i) or check_key("Number"..i) then return i end 
	end 
end

hex_num = {"A","B","C","D","E","F"}

function check_btn_hex()
	for i=0,9 do
		if check_key(""..i) or check_key("Number"..i) then return i end 
	end 

	for i,hex in ipairs(hex_num) do
		if check_key(hex) then return i+9 end
	end 
end


function get_keys()
	last_key = key
	key = input.get()
end

function check_keys(btns)
	pressed_key_count = 0
	not_prev_held = false
	for btn =1,#btns do
		if key[btns[btn]] then 	
				pressed_key_count = pressed_key_count + 1
		end 
		if not last_key[btns[btn]] then
			not_prev_held = true -- check if at least 1 button wasn't previously held
		end 
	end
	if not_prev_held then
		return pressed_key_count
	end 
end 

function check_keys_continuous(btns)
	pressed_key_count = 0
	for btn =1,#btns do
		if key[btns[btn]] then 	
				pressed_key_count = pressed_key_count + 1
		end 
	end
	return pressed_key_count
end 

function check_key(btn)
	if key[btn] and not last_key[btn] then
		return true
	else
		return false
	end
end

function get_joy()
	last_joy = joy
	joy = joypad.get()
end 

function get_stylus()
	last_stylus = stylus_
	stylus_ = stylus.get()
end

function is_clicking_area(x,y,x2,y2,click_type)
	click_type = click_type or "leftclick"
	if key[click_type] then 
		if (key["xmouse"] >= x) and (key["xmouse"] <= (x + x2)) then
			if (key["ymouse"] >= y) and (key["ymouse"] <= (y + y2)) then
				return true
			end
		end
	end 
end 

function wait_frames(frames)
	current_frame = emu.framecount()
	target_frame = current_frame + frames
	while current_frame < target_frame do
		emu.frameadvance()
		current_frame = emu.framecount()
		if current_frame == 0 then
		 	break
		end 
	end 
end

clock = os.clock

function sleep(n)  -- seconds
   local t0 = clock()
   while clock() - t0 <= n do
   end
end

function wait_for_reset()
	current_frame = emu.framecount()
	sleep(1)
end

function tap_touch_screen(x_,y_,frames)
	current_frame = emu.framecount()
	target_frame = current_frame + frames
	while current_frame < target_frame do
		stylus_.x = x_
		stylus_.y = y_
		stylus_.touch = true
		stylus.set(stylus_)
		emu.frameadvance()
		current_frame = emu.framecount()
	end 
	stylus_.touch = false
	stylus.set(stylus_)
end

calc_x_start = 33
calc_y_start = 48

calc_x_pos = {["0"]=50,["1"]=50,["2"]=80,["3"]=110,["4"]=50,["5"]=80,["6"]=110,["7"]=50,["8"]=80,["9"]=110,["+"]=140,["-"]=170,["x"]=140,["*"]=140,["/"]=170,["C"]=150,["."]=110,["="]=160,}
calc_y_pos = {["0"]=160,["1"]=125,["2"]=125,["3"]=125,["4"]=90,["5"]=90,["6"]=90,["7"]=60,["8"]=60,["9"]=60,["+"]=90,["-"]=90,["x"]=125,["*"]=125,["/"]=125,["C"]=60,["."]=160,["="]=160,}

function write_calc_input(input_str) -- input in str form
	for i = 1,#input_str do 
		-- gui.text(50,10,"test "..string.sub(input_str,i,i),"red")
		tap_touch_screen(calc_x_pos[string.sub(input_str,i,i)],calc_y_pos[string.sub(input_str,i,i)],2)
		wait_frames(2)
	end 
	use_menu(8)
	wait_frames(2)

end 

function press_button(btn,frames)
	frames = frames or 2
	current_frame = emu.framecount()
	target_frame = current_frame + frames
	while current_frame ~= target_frame do
		joy[btn] = true 
		joypad.set(joy)
		emu.frameadvance()
		current_frame = emu.framecount()
	end 
	joy[btn] = false
end 

function press_buttons(btns,frames)
	frames = frames or 2
	current_frame = emu.framecount()
	target_frame = current_frame + frames
	while current_frame < target_frame do
		for i = 1,#btns do
			joy[btns[i]] = true
		end 
		joypad.set(joy)
		emu.frameadvance()
		current_frame = emu.framecount()
	end 
	for i = 1,#btns do
		joy[btns[i]] = false
	end 
	joypad.set(joy)
end 	

-- menu selection 

function use_menu(menu_index)

	if readword(base + mapdata_and_menu_struct["side_menu_state"]) == 0 then	
		press_button("X")
	end 
	
	current_menu_index = readbyte(base + mapdata_and_menu_struct["menu_index"])

	if menu_index == current_menu_index then 
		wait_frames(4)
		press_button("A")
	elseif menu_index > current_menu_index then 
		btn = "down"
	else
		btn = "up"
	end 

	while menu_index ~= current_menu_index do
		press_button(btn)
		wait_frames(2)
		current_menu_index = readbyte(base + mapdata_and_menu_struct["menu_index"])
	end 
	press_button("A")
end

function find_item_address_from_pocket(item_id,pocket_id,item_id2)
	item_id2 = item_id2 or item_id
	current_addr = base + item_pocket_struct[pocket_id+1][2]
	end_addr = base + item_pocket_struct[pocket_id+1][3]
	current_item_id = readword(current_addr)
	while (current_addr < end_addr) and (current_item_id ~= 0) do
		current_item_id = readword(current_addr)
		if (current_item_id == item_id) or (current_item_id == item_id2)  then
			-- debug_print("item found with id "..fmt(item_id,4).." or id "..fmt(item_id2,4).." at addr "..fmt(current_addr,8).." in "..item_pocket_struct[pocket_id+1][1])
			return  current_addr
		end 
		current_addr = current_addr + 0x4
	end 
	return nil 
end 

function find_item_address(item_id)
	for pocket_id = 0,#item_pocket_struct-1 do
		current_addr = base + item_pocket_struct[pocket_id+1][2]
		end_addr = base + item_pocket_struct[pocket_id+1][3]
		current_item_id = readword(current_addr)
		while (current_addr < end_addr) and (current_item_id ~= 0) do
			current_item_id = readword(current_addr)
			-- debug_print("item with id "..fmt(current_item_id,4)..item_pocket_struct[pocket_id+1][1])
			if current_item_id == item_id then
				data = {current_addr,pocket_id}
				-- debug_print("item found with id "..fmt(item_id,4).." at addr "..fmt(current_addr,8).." in "..item_pocket_struct[pocket_id+1][1])
				return data
			end 
			
			current_addr = current_addr + 0x4
		end 
	end
	debug_print("item with id "..fmt(item_id,4).." not found")
	return {nil,nil}
end 

function switch_to_item(item_id)
	item_data = find_item_address(item_id)
	item_address = item_data[1]
	pocket_id = item_data[2]

	if item_address == nil then
		debug_print("use_item has failed, the requested item cannot be found in any pocket")
		return
	end
	
	current_pocket_id = readbyte(base + data_table["current_pocket_index_offs"])
	count_button_presses = math.abs(pocket_id - current_pocket_id)

	if pocket_id > current_pocket_id then
		direction = "right"
	else
		direction = "left"
	end

	for i = 1,count_button_presses do 
		press_button(direction)
		wait_frames(4)
	end 
	wait_frames(40)
	current_pocket_id = readbyte(base + data_table["current_pocket_index_offs"])	
	hovering_item_id_offs = readdword(data_table["bag_hovering_data_ptr"])

	if readword(hovering_item_id_offs + hovering_item_struct["cursor_offset_16"]) == 0x5A then -- hovering over "none"
		direction = "up"
	else	
		hovering_item_id = readbyte(hovering_item_id_offs + hovering_item_struct["hovering_item_id"])
		hovering_item_address = find_item_address_from_pocket(hovering_item_id,current_pocket_id,hovering_item_id+0x100)

		if hovering_item_address == nil then -- failed to find item in current pocket
			debug_print("use_item failed, item"..fmt(hovering_item_id,4).."couldn't be found in pocket "..current_pocket_id)
			debug_print("function will now return")
			return
		end

		if item_address > hovering_item_address then
			direction = "down"
		else 
			direction = "up"
		end
	end 

	-- slow, but efficient, doesn't work with none sadly
	-- count_button_presses = math.abs(item_address - hovering_item_address)/4

	-- for i = 1,count_button_presses do
	-- 	press_button(direction)
	-- 	wait_frames(8)
	-- end

	-- fast, but inefficient. the duality of man :/

	while item_id%0x100 ~= hovering_item_id do
		press_button(direction)
		wait_frames(2)
		hovering_item_id = readbyte(hovering_item_id_offs + 0x360)
		-- debug_print(fmt(item_id,4),fmt(hovering_item_id,4))
		
		-- if hovering_item_id == 0xF8 then
		-- 	debug_print("Failed to find item")
		-- 	press_button("B")
		-- 	wait_frames(120)
		-- 	press_button("B")
		-- 	wait_frames(8)
		-- 	return
		-- end 
	end

	press_button("A")
	wait_frames(8)
	press_button("A")
	wait_frames(120)
end 

item_list = {
	[0x1AC]="Explorer Kit",
	[0x4F]="Repel"}

function use_item(item_id,menu_open)
	debug_print("Using item: "..item_list[item_id])
	menu_open = menu_open or false 
	if menu_open == false then 
		use_menu(2)
		wait_frames(100)
	end 
	switch_to_item(item_id)
end

function use_explorer_kit(full,crash,reset_,menu_open)
	wait_frames(80)
	use_item(0x01AC,menu_open)

	if full then 
		mash_button("A",200)
		wait_frames(400)
		if crash then
			wait_frames(400)
			debug_print("crash handler")
			press_button("A")
			sleep(2)
			wait_frames(650)
			press_button("A")
			wait_frames(80)
			press_button("A")
			wait_frames(200)
			press_button("A")
			wait_frames(100)
			return
		end
		if reset_ then
			reset()
		end 
		return
	end 
	press_button("B")
	wait_frames(60)
end

function close_menu(close_side_menu)
	press_button("B")
	wait_frames(100)
	if close_side_menu then
		press_button("B")
	end
end

--

function ledgecancel(steps,keep_side_menu)
	steps = steps or 0
	wait_frames(steps*8+4)
	press_button("X")
	if keep_side_menu then return end
	wait_frames(4)
	press_button("B")
	debug_print("Ledgecancel performed")
end 

mash_switch = {
	A = "B",
	B = "A"
}

function mash_text(frames)
	btn= "A"
	current_frame = emu.framecount()
	target_frame = current_frame + frames
	while current_frame < target_frame do
		button_release_frame = current_frame + 2
		while current_frame ~= button_release_frame do 
			joy[mash_switch[btn]] = false
			joy[btn] = true 
			joypad.set(joy)
			emu.frameadvance()
			current_frame = emu.framecount()
		end 
		btn = mash_switch[btn]
	end 
	joy[mash_switch[btn]] = false
end 

function mash_button(btn,frames)
	c_frame_mash = emu.framecount()
	target_frame_mash = c_frame_mash+ frames
	
	while c_frame_mash < target_frame_mash do
		press_button(btn)
		wait_frames(2)
		c_frame_mash = emu.framecount()
	end 
end

function mash_pal_park_text(text_box)
	text_box = text_box or 0

	if text_box == 1 then
		wait_frames(80)
		mash_button("A",620)
		wait_frames(60)
		press_button("down")
		wait_frames(90)
		mash_button("A",12)
		wait_frames(120)
		mash_button("A",200)
		wait_frames(120)
		clear_stepcounter()
		return 
	end 
end 

function save()
	use_menu(4)
	mash_button("A",200)
	wait_frames(400)
end 

function reset(reset_type,wait_for_intro)
	debug_print("resetting")
	reset_type = reset_type or "hard"
	if reset_type == "hard" then
		-- debug_print("hard reset")
		emu.reset()
	elseif reset == "soft" then
		-- debug_print("soft reset")
		press_buttons({"start","select","L","R"},2)
		wait_for_reset()
		wait_frames(40)
	else return
	end 
	if wait_for_intro then
		wait_frames(1600) --1300 is enough, this is for demonstration purposes
		press_button("A")
		wait_frames(80)
		press_button("A")
		wait_frames(200)
		press_button("A")
		wait_frames(100)
		return
	end 
	wait_frames(450)
	press_button("A")
	wait_frames(80)
	press_button("A")
	wait_frames(200)
	press_button("A")
	wait_frames(100)
end 

function save_reset(reset_type,wait_for_intro)
	save()
	reset(reset_type,wait_for_intro)
end 

function wrong_warp_reset(wait_for_intro)
	debug_print("Performing wrong warp")
	mash_button("A",400)
	wait_frames(350)
	mash_button("A",8)
	wait_frames(600)
	reset("hard",wait_for_intro)
end 

function fast_warp(wait_for_intro)
	go_direction_wait_warp("left")
	wait_frames(200)
	clear_stepcounter()
	wait_frames(100)
	left(4)
	up(13)
	graphic_reload()
	up(2)
	right(6)
	graphic_reload()
	down(2)
	graphic_reload()
	down(3)
	right(1)
	wrong_warp_reset(wait_for_intro)
end

function get_on_bike(bike_gear,init_wait)
	init_wait = init_wait or 4
	bike_gear = bike_gear or 1
	init_wait = init_wait or 4
	wait_frames(init_wait)

	if check_bike_state() == 0 then -- walking, slow bike
		press_button("Y")
		wait_frames(8)
		if bike_gear == 1 then 
			press_button("B")
			wait_frames(8)
		end
		return
	end
	if check_bike_state() == 1 then -- on bike, slow bike
		if bike_gear == 1 then
			press_button("B")
		end 
		return
	end 
	if check_bike_state() == 2 then --on bike, fast bike
		if bike_gear == 0 then
			press_button("B")
		end 
		return
	end 
	if check_bike_state() == 4 then -- walking, fast bike
		press_button("Y")
		wait_frames(8)
		if bike_gear == 0 then 
			press_button("B")
			wait_frames(8)
		end
		return
	end
end

function graphic_reload()
	debug_print("Graphic reload")
	use_menu(5)
	wait_frames(100)
	press_button("B")
	wait_frames(100)
	press_button("B")
end 

-- MOVEMENT FUNCTIONS

collision_states = {
	[0x1000] = 0x1C20,
	[0x1C20] = 0x1000
}

function toggle_wtw_state()
	current_collision_state = readword(lang_data["collision_check_addr"])
	writeword(lang_data["collision_check_addr"],collision_states[current_collision_state])
end

function toggle_menu_state()
	menu_state = readbyte(base + data_table["menu_state_offs"])
	if menu_state == 0x0 then
		writebyte(base + data_table["menu_state_offs"],0x2)
		return
	end
	writebyte(base + data_table["menu_state_offs"],0x0)
end 

function set_stepcounter(steps)
	step_addr = base+live_struct["step_counter"]
	writeword(step_addr,steps)
end 

function add_to_stepcounter(steps)
	step_addr = base+live_struct["step_counter"]
	writedword(step_addr,readdword(step_addr)+steps)
end 

function clear_stepcounter()
	tap_touch_screen(115,120,2)

end 

function check_bike_state()
	bike_state = 0
	if readword(base+live_struct["movement_mode_32"]) == 1 then -- on bike
		bike_state = bike_state + 1
		if readword(base+live_struct["bike_gear_16"]) == 1 then -- fast gear
			bike_state = 2
		end
	else 
		if readword(base+live_struct["bike_gear_16"]) == 1 then -- fast gear, but walking
			bike_state = 4
		end	
	end 	
	return bike_state
end 

function move_player(pos,target,pos_offs,joy_b,j_up,j_down,j_left,j_right)
	while pos ~= target do
		joy.up = j_up
		joy.down = j_down
		joy.left = j_left
		joy.right = j_right
		joy.B = joy_b
		joypad.set(joy)
		joy = {}
		emu.frameadvance()
		pos = readdword(base + pos_offs)
	end
end 

function return_arg(input,other)
	if input == "false" then
			return false
		end
	return other
end

function up(steps,delay_before_reset,delay_after_reset,reset_stepcounter)
	if show_steps then debug_print(steps.." N") end
	delay_before_reset = delay_before_reset or 2
	delay_after_reset = delay_after_reset or 4
	reset_stepcounter = return_arg(reset_stepcounter,true)

	player_pos_y = readdword(base + live_struct["z_pos_32_r"])
	target = player_pos_y - steps

	-- account for bike momentum
	if check_bike_state() == 1 then
		if steps > 3 then 
			target = target + 2
		end
	end 

	if target < 0 then
		target = 4294967295 + target + 1
	end
	
	press_b = false
	if (check_bike_state() == 0) or (check_bike_state() == 4) then
		press_b = true
	end 

	move_player(pos,target,live_struct["z_pos_32_r"],press_b,true)
	if reset_stepcounter then
		wait_frames(delay_before_reset*30)
		clear_stepcounter()
	end 
	wait_frames(delay_after_reset*30)
end

function left(steps,delay_before_reset,delay_after_reset,reset_stepcounter)
	if show_steps then debug_print(steps.." W") end
	delay_before_reset = delay_before_reset or 2
	delay_after_reset = delay_after_reset or 4
	reset_stepcounter = return_arg(reset_stepcounter,true)

	player_pos_x = readdword(base + live_struct["x_pos_32_r"])
	target = player_pos_x - steps

	-- account for bike momentum
	if check_bike_state() == 2 then
		if steps > 3 then 
			target = target + 2
		end
	end 

	press_b = false
	if (check_bike_state() == 0) or (check_bike_state() == 4) then
		press_b = true
	end 

	if target < 0 then
		target = 4294967295 + target + 1
	end 

	move_player(pos,target,live_struct["x_pos_32_r"],press_b,false,false,true)
	
	if reset_stepcounter then
		wait_frames(delay_before_reset*30)
		clear_stepcounter()
	end 
	wait_frames(delay_after_reset*30)
end

function down(steps,delay_before_reset,delay_after_reset,reset_stepcounter)
	if show_steps then debug_print(steps.." S") end
	delay_before_reset = delay_before_reset or 2
	delay_after_reset = delay_after_reset or 4
	reset_stepcounter = return_arg(reset_stepcounter,true)

	player_pos_y = readdword(base + live_struct["z_pos_32_r"])
	target = (player_pos_y + steps)%4294967296

	-- account for bike momentum
	if check_bike_state() == 2 then
		if steps > 3 then 
			target = target - 2	
		end 
	end

	press_b = false
	if (check_bike_state() == 0) or (check_bike_state() == 4) then
		press_b = true
	end 

	move_player(pos,target,live_struct["z_pos_32_r"],press_b,false,true)
	if reset_stepcounter then
		wait_frames(delay_before_reset*30)
		clear_stepcounter()
	end 
	wait_frames(delay_after_reset*30)
end

function right(steps,delay_before_reset,delay_after_reset,reset_stepcounter)
	if show_steps then debug_print(steps.." E") end
	delay_before_reset = delay_before_reset or 2
	delay_after_reset = delay_after_reset or 4
	reset_stepcounter = return_arg(reset_stepcounter,true)

	player_pos_x = readdword(base + live_struct["x_pos_32_r"])
	target = (player_pos_x + steps)%4294967296

	-- account for bike momentum
	if check_bike_state() == 2 then
		if steps > 3 then 
			target = target - 2
		end 
	end 

	press_b = false
	if (check_bike_state() == 0) or (check_bike_state() == 4) then
		press_b = true
	end 

	move_player(pos,target,live_struct["x_pos_32_r"],press_b,false,false,false,true)
	if reset_stepcounter then
		wait_frames(delay_before_reset*30)
		clear_stepcounter()
	end 
	wait_frames(delay_after_reset*30)
end

function go_direction_wait_warp(direction,frames)
	frames = frames or 200
	wait_frames(20)
	press_button(direction,8)
	wait_frames(frames)
end

function check_battle_state()
	if readword(data_table["battle_check"]) ~= 0 then
		return true
	end
	return false 
end 

function turn_around(frames,until_encounter)
	debug_print("Trying to get encounter...")
	frames = frames or 400
	until_encounter = return_arg(until_encounter,true)
	if until_encounter then
		while not check_battle_state() do
			press_button("left",4)
			wait_frames(4)
			press_button("right",4)
			wait_frames(4)
		end 
		return
	end 
	c_frame = emu.framecount()
	t_frame = c_frame + frames
	while c_frame < t_frame do
		press_button("right",4)
		wait_frames(4)
		press_button("left",4)
		wait_frames(4)
		emu.frameadvance()
		c_frame = emu.framecount()
		if c_frame == 0 then
		 	break
		end 
	end 
end 

function throw_ball(special_fight)
	if special_fight then -- safari/pal park
		tap_touch_screen(115,120,4)
		return
	end
end 

function catch_pal_park_mon(count)
	debug_print("Catching Pokemon")
	count = count or 6
	for i=0,count-1 do
		turn_around()
		wait_frames(200)
		mash_button("A",120)
		wait_frames(100)
		throw_ball(true)
		mash_button("A",200)
		wait_frames(1000)
	end 
end 

function catching_show(leave,catch)
	mash_button("A",400)
	wait_frames(700)
	if leave then
		use_menu(8)
		wait_frames(80)
		press_button("A")
		wait_frames(320)
	end 
end 

function use_move(move)
	move = move or "surf"
	wait_frames(8)
	mash_button("A",180)
	wait_frames(108)
end 


function nib(byte)
	l_nib = rshift(byte,4)
	h_nib = band(byte,0xF)
	return {l_nib,h_nib}

end 

function bin(num,bits)
	local t = {}
	for b=bits,1,-1 do
		rest = math.fmod(num,2)
		t[b] = rest
		num = (num-rest)/2
	end 
	return t
end 

start_signature_x = 30
start_signature_y = 70

function write_signature(byte_array)
	row = 0
	col = 0
	region = 0

	for byte = 0,#byte_array do

		row = (row + 1)%8
	end 
end

show_steps = true 

-- function auto_calc_input()
-- 	for i = 0,calc_input do
-- 	end 
-- end 

function press_equal_sign()

end 

function auto_movement()
	right(5,0,0,"false")
	down(1,0,0,"false")
	up(1,0,0,"false")
	left(1,0,0,"false")
	get_on_bike(1)
	up(24,0,0,"false")
	left(37,0,0,"false")
	up(12,0,0,"false")
	right(7,0,0,"false")
	down(5,0,0,"false")
	graphic_reload()
	press_button("down",8)
	wait_frames(160)
	clear_stepcounter()
	down(1,2,2,true)
	left(17,2,2,true)
	down(18,2,2,true)
	press_button("Y",8)
	wait_frames(8)
	up(1,2,2,true)
	graphic_reload()
	left(415,2,2,true)
	save_reset()
	
	right(1,2,2,true)
	graphic_reload()
	down(512,2,2,true)
	left(1,2,2,"false")
	left(1,2,2,true)
	down(1,2,2,true)
	wait_frames(8)
	graphic_reload()
	wait_frames(8)
	up(1,2,2,true)
	right(1,2,2,"false")
	right(1,2,2,true)
	up(190,2,2,true)
	right(155,2,2,true)
	down(1,0,0,"false")
	wait_frames(8)
	ledgecancel()
	up(1,2,2,true)
	right(25,2,2,true)
	down(1,2,2,true)
	right(373,2,2,true)
	up(80,2,2,true)
	graphic_reload()
	wait_frames(20)
	press_button("up",16)
	wait_frames(180)
	up(7,0,0,"false")
	wait_frames(20)
	mash_button("A",200)
end 

function auto_calculate()
	write_calc_input("8621850700x256=")
	-- write_calc_input("2199023281152x1=")
	-- for i=0,8 do 
	-- 	use_menu(8)
	-- 	wait_frames(2)
	-- end 
	
end

function manaphy_creation()
	write_calc_input("2450564232073185024x1=")
	write_calc_input("10160726794148251392x1=")
	write_calc_input("2306449044030883584x1=")
	write_calc_input("10160726794181805824x1=")
	write_calc_input("606034850744064x1=")
	write_calc_input("606034867521280x1=")
	write_calc_input("12394512209407903488x1=")
	write_calc_input("432951599128643328x1=")
	write_calc_input("17942946950361908992x1=")
	write_calc_input("15420931159051208448x1=")
	write_calc_input("5476983181833930496x1=")
	write_calc_input("9079862883747104512x1=")
	write_calc_input("14123894466418837248x1=")
	write_calc_input("3747600924973991680x1=")
	write_calc_input("10665129952631850752x1=")
	write_calc_input("16717967851834574592x1=")
	write_calc_input("5765213558086305536x1=")
	write_calc_input("11962166645364885248x1=")
	write_calc_input("16645910257846978304x1=")
	write_calc_input("7206365438895195904x1=")
	write_calc_input("8359286943518820096x1=")
	write_calc_input("6774019874701182720x1=")
	write_calc_input("2882909796669851392x1=")
	write_calc_input("5116695211862394624x1=")
	write_calc_input("8071056567434217216x1=")
	write_calc_input("7710768597261354752x1=")
	write_calc_input("10088669200529753856x1=")
	write_calc_input("13763606496480855808x1=")
	write_calc_input("10088669200563308288x1=")
	write_calc_input("16862083040145311488x1=")
	write_calc_input("12970972962113980160x1=")
	write_calc_input("9151920478120576768x1=")
	write_calc_input("12250397021768255232x1=")
	write_calc_input("15276815971378005760x1=")
	write_calc_input("8935747696057124608x1=")
	write_calc_input("7350480627239487232x1=")
	write_calc_input("9872496418583742208x1=")
	write_calc_input("4396119271717996288x1=")
	write_calc_input("216778817534953216x1=")
	write_calc_input("12034224239771911936x1=")
	write_calc_input("3747600925426976512x1=")
	write_calc_input("12250397021919250176x1=")
	write_calc_input("3243197767195035392x1=")
	write_calc_input("17942946950949111552x1=")
	write_calc_input("16429737476169402112x1=")
	write_calc_input("15060643189465548544x1=")
	write_calc_input("2450564232844936960x1=")
	write_calc_input("7422538221478741760x1=")
	write_calc_input("10448957171088492288x1=")
	write_calc_input("13115088150508603136x1=")
	write_calc_input("12250397022070245120x1=")
	write_calc_input("1153527540246120192x1=")
	write_calc_input("16862083040531187456x1=")
	write_calc_input("4684349648138143488x1=")
	write_calc_input("11529821081758074624x1=")
	write_calc_input("14268009655216113408x1=")
	write_calc_input("6197559122984961792x1=")
	write_calc_input("18375292515411560192x1=")
	write_calc_input("15709161536025003776x1=")
	write_calc_input("10376899577235113728x1=")
	write_calc_input("6125501529014142720x1=")
	write_calc_input("13403318526861641472x1=")
	write_calc_input("4756407242327066368x1=")
	write_calc_input("11169533111719429888x1=")
	write_calc_input("7134307845612242688x1=")
	write_calc_input("2810852203353343744x1=")
	write_calc_input("13187145744831743744x1=")
	write_calc_input("7782826192003925760x1=")
	write_calc_input("9800438825082685184x1=")
	write_calc_input("8791632508568471296x1=")
	write_calc_input("11097475517798942464x1=")
	write_calc_input("12970972962801846016x1=")
	write_calc_input("17726774169321867008x1=")
	write_calc_input("13619491309176751872x1=")
	write_calc_input("72663630063077120x1=")
	write_calc_input("3891716114090034944x1=")
	write_calc_input("17222371011123480320x1=")
	write_calc_input("7710768598133769984x1=")
	write_calc_input("11529821082160727808x1=")
	write_calc_input("6485789499522549504x1=")
	write_calc_input("17438543793304372992x1=")
	write_calc_input("10160726795490428672x1=")
	write_calc_input("1369700322879997696x1=")
	write_calc_input("12826857774927316736x1=")
	write_calc_input("15420931160309499648x1=")
	write_calc_input("4324061678485374720x1=")
	write_calc_input("15637103942456837888x1=")
	write_calc_input("3891716114291361536x1=")
	write_calc_input("9944554013494085376x1=")
	write_calc_input("16934140635189872384x1=")
	write_calc_input("13835664091575748352x1=")
	write_calc_input("10232784389696128768x1=")
	write_calc_input("3171140173995968256x1=")
	write_calc_input("17078255823332837120x1=")
	write_calc_input("18303234921994389248x1=")
	write_calc_input("15348873566456121088x1=")
	write_calc_input("7206365440187041536x1=")
	write_calc_input("577066788714448640x1=")
	write_calc_input("8647517320979154688x1=")
	write_calc_input("15853276724788725504x1=")
	write_calc_input("11241590706378114816x1=")
	write_calc_input("17582658981732550400x1=")
	write_calc_input("12322454616980588288x1=")
	write_calc_input("8143114162797545216x1=")
	write_calc_input("15709161536796755712x1=")
	write_calc_input("5188752807276054272x1=")
	write_calc_input("12970972963389048576x1=")
	write_calc_input("5332867995385464576x1=")
	write_calc_input("15709161536863864576x1=")
	write_calc_input("11457763488642893568x1=")
	write_calc_input("18375292516300752640x1=")
	write_calc_input("1225585135290681088x1=")
	write_calc_input("11169533112541513472x1=")
	write_calc_input("12034224241013425920x1=")
	write_calc_input("1946161075720292096x1=")
	write_calc_input("17798831764081215232x1=")
	write_calc_input("3243197768436549376x1=")
	write_calc_input("9728381231866840832x1=")
	write_calc_input("8719574915352626944x1=")
	write_calc_input("10016611608052107008x1=")
	write_calc_input("9872496419993028352x1=")
	write_calc_input("1369700323534309120x1=")
	write_calc_input("8791632509457663744x1=")
	write_calc_input("17870889358253360896x1=")
	write_calc_input("4468176867215542016x1=")
	write_calc_input("16429737477528356608x1=")
	write_calc_input("10016611608169547520x1=")
	write_calc_input("8647517321465693952x1=")
	write_calc_input("12178339429340940032x1=")
	write_calc_input("2666737016351229696x1=")
	write_calc_input("4540234461354133248x1=")
	write_calc_input("4324061679257126656x1=")
	write_calc_input("1946161076022281984x1=")
	write_calc_input("6701962282542302976x1=")
	write_calc_input("4684349649497097984x1=")
	write_calc_input("360894007238199040x1=")
	write_calc_input("144115462953870336x1=")
	print("done")
end 

hex = false 

function toggle_hexview()
	hex = not hex
end 

map_editing =  false 

function toggle_map_editing()
	map_editing = not map_editing 
	temp_map_id = ""
end


function change_map_id()
	value = check_btn_ints()
	if value ~= nil then 
		temp_map_id = temp_map_id..value
		writeword(base + live_struct["map_id_32"],tonumber(temp_map_id))
	end
	if (#temp_map_id > 4) or (key.enter) then
		temp_map_id = tonumber(temp_map_id)
		if temp_map_id > 65535 then
			temp_map_id = 65535
		end 
		writeword(base + live_struct["map_id_32"],temp_map_id)
		map_editing = false
	end
end 

memory_editing = false


function toggle_memory_addr_editing()
	memory_editing = not memory_editing
	temp_memory_addr = 0
	temp_str_memory_addr = "0"
end

function change_memory_addr()
	value = check_btn_hex()
	if value ~= nil then 
		if #temp_str_memory_addr < 7 then 
			temp_memory_addr = lshift(temp_memory_addr,4) + value 
			temp_str_memory_addr = fmt(temp_memory_addr,0)
			return
		end 
	end

	if key.enter then
		memview_addr = temp_memory_addr - temp_memory_addr%16
		memory_editing = false
		scroll_vertical = 0
		return
	end

	if check_key("backspace") then 
		temp_memory_addr = rshift(temp_memory_addr,4)
		temp_str_memory_addr = fmt(temp_memory_addr,0)
	end

end 

teleport_editing =  false 

function toggle_teleport_editing()
	teleport_editing = not teleport_editing 
	temp_teleport_amount = ""
end

function change_teleport_amount()
	value = check_btn_ints()
	if value ~= nil then 
		temp_teleport_amount = temp_teleport_amount..value
		tp_amount = tonumber(temp_teleport_amount)
	end
	if (#temp_teleport_amount > 4) or (key.enter) then
		temp_teleport_amount = tonumber(temp_teleport_amount)
		if temp_teleport_amount > 65535 then
			temp_teleport_amount = 65535
		end 
		tp_amount = temp_teleport_amount
		teleport_editing = false
	end
end 


tp_amount = 31

function teleport_up()
	z_phys_32 = readdword(base + player_struct["z_phys_32"] + memory_shift)
	writedword(base + player_struct["z_phys_32"] + memory_shift,z_phys_32 - tp_amount) 
	z_cam_16 = readword(base + player_struct["z_cam_16"] + memory_shift)
	writeword(base + player_struct["z_cam_16"] + memory_shift,z_cam_16 - tp_amount) 
	add_to_stepcounter(tp_amount)
end

function teleport_left()
	x_phys_32 = readdword(base + player_struct["x_phys_32"] + memory_shift)
	writedword(base + player_struct["x_phys_32"] + memory_shift,x_phys_32 - tp_amount) 
	x_cam_16 = readword(base + player_struct["x_cam_16"] + memory_shift)
	writeword(base + player_struct["x_cam_16"] + memory_shift,x_cam_16 - tp_amount)
	add_to_stepcounter(tp_amount) 
end

function teleport_right()
	x_phys_32 = readdword(base + player_struct["x_phys_32"] + memory_shift)
	writedword(base + player_struct["x_phys_32"] + memory_shift,x_phys_32 + tp_amount) 
	x_cam_16 = readword(base + player_struct["x_cam_16"] + memory_shift)
	writeword(base + player_struct["x_cam_16"] + memory_shift,x_cam_16 + tp_amount)
	add_to_stepcounter(tp_amount)
end

function teleport_down()
	z_phys_32 = readdword(base + player_struct["z_phys_32"] + memory_shift)
	writedword(base + player_struct["z_phys_32"] + memory_shift,z_phys_32 + tp_amount) 
	z_cam_16 = readword(base + player_struct["z_cam_16"] + memory_shift)
	writeword(base + player_struct["z_cam_16"] + memory_shift,z_cam_16 + tp_amount) 
	add_to_stepcounter(tp_amount)
end

-- GUI GAMEPLAY FUNCTIONS

function get_memory_state()
	if readdword(base+data_table["memory_state_check_offs"]) == (base + data_table["memory_state_check_val"]) then -- check for ug/bt ptr
		if readbyte(data_table["ug_init_addr"]) == data_table["ug_init_val"] then -- if 0x1f, is UG
			return "UG"
		end
		return "BT" 
	end 
	return "OW"
end

function get_edit_color(editing)
	if editing then return "red" end
	return "yellow"
end 

function show_player_data()
	x_phys_32 = readword(base + player_struct["x_phys_32"] + memory_shift)
	z_phys_32 = readword(base + player_struct["z_phys_32"] + memory_shift) 
	map_id_phys_32 =  readword(base + live_struct["map_id_32"])
	print_to_screen(10,30,"Physical:","yellow")
	print_to_screen(20,40,"X: "..x_phys_32..","..fmt(x_phys_32,4),"yellow")
	print_to_screen(20,50,"Z: "..z_phys_32..","..fmt(z_phys_32,4),"yellow")
	print_to_screen(20,60,"Map Id: "..map_id_phys_32..","..fmt(map_id_phys_32,4),get_edit_color(map_editing))
	x_stored_warp_16 = readword(base + live_struct["x_stored_warp_16"])
	z_stored_warp_16 = readword(base + live_struct["z_stored_warp_16"])	
	map_id_stored_warp_16 = readword(base + live_struct["map_id_stored_warp_16"])
	warp_id_stored_warp_32 = readword(base + live_struct["warp_id_stored_warp_32"])
	print_to_screen(10,80,"Stored Warp:","yellow")
	print_to_screen(20,90,"X: "..x_stored_warp_16..","..fmt(x_stored_warp_16,4),"yellow")
	print_to_screen(20,100,"Z: "..z_stored_warp_16..","..fmt(z_stored_warp_16,4),"yellow")
	print_to_screen(20,110,"Map Id: "..map_id_stored_warp_16..","..fmt(map_id_stored_warp_16,4),"yellow")
	print_to_screen(20,120,"Warp Id: "..warp_id_stored_warp_32..","..fmt(warp_id_stored_warp_32,4),"yellow")
	--print_to_screen(20,120,fmt(base + live_struct["warp_id_stored_warp_32"],4),"yellow")

	step_counter = readword(base + live_struct["step_counter"])
	print_to_screen(10,140,"Steps: "..step_counter,"yellow")
	npc_count = readbyte(base + general_npc_struct["npc_count"] + memory_shift) -1 
	print_to_screen(10,150,"NPCs: "..npc_count,"yellow")
	print_to_screen(10,160,"TP: "..tp_amount,get_edit_color(teleport_editing))
	
end

function win_ug_minigame()
	for i = 0,data_table["ug_excavation_minigame_tile_count"] do
		writebyte(base+ug_excavation_minigame_struct["tiles_start"]+i,0)		
	end 
end

function remove_trap_effect()
end 

-- BOUNDING BOXES
bounding_view = false
function toggle_bounding_view()
	bounding_view = not bounding_view
end 


function show_ug_gems() 
	draw_bounding_boxes(data_table["ug_gem_count"],base + ug_gem_struct["x_phys_16"], base + ug_gem_struct["z_phys_16"],data_table["ug_gem_struct_size"],0x0,"#FFF8666","#FFF66")
end 

function show_ug_traps()
	ug_trap_count = readbyte(data_table["ug_trap_count_addr"])
	draw_bounding_boxes(ug_trap_count,base + ug_trap_struct["x_phys_16"], base + ug_trap_struct["z_phys_16"],data_table["ug_trap_struct_size"],0x0,"#FFFFFF8","white")
end 

function show_ug_spheres()
	-- start of data at base + start_ug_sphere_struct
	-- start here, check if at every 0x8 bytes (the size of the struct) the first byte is 0x0, if so, stop, count how many there are
	local struct_size = data_table["ug_sphere_struct_size"]
	local x_phys_16 = base + ug_sphere_struct["x_phys_16"]
	local z_phys_16 = base + ug_sphere_struct["z_phys_16"]

	for i = 0, data_table["ug_max_sphere_count"] do
		if readbyte(base + start_ug_sphere_struct + (i * struct_size)) == 0x0 then
			break
		end
		draw_bounding_box(readword(x_phys_16 + i*struct_size),readword(z_phys_16 + i*struct_size),"#FF00008","red")
	end
end

function show_objects()
	object_count = readword(base+object_struct["object_count"])
	draw_bounding_boxes(object_count,base + object_struct["x_phys_32"], base + object_struct["z_phys_32"],data_table["object_struct_size"],0x0,"#9793FF8","purple")
end 

function show_triggers()
	start_trigger_struct = readdword(base+object_struct["trigger_ptr_offs"])
	trigger_count = readword(start_trigger_struct+trigger_struct["trigger_count"])
	for i = 0,trigger_count-1 do 
		x_phys_16 = readword(start_trigger_struct + trigger_struct["x_phys_16"] + i*data_table["trigger_struct_size"])
		z_phys_16 = readword(start_trigger_struct + trigger_struct["z_phys_16"] + i*data_table["trigger_struct_size"])
		vert_count_16 = readword(start_trigger_struct+trigger_struct["vert_count_16"] + i*data_table["trigger_struct_size"])
		hor_count_16 = readword(start_trigger_struct+trigger_struct["hor_count_16"] + i*data_table["trigger_struct_size"])
		for vert_offs = 0, vert_count_16-1 do
			x_trigger_inst = x_phys_16 + vert_offs
			for hor_offs = 0, hor_count_16-1 do
				z_trigger_inst = z_phys_16 + hor_offs
				draw_bounding_box(x_trigger_inst,z_trigger_inst,"#FFF8666","#FFF66")		
			end 
		end 
	end
end

function show_warps()
	start_warp_struct = readdword(base+object_struct["warp_ptr_offs"])
	warp_count = readword(start_warp_struct+warp_struct["warp_count"])
	draw_bounding_boxes(warp_count,start_warp_struct+warp_struct["x_phys_16"],start_warp_struct+warp_struct["z_phys_16"],data_table["warp_struct_size"],0x0,"#600038", "#C00058")
end 

function show_npcs()
	npc_count = readbyte(base + general_npc_struct["npc_count"] + memory_shift) -1 -- subtracting player's npc from count
	if npc_count > 0 then -- prevent negative npc count when not initialized
		draw_bounding_boxes(npc_count,base + generic_npc_struct["x_phys_32"],base + generic_npc_struct["z_phys_32"],data_table["npc_struct_size"],memory_shift,"#88FFFFA0","#0FB58")
	end
end

function show_trainer_range()
	npc_count = readbyte(base + general_npc_struct["npc_count"] + memory_shift) -1 -- subtracting player's npc from count
	if npc_count > 0 then -- prevent negative npc count when not initialized
		
	end
end 

function draw_bounding_boxes(count,x_start,z_start,struct_size,extra_offs,fill,border)
	for i = 0,count-1 do 
		x_phys_32 = readword(x_start + i*struct_size + extra_offs)
		z_phys_32 = readword(z_start + i*struct_size + extra_offs)
		draw_bounding_box(x_phys_32,z_phys_32,fill,border)
	end
end 

function draw_bounding_box(x,z,fill_clr,border_clr)
	x_v = (readword(base + live_struct["x_pos_32_r"]) - x) *16
	y_v = (readword(base + live_struct["z_pos_32_r"]) - z)
	if y_v > 0 then 
		y_v = y_v*13
	else
		y_v = y_v*15.5
	end
	draw_bounding_rectangle(127-x_v,99-y_v,12,12,fill_clr,border_clr)
end

function draw_player_pos(fill_clr,border_clr)
	draw_bounding_rectangle(128,99,15,14,fill_clr,border_clr)
end 

function show_bounding_boxes(memory_state)
	-- data that should always be shown
	draw_player_pos("#88FFFFA0","#0FB58")
	show_npcs()

	-- data that should only be shown when in UG (check is for excavation game)
	if memory_state == "UG" then
		-- if readbyte(base+data_table["menu_addr"]) == 0 then 
		show_ug_gems()
		show_ug_traps()
		show_ug_spheres()
		-- 	return 
		-- end
		return
	end 
	-- data that should only be shown when not in UG
	show_objects()
	show_triggers()
	show_warps()
	-- data that is unique to overworld
end 

--
menu_id = 0
menu_count = 2

function increment_menu()
	menu_id = (menu_id + 1)%menu_count
end 

function get_map_id_color(map_id)
	if map_id > 558 then return map_id_list['jubilife_city']['color'] end
	return map_ids[map_id] or map_id_list['default']['color']
end 

c_map_converted = {[1000]=">999"}

function get_display_map(map_id)
	return c_map_converted[map_id] or map_id
end

set_matrix_height = none

function toggle_matrix_mode()
	if set_matrix_height == 30 then
	 set_matrix_height = none
	 return
	end 
	set_matrix_height = 30
end 

function show_void_pos()
	matrix_width = readbyte(base + matrix_struct["matrix_width_8"])
	matrix_height = set_matrix_height or readbyte(base + matrix_struct["matrix_height_8"])
	matrix_center = base + matrix_struct["matrix_center_16"]

	x_phys_32 = readdwordsigned(base + player_struct["x_phys_32"] + memory_shift)
	z_phys_32 = readdwordsigned(base + player_struct["z_phys_32"] + memory_shift)

	x_offs = math.modf(x_phys_32 / 32) *2
	z_offs = math.modf(z_phys_32 / 32) *2 *matrix_height 

	center = (5*2) + (matrix_height*2*9)

	print_to_screen(130,15,"Void pos: 0x" .. fmt(matrix_center+x_offs+z_offs,8),"yellow")

	if hex then hex_show_pos() return end
	int_show_pos()
end

function hex_show_pos()
	initial_addr =  matrix_center + x_offs + z_offs
	start_addr = initial_addr + scroll_vertical*2*matrix_height + scroll_horizontal*2
	for row=0,9 do
		for col=0,18 do 
			c_map_offset = start_addr + row*2 + col*2*matrix_height-center
			c_map_id = readword(c_map_offset)

			if (c_map_offset == initial_addr) then
				clr = 'white'
			else
				clr = get_map_id_color(c_map_id)
			end
			print_to_screen(3 + row*25,3 + col*10,fmt(c_map_id,4),clr,2)
		end 
	end

end


function int_show_pos()
	initial_addr =  matrix_center + x_offs + z_offs
	start_addr = initial_addr + scroll_vertical*2*matrix_height + scroll_horizontal*2
	
	for row=0,9 do
		for col=0,18 do 
			c_map_offset = start_addr + row*2 + col*2*matrix_height-center
			c_map_id = math.min(readword(c_map_offset),1000)

			
			if (c_map_offset == initial_addr) then
				clr = 'white'
			else
				clr = get_map_id_color(c_map_id)
			end
 
				print_to_screen(3 + row*25,3 + col*10,get_display_map(c_map_id),clr,2)
		end 
	end 
end 

function split_word_into_bytes(word)
	h_byte = rshift(word,8)
	l_byte = band(word,0xFF)
	return {l_byte,h_byte}
end 

-- Loadlines and grid

grid = false
loadlines = true 
maplines = false
mapmodellines = false

function toggle_grid()
	grid = not grid
end 

function toggle_loadlines()
	loadlines = not loadlines
end 

function toggle_maplines()
	maplines = not maplines
end

function toggle_mapmodellines()
	mapmodellines = not mapmodellines
end

function show_boundary_lines()
	if grid then show_gridlines() end
	if loadlines then show_loadlines() end
	if maplines then show_maplines() end
	if mapmodellines then show_mapmodellines() end 
end 

function show_gridlines()
	for i = 0,15 do draw_line(i*16+7,0,0,200, "#0FB58") end 
	for i = 0,7 do draw_line(0,i*13,256,0, "#0FB58") end
	for i = 0,6 do draw_line(0,7*13+15.5*i,256,0, "#0FB58") end
end 

function show_loadlines()
	x_cam_16 = readword(base + player_struct["x_cam_16"] + memory_shift)
	z_cam_16 = readword(base + player_struct["z_cam_16"] + memory_shift)

	add_x = 0
	add_y = 0
	if x_cam_16 > 0x7FFF then 
		add_x = 1
	end 
	if z_cam_16 > 0x7FFF then 
		add_y = 1
	end 

	x_line = (-x_cam_16+23)%32 - add_x
	z_line = (-z_cam_16+23)%32 - add_y + add_x
	draw_line(x_line*16+7,0,0,200, "red")
	if z_line < 14 then 
		if z_line > 7 then draw_line(0,7*13+(z_line-7)*15.5,256,0, "red") return end
		draw_line(0,13*z_line,256,0, "red")
	end 
end

function show_maplines()
	x_phys_32 = readdword(base + player_struct["x_phys_32"] + memory_shift)
	z_phys_32 = readdword(base + player_struct["z_phys_32"] + memory_shift)

	add_x = 0
	add_y = 0
	if x_phys_32 > 0x7FFF then 
		add_x = 1
	end 
	if z_phys_32 > 0x7FFF then 
		add_y = 1
	end 

	x_line = (-x_phys_32+7)%32 + add_x
	z_line = (-z_phys_32+7)%32 + add_y
	draw_line(x_line*16+7,0,0,200, "blue")
	if z_line < 14 then 
		if z_line > 7 then draw_line(0,7*13+(z_line-7)*15.5,256,0, "blue") return end
		draw_line(0,13*z_line,256,0, "blue")
	end 

end  

function show_mapmodellines()
	x_cam_16 = readword(base + player_struct["x_cam_16"] + memory_shift)
	z_cam_16 = readword(base + player_struct["z_cam_16"] + memory_shift)
	x_line = (-x_cam_16+7)%32
	z_line = (-z_cam_16+7)%32
	draw_line(x_line*16+7,0,0,200, "orange")
	if z_line < 14 then 
		if z_line > 7 then draw_line(0,7*13+(z_line-7)*15.5,256,0, "orange") return end
		draw_line(0,13*z_line,256,0, "orange")
	end

end 

function get_tile_color(tile_data)
	tile_id = band(tile_data,0xff)
	collision = rshift(tile_data,8)

	if tile_id == 0x00 then 
		if collision > 0x7F then return "#CCCCCC" end
		return
	end 

	return tile_ids[tile_id]

end 

function get_collision_color(collision)
	if rshift(collision,7) ~= 0 then return "#CCCCCC" end
	return tile_id_list['default']['color']
end 

chunk_scr_x = {0,128,0,128}
chunk_scr_y = {0,0,96,96}

tile_view = true 

function toggle_tile_view()
	tile_view = not tile_view
end 

player_view = true 

function toggle_player_pos()
	player_view = not player_view
end

function show_chunks_ow()
	show_tile_data()
	-- draw_rectangle(0,0,256,200,"#000022ccc",0,2)
	draw_rectangle(0,0,256,200,"#000001fff","#000001fff",2)
	
	additional_offset = 0
	x_phys_32 = readdword(base + player_struct["x_phys_32"] + memory_shift)
	z_phys_32 = readdword(base + player_struct["z_phys_32"] + memory_shift)

	if x_phys_32 > 0x7FFFFFF then 
		additional_offset = additional_offset -64
	end 
	if z_phys_32 > 0x7FFFFFF then 
		additional_offset = additional_offset -64
	end 

	if tile_view then 
		show_tiles_ow(additional_offset)
		if player_view then
			show_chunk_position()
		end 
		return
	end 
	show_collision_ow(additional_offset)
	if player_view then
		show_chunk_position()
		return
	end 
end 

show_load_calculations = false

function toggle_load_calculations()
	show_load_calculations = not show_load_calculations
end 

debug_tile_print = false
function toggle_debug_tile_print()
	debug_tile_print = not debug_tile_print
end 

function show_tile_data()
	tile_id = readbyte(base + player_struct["tile_type_16_1"] + memory_shift)
	-- current_tile_2 = readbyte(base + player_struct["tile_type_16_2"] + memory_shift) -- slower
	print_to_screen(143,15,"Tile: "..tile_id..","..fmt(tile_id,2),'yellow')
	print_to_screen(143,25,tile_names[tile_id+1],'yellow')

	start_chunk_struct = readdword(base+data_table["chunk_calculation_ptr"])
	print_to_screen(143,35,"Loading:",'yellow')
	load_state = readbyte(start_chunk_struct + chunk_struct["load_state"])
	if load_state == 0 then
		print_to_screen(198,35,"true",'green')
		
	else 
		print_to_screen(198,35,"false",'red')
	end

	--print_to_screen(143,45,"Vis X: ".. readword(data_table['graphical_x']).."," .. fmt(readword(data_table['graphical_x']),1),"yellow")
	
	if show_load_calculations then 
		x_target_16 = readword(start_chunk_struct + chunk_struct["x_target_16"])
		z_target_16 = readword(start_chunk_struct + chunk_struct["z_target_16"])
		print_to_screen(143,45,"Target:",'yellow')
		print_to_screen(143,55,"    X: "..x_target_16..","..fmt(x_target_16,4),'yellow')
		print_to_screen(143,65,"    Z: "..z_target_16..","..fmt(z_target_16,4),'yellow')

		x_cam_16 = readword(base + player_struct["x_cam_16"] + memory_shift)
		z_cam_16 = readword(base + player_struct["z_cam_16"] + memory_shift) 

		print_to_screen(143,75,"Graphical:",'yellow')
		print_to_screen(143,85,"    X: "..x_cam_16..","..fmt(x_cam_16,4),'yellow')
		print_to_screen(143,95,"    Z: "..z_cam_16..","..fmt(z_cam_16,4),'yellow')
	end 

end 

function show_tiles_ow(additional_offset)
	start_chunk_struct = readdword(base+data_table["chunk_calculation_ptr"])
	print_to_screen(153,140,"0x"..fmt(start_chunk_struct,8))
	chunk_pointer_offs = chunk_struct["chunk_pointer_offs"]
	chunk_pointers = {}
	print_to_screen(153,150,"Chunk addresses:")
	for i = 1,#chunk_pointer_offs do
		chunk_pointer = readdword(chunk_pointer_offs[i] + start_chunk_struct)
		print_to_screen(153,150+i*10,"0x"..fmt(chunk_pointer,7))
		for col = 0,31 do 
			for row = 0,31 do 
				tile_data = readword(chunk_pointer+row*2 + col*64+additional_offset)
				tile_color = get_tile_color(tile_data)
				draw_rectangle(chunk_scr_x[i]+row*4,chunk_scr_y[i] + col*3,5,4,tile_color,0,2)
			end
		end 
	end 
end

function show_collision_ow(additional_offset)
	start_chunk_struct = readdword(base+data_table["chunk_calculation_ptr"])
	print_to_screen(153,140,"0x"..fmt(start_chunk_struct,8))
	chunk_pointer_offs = chunk_struct["chunk_pointer_offs"]
	chunk_pointers = {}
	print_to_screen(153,150,"Chunk addresses:")
	for i = 1,#chunk_pointer_offs do
		chunk_pointer = readdword(chunk_pointer_offs[i] + start_chunk_struct)
		print_to_screen(153,150+i*10,"0x"..fmt(chunk_pointer,7))
		for row = 0,31 do 
			for col = 0,31 do 
				if (readbyte(chunk_pointer+row*2 + col*64+additional_offset)) ~= 0xff then
					collision  = readbyte(chunk_pointer+row*2 + col*64+1+additional_offset)
					collision_color = get_collision_color(collision)
				end 
				draw_rectangle(chunk_scr_x[i]+row*4,chunk_scr_y[i] + col*3,5,4,collision_color,0,2)
			end
		end 

	end 
end

function show_chunk_position()
	start_chunk_struct = readdword(base+data_table["chunk_calculation_ptr"])
	c_chunk = readbyte(chunk_struct["current_chunk_8"] + start_chunk_struct)
	if c_chunk < 4 then 
		x_phys_32 = readdword(base + player_struct["x_phys_32"] + memory_shift)
		z_phys_32 = readdword(base + player_struct["z_phys_32"] + memory_shift)
		if x_phys_32 > 0x7FFFFFF then 
			c_chunk = 1
		end 
		if z_phys_32 > 0x7FFFFFF then 
			z_phys_32 = z_phys_32 + 1
		end 
		row = x_phys_32%32
		col = z_phys_32%32
		draw_rectangle(chunk_scr_x[c_chunk+1]+row*4,chunk_scr_y[c_chunk+1] + col*3,5,4,"#00f0ff",0,2)
	
	end
	
end 

function setup_search_collect()
	os.execute("mkdir searched_tiles")

    for _, entry in ipairs(texture_data) do
        local map_id = entry.map_ids[1]
		savestate.load(2)
		writeword(base + live_struct["map_id_32"], map_id)
		print("Switched to map ID: " .. map_id)

		press_button("B")
		wait_frames(120)

		press_button("A")
		wait_frames(120)
		savestate.save(3)

		search_tile_collect(entry)
    end
end

function search_tile_collect(entry)
    local map_id_phys_32 = readword(base + live_struct["map_id_32"])
    local map_name = "map_" .. fmt(map_id_phys_32, 4)

    local final_data = {
        primary_map_ids = entry.map_ids,
        results = {}
    }

    for set_id, set in pairs(texture_data) do
        local result = {
            map_ids = set.map_ids,
            tile_data = {}
        }

		savestate.load(3)
        local original_data = dump_tiles_and_collisions(set.offsets)

		writeword(base + live_struct["map_id_32"], set.map_ids[1])
        press_button("B")
        wait_frames(60)

        local updated_data = dump_tiles_and_collisions(set.offsets)

        for offs, original_tiles in pairs(original_data) do
            local updated_tiles = updated_data[offs]
            local tiles = {}

            for i, original_tile in ipairs(original_tiles) do
                local updated_tile = updated_tiles[i]

                if original_tile.tile ~= updated_tile.tile or original_tile.collision ~= updated_tile.collision then
                    table.insert(tiles, {
                        tile = "X",
                        collision = "X",
                        walkable = "X"
                    })
                else
                    table.insert(tiles, original_tile)
                end
            end

            result.tile_data[string.format("0x%X", offs)] = tiles
        end

        table.insert(final_data.results, result)
    end

    local file_name = "searched_tiles/tiles_" .. map_name .. ".json"
    local file = io.open(file_name, "w")
    file:write(serialize_to_json(final_data))
    file:close()

    print("Tile data saved to " .. file_name)
end


function dump_tiles_and_collisions(offsets)
    local data = {}

    for _, offs in pairs(offsets) do
        local tiles = {}
        for tile_offs = 0, 0x26, 2 do
            local tile_addr = base + (offs - 0x26) + tile_offs
            local tile = memory.readbyte(tile_addr)
            local collision = memory.readbyte(tile_addr + 1)
            local walkable = collision <= 0x7F

            table.insert(tiles, {
                tile = tile,
                collision = collision,
                walkable = walkable
            })
        end
        data[offs] = tiles
    end

    return data
end

function serialize_to_json(tbl, indent)
    indent = indent or 0
    local json = ""
    local padding = string.rep("    ", indent)

    if type(tbl) == "table" then
        local is_array = #tbl > 0
        json = json .. (is_array and "[\n" or "{\n")
        local first = true
        for k, v in pairs(tbl) do
            if not first then
                json = json .. ",\n"
            end
            first = false
            if not is_array then
                local key = type(k) == "string" and string.format("%q", k) or string.format("%q", tostring(k))
                json = json .. padding .. "    " .. key .. ": "
            else
                json = json .. padding .. "    "
            end
            json = json .. serialize_to_json(v, indent + 1)
        end
        json = json .. "\n" .. padding .. (is_array and "]" or "}")
    elseif type(tbl) == "string" then
        json = string.format("%q", tbl)
    else
        json = tostring(tbl)
    end

    return json
end

map_ase_combos = {
	[28] = {0x2A15E,0x2A1D6,0x2A18E,0x2A186,0x2A1F4,0x2A1B2,0x2A1EC,0x2A170,
			0x2A99C,0x2AA18,0x2A9DE,0x2AA20,0x2A9B2,0x2A9BA,0x2AA02,0x2A98A,0x2A9D0},
	[67] = {},
	[68] = {0x2A130,0x2A164,0x2A11A,0x2A190,0x2A18E,0x2A148,0x2A13A,
			0x2A95C,0x2A966,0x2A974,0x2A9BA,0x2A9BC,0x2A946,0x2A990}
}
-- order the lists above by offset

map_ase_combos =  {
	[28] = {0x2A15E,0x2A170,0x2A186,0x2A18E,0x2A1B2,0x2A1D6,0x2A1EC,0x2A1F4,
			0x2A99C,0x2A9B2,0x2A9BA,0x2A9D0,0x2A9DE,0x2A98A,0x2AA02,0x2AA18,0x2AA20},
	[67] = {},
	[68] = {0x2A11A,0x2A130,0x2A13A,0x2A148,0x2A164,0x2A190,0x2A18E,
			0x2A95C,0x2A946,0x2A966,0x2A974,0x2A990,0x2A9BA,0x2A9BC}
}

-- find the missing value in map 28's list, bottom row is correct, the 2 sequences have the same intervals


function search_ase_manip()
	for map_id,offsets in pairs(map_ase_combos) do
		print("Searching for map "..map_id)
		results = 0
		for i = 1, #offsets-1 do
			if memory.readword(offsets[i]+ base)  == map_id then
				results = results + 1
				print("Found map_id at "..fmt(offsets[i] + base,4))
			end
		end 
		print("Found "..results.." map_ids for map "..map_id)
	end
end


function show_chunks_battle_tower()
end

function show_chunks_ug()
end

function debug_script_calling()
	get_internal_pointer()
	display_script_data()
end 

show_script = false
script_executed = false 
update_variables = false
last_script_map = 0 
script_map = -1
param_count = 0


function swap_endian(num)

	return bor(lshift(num%256,8),rshift(num,8));
end

halting_commands = {
	[0x02]=0,[0x1B]=0,[0xB0]=0
}
function scr_cmd_color(cmd)
	if script_commands[cmd] then 
		return script_commands[cmd]['color']
	end 
	return 'red' --script_commands['default']['color']
end 


function get_param_count(cmd) -- incompatible with uneven script params so whatever fuck this
	--if cmd > 716 then return script_commands['default']['param_count'] end 
	if script_commands[cmd] then 
		return script_commands[cmd]['param_count']
	end 
	return script_commands['default']['param_count']
end 

-- figuring out the script execution start address
-- base + 0x3E950 - pointer to heap partition start of script execution

function display_script_data()
	last_script_map = script_map 
	script_map = readword(base + live_struct["map_id_32"])

	script_array_pointer = base + 0x29574 + memory_shift-- this only accounts for normal RETIRE 
	script_array_addr = readdword(script_array_pointer)

	-- temp_script_offs_4_addr = script_array_addr + 4*3 -- 4th index, 4 bytes each (indexing from 0 instead of 1)
	-- temp_script_execution_start_addr = temp_script_offs_4_addr + readdword(temp_script_offs_4_addr) + 0x4-- add the offset to its own address, add 4 bcs jump starts after the address

	if script_array_addr == 0 then 
		script_executed = false
		print_to_screen(143,15,"No script loaded","#00f0f")
		return 
	end 

	if last_script_map ~= script_map then
		script_executed = false
		print_to_screen(143,15,"No script loaded","#00f0f")
		return
	end 


	if not script_executed then
		if script_array_addr ~= 0 then 
			script_executed = true
			update_variables = true
		end 

	end

	if (script_executed and update_variables) then
		script_offs_4_addr = script_array_addr + 4*3
		script_offs_4 = readdword(script_offs_4_addr)
		if (readword(base + live_struct["map_id_32"]) == 332 or readword(base + live_struct["map_id_32"]) == 333) and (script_offs_4 == 0x4652) then 
			script_offs_4 = 0x5544 -- this is a hack because the header gets overwritten after 1 frame, so we need to manually set it to the correct value
		end
		script_execution_start_addr =script_offs_4_addr + script_offs_4 + 0x4
		show_script = true
		update_variables = false 
	end 

	if show_script then 
		print_to_screen(143,15,"Next Command:\n    0x"..fmt(next_opcode_addr,8),"#00f0f")
		print_to_screen(143,35,"Script Data:","#00f0f")
		print_to_screen(153,45,"Array:  0x"..fmt(script_array_addr,0),"#00f0f")
		print_to_screen(153,55,"Offset: 0x"..fmt(script_offs_4,0),"#00f0f")
		print_to_screen(153,65,"Exec:   0x"..fmt(script_execution_start_addr,0),"#00f0f")
		print_to_screen(153,75,"RelExe: 0x"..fmt(script_execution_start_addr - base,0),"#00f0f")
		show_script_memory()
	else
		print_to_screen(143,15,"No script loaded","#00f0f")
	end 
	
end 

function get_internal_pointer()
	opcode_pointer = base + script_execution_struct["opcode_pointer"] + memory_shift
	next_opcode_addr = readdword(opcode_pointer)
	-- opcode = readword(next_opcode_addr-2)
	-- if next_opcode_addr%2 == 1 then 
	-- 	higher_byte = band(readword(next_opcode_addr),0xFF)
	-- 	lower_byte = rshift(readword(next_opcode_addr-2),8)
	-- 	opcode = bor(lshift(higher_byte,8),lower_byte)
	-- end 
	--print_to_screen(143,185,"Pointer addr:\n    "..fmt(opcode_pointer,8),"yellow")
end

function shiftl(value,count)
	if value == 0 then
		return 0
	end 
	return lshift(value,count)

end 

function shiftr(value,count)
	if value == 0 then
		return 0
	end 
	return rshift(value,count)

end 

param_color = "#80A09" --"#AACC44"
addr_color = "#888888"

function readbyte_little_endian(addr) 
	return bor(shiftl(readbyte(addr+1),8),readbyte(addr))
end 

-- function print_to_grid(data,color,index) 
-- 	print_to_screen(46+(index%8)*26,2+math.floor(index/8)*10,data,color,2)
-- end 

function print_addr(addr)
	print_to_screen(1,2+math.floor(index/8)*10,fmt(addr,7),addr_color,2)
end

function increment_index(index,count)
	index = index + count
	if index%8 == 0 then print_addr(cur_sc_addr) end 
	return index
end 

function read_n_bytes(addr,n)
	local value = 0
	for i = 0, n-1 do 
		value = bor(value,shiftl(readbyte(addr+i),8*i))
	end 
	return value
end

function group_param_size(params)
	-- if params is empty, return empty table
	if #params == 0 then 
		return {}
	end

	local grouped_params = {}
	local prev_param = params[1]
	local cur_param_size = 0

	for i=1,#params do 
		if prev_param == params[i] then 
			cur_param_size = cur_param_size + 1
			prev_param = params[i]
		else
			table.insert(grouped_params,cur_param_size)
			cur_param_size = 1
			prev_param = params[i]
		end
	end
	table.insert(grouped_params,cur_param_size)
	return grouped_params
end

function ends_execution(cmd_id,cmd_data)
	if cmd_data == nil then return true end
	if (cmd_id == 0x2) or (cmd_id == 0xB0) then return true end
	return false
end

function update_grid_pos(grid_pos,bytes,address)
	local new_grid_pos = grid_pos
	new_grid_pos.x = new_grid_pos.x + bytes -- + 1 to add a gap
	if new_grid_pos.x >= 14 then 
		new_grid_pos.x = 0
		new_grid_pos.y = new_grid_pos.y + 1
		print_to_screen(0,2+new_grid_pos.y*10,fmt(address,8),"grey",2)
	end
	return new_grid_pos
end

function print_to_grid(grid_pos,bytes,bytecount,color)
	print_to_screen(52+grid_pos.x*13,2+grid_pos.y*10,fmt(bytes,bytecount),color,2)
end 

function is_valid_jump(cmd_id,flag) -- flag is conditional
	if (cmd_id == 0x16 or cmd_id == 0x1A) then return true end 
	if (cmd_id == 0x1C or cmd_id == 0x1D) and (flag == 0x0 or flag == 0x3 or flag == 0x5) then return true end
	-- if (cmd_id == 17) and (notImplemented) then return true end
	-- if (cmd_id == 18) and (notImplemented) then return true end
	if (cmd_id == 0x19) and (flag == readbyte(base + player_struct["facing_dir_32"] + memory_shift)) then return true end
	return false
end 

function is_function_call(cmd_id)
	if (cmd_id == 0x1A) or (cmd_id == 0x1D)  then return true end
	return false
end

function is_return_command(cmd_id)
	if (cmd_id == 0x1B) then return true end
	return false
end

function show_script_memory () -- script dissasembler
	draw_rectangle(0,0,256,200,"#000000ff","#000000ff",2)

	local offset = 0
	local additional_offset = 0
	local return_offset = 0
	local return_additional_offset = 0

	local grid_pos = {x=0,y=0}
	if scroll_vertical > 100000 then return end
	while script_execution_start_addr + offset < script_execution_start_addr + scroll_vertical * 0xE do
		cmd_id = read_n_bytes(script_execution_start_addr + offset + additional_offset,2)
		offset = offset + 2
		cmd_data = script_commands[cmd_id]
		if not ends_execution(cmd_id,cmd_data) then
			params = cmd_data['parameters']
			params_grouped = group_param_size(params)
			param_values_stored = {}

			for i=1,#params_grouped do 
				param_size = params_grouped[i]
				param_value = read_n_bytes(script_execution_start_addr + offset + additional_offset,param_size)
				table.insert(param_values_stored,param_value)
				offset = offset + param_size
			end

			if is_valid_jump(cmd_id,param_values_stored[1]) then 
				if is_function_call(cmd_id) then 
					return_offset = offset
					return_additional_offset = additional_offset
				end 
				additional_offset = additional_offset + param_value
			end

			if is_return_command(cmd_id) and ((return_offset + return_additional_offset) ~= 0) then
				offset = return_offset
				additional_offset = return_additional_offset
				return_offset = 0
				return_additional_offset = 0
			end
		end
	end

	while grid_pos.y < 18 do
		if (grid_pos.y == 0 and grid_pos.x == 0) then print_to_screen(0,2+grid_pos.y*10,fmt(script_execution_start_addr + offset + additional_offset,8),"grey",2) end
		cmd_id = read_n_bytes(script_execution_start_addr + offset + additional_offset,2)
		offset = offset + 2
		print_to_grid(grid_pos,cmd_id,4,scr_cmd_color(cmd_id))
		grid_pos = update_grid_pos(grid_pos,2,script_execution_start_addr + offset + additional_offset) 

		cmd_data = script_commands[cmd_id]
		if not ends_execution(cmd_id,cmd_data) then -- remove 'not' and do break end to stop at end of script

			-- cmd_name = cmd_data['script_command']
			params = cmd_data['parameters']
			params_grouped = group_param_size(params)
			param_values_stored = {}

			for i=1,#params_grouped do 
				param_size = params_grouped[i]
				-- param_id = params[i]
				-- param_name = script_parameters[param_id]
				param_value = read_n_bytes(script_execution_start_addr + offset + additional_offset,param_size)
				table.insert(param_values_stored,param_value)
				offset = offset + param_size
				print_to_grid(grid_pos,param_value,param_size*2,param_color)
				grid_pos = update_grid_pos(grid_pos,param_size,script_execution_start_addr + offset + additional_offset)
			end

			if is_valid_jump(cmd_id,param_values_stored[1]) then 
				if is_function_call(cmd_id) then 
					return_offset = offset
					return_additional_offset = additional_offset
				end
				additional_offset = additional_offset + param_value
				grid_pos.x = 0
				print_to_screen(52+grid_pos.x*13,2+(grid_pos.y+1)*10,"jmp by 0x"..fmt(param_value,0).." to 0x"..fmt(script_execution_start_addr + offset + additional_offset,0),"green",2)
				grid_pos.y = grid_pos.y + 2
				print_to_screen(0,2+grid_pos.y*10,fmt(script_execution_start_addr + offset + additional_offset,8),"grey",2)
			end	
			
			if is_return_command(cmd_id) then 
				if ((return_offset + return_additional_offset) == 0) then
					grid_pos.x = 0
					print_to_screen(52+grid_pos.x*13,2+(grid_pos.y+1)*10,"return to ? (undefined behaviour)","yellow",2)
					grid_pos.y = grid_pos.y + 2
					print_to_screen(0,2+grid_pos.y*10,fmt(script_execution_start_addr + offset + additional_offset,8),"grey",2)
				else 
					offset = return_offset
					additional_offset = return_additional_offset
					grid_pos.x = 0
					print_to_screen(52+grid_pos.x*13,2+(grid_pos.y+1)*10,"return to 0x"..fmt(script_execution_start_addr + offset + additional_offset,0),"yellow",2)
					grid_pos.y = grid_pos.y + 2
					print_to_screen(0,2+grid_pos.y*10,fmt(script_execution_start_addr + offset + additional_offset,8),"grey",2)

					return_offset = 0
					return_additional_offset = 0
				end

			end			

		end

	end
end


scroll_vertical = 0
scroll_horizontal = 0
temp_memory_addr = readdword(lang_data["base_addr"]) + 0x2EAF0
temp_str_memory_addr = fmt(temp_memory_addr,0)

memview_addr = temp_memory_addr - temp_memory_addr%16 

function increment_scroll_vertical()
	scroll_vertical = scroll_vertical - 1
end 

function decrement_scroll_vertical()
	scroll_vertical = scroll_vertical + 1
end 

function increment_scroll_horizontal()
	scroll_horizontal = scroll_horizontal + 1
end 

function decrement_scroll_horizontal()
	scroll_horizontal = scroll_horizontal - 1
end 

function reset_scroll()
	scroll_vertical = 0
	scroll_horizontal = 0
end 

function get_value_color(cmd)
	if cmd > 0x0 then return "#4AAAFF" end--"#00F0F" end
	return script_commands['default']['color']
	-- if script_commands[cmd] then 
	-- 	return script_commands[cmd]['color']
	-- end 
	-- return script_commands['default']['color']
end 

small_endian = true 
function memory_viewer()
	if small_endian then memory_viewer_8() return end
	memory_viewer_16()
end 

function memory_viewer_8()
	-- draw_rectangle(0,0,256,200,"#000000AA","#000001888",2)
	draw_rectangle(0,0,256,200,"#000000CC","#000001888",2)
	for y = 0,15 do
		for x = 0,7 do
			-- script_command = readword(script_execution_start_addr+x*2+y*16)
			current_addr = memview_addr+x*2+y*16 + scroll_vertical*0x10
			value = bor(shiftl(readbyte(current_addr),8),readbyte(current_addr+1))
			color = get_value_color(value)
			print_to_screen(48+x*26,20+y*10,fmt(value,4),color,2)
		end
		print_to_screen(2,20+y*10,fmt(memview_addr+y*16 + scroll_vertical*0x10,7),"#888888",2)
	end  
	for x = 0,15 do
		print_to_screen(48+x*13,8,fmt(x,0),"#888888",2)
		
	end 
	for x = 1,7 do
		gui.drawline(46+(x*26),6,46+(x*26),179,"#444444")
	end 

	print_to_screen(2,8,temp_str_memory_addr,"yellow",2)
	gui.drawline(45,6,45,179,"#888888")
	gui.drawline(0,6,0,179,"#888888")
	gui.drawline(255,6,255,179,"#888888")
	gui.drawline(0,5,256,5,"#888888")
	gui.drawline(0,17,256,17,"#888888")
	gui.drawline(0,179,256,179,"#888888")

end 

function memory_viewer_16()
	-- draw_rectangle(0,0,256,200,"#000000AA","#000001888",2)
	draw_rectangle(0,0,256,200,"#000000CC","#000001888",2)
	for y = 0,15 do
		for x = 0,7 do
			-- script_command = readword(script_execution_start_addr+x*2+y*16)
			current_addr = memview_addr+x*2+y*16 + scroll_vertical*0x10
			value = readword(current_addr)
			color = get_value_color(value)
			print_to_screen(48+x*26,20+y*10,fmt(value,4),color,2)
		end
		print_to_screen(2,20+y*10,fmt(memview_addr+y*16 + scroll_vertical*0x10,7),"#888888",2)
	end  
	for x = 0,15 do
		print_to_screen(48+x*13,8,fmt(x,0),"#888888",2)
		
	end 
	for x = 1,7 do
		gui.drawline(46+(x*26),6,46+(x*26),179,"#444444")
	end 

	print_to_screen(2,8,temp_str_memory_addr,"yellow",2)
	gui.drawline(45,6,45,179,"#888888")
	gui.drawline(0,6,0,179,"#888888")
	gui.drawline(255,6,255,179,"#888888")
	gui.drawline(0,5,256,5,"#888888")
	gui.drawline(0,17,256,17,"#888888")
	gui.drawline(0,179,256,179,"#888888")

end 

selected_ppid = 0

pokemon_struct = {
	BlockA = {
		["Species ID"] = {offset = 0x08, size=0xFFFF},
		["Held Item"] = {offset = 0x0A, size=0xFFFF},
		["TID"] = {offset = 0xC,size=0xFFFF},
		["SID"] = {offset = 0xE,size=0xFFFF},
		["Experience"] = {offset = 0x10,size = 0xFFFF},
		["Friendship"] = {offset = 0x14,size = 0xFF},
		["Ability"] = {offset = 0x15,size = 0xFF},
		["Markings"] = {offset = 0x16,size = 0xFF},
		["Language"] = {offset = 0x17,size = 0xFF},
		["HP EV"] = {offset = 0x18,size = 0xFF},
		["Attack EV"] = {offset = 0x19,size = 0xFF},
		["Defense EV"] = {offset = 0x1A,size = 0xFF},
		["Speed EV"] = {offset = 0x1B,size = 0xFF},
		["Sp. Atk EV"] = {offset = 0x1C,size = 0xFF},
		["Sp. Def EV"] = {offset = 0x1D,size = 0xFF},
		["Cool Contest"] = {offset = 0x1E,size = 0xFF},
		["Beauty Contest"] = {offset = 0x1F,size = 0xFF},
		["Cute Contest"] = {offset = 0x20,size = 0xFF},
		["Smart Contest"] = {offset = 0x21,size = 0xFF},
		["Tough Contest"] = {offset = 0x22,size = 0xFF},
		["Sheen Contest"] = {offset = 0x23,size = 0xFF},
		["Sinnoh Ribbons"] = {offset = 0x24,size= 0xFFFFFF},
		["Move 1"] = {offset = 0x28,size=0xFFFF},
		["Move 2"] = {offset = 0x2A,size=0xFFFF},
		["Move 3"] = {offset = 0x2C,size=0xFFFF},
		["Move 4"] = {offset = 0x2E,size=0xFFFF},
		["Move 1 PP"] = {offset = 0x30,size=0xFF},
		["Move 2 PP"] = {offset = 0x31,size=0xFF},
		["Move 3 PP"] = {offset = 0x32,size=0xFF},
		["Move 4 PP"] = {offset = 0x33,size=0xFF},
		["Move 1 PP Ups"] = {offset = 0x34,size=0xFF},
		["Move 2 PP Ups"] = {offset = 0x35,size=0xFF},
		["Move 3 PP Ups"] = {offset = 0x36,size=0xFF},
		["Move 4 PP Ups"] = {offset = 0x37,size=0xFF},
		["IVs"] = {offset = 0x38,size=0xFFFFFFFC},
		["HP IV"] = {offset = 0x38,size=0x1F},
		["Attack IV"] = {offset = 0x38,size=0x1F,bit=5},
		["Defense IV"] = {offset = 0x38,size=0x1F,bit=10},
		["Speed IV"] = {offset = 0x38,size=0x1F,bit=15},
		["Sp. Atk IV"] = {offset = 0x38,size=0x1F,bit=20},
		["Sp. Def IV"] = {offset = 0x38,size=0x1F,bit=25},
		["Is Egg"] = {offset = 0x38,size=0x1,bit=30},
		["Is Nicknamed"] = {offset = 0x38,size=0x1,bit=31},
		["Hoenn Ribbon Set"] = {offset = 0x3C,size=0xFFFF},
		["Fateful Encounter"] = {offset = 0x40,size=0x1,bit=0},
		["Female"] = {offset = 0x40,size=0x1,bit=1},
		["Gender UK"] = {offset = 0x40,size=0x1,bit=2},
		["Form"] = {offset = 0x40,size=0x4,bit=3},
		["Leaves A-E"] = {offset = 0x41,size=0xF},
		["Leaf Crown"] = {offset = 0x41,size=0x1,bit=5},
		["Platinum Egg Location"] = {offset = 0x44,size=0xFFFF},
		["Platinum Met Location"] = {offset = 0x46,size=0xFFFF}
	},
	BlockB = {

	}

}

function party_viewer()
	ppid = 0


end

menu_choices = {
	OW = {show_void_pos,show_chunks_ow,debug_script_calling,memory_viewer,party_viewer,empty},
	UG = {show_void_pos,show_chunks_ug,memory_viewer},
	BT = {show_void_pos,show_chunks_battle_tower,debug_script_calling,memory_viewer,empty}
	}

function show_menu_choices()
end 

function show_menu(index)
	menu_count = #menu_choices[memory_state]
	menu_id = menu_id%menu_count
	menu_choices[memory_state][index+1]()
end

function auto_sprite_inc()
	sprite = readword(base + player_struct["sprite_id_32"])
	writeword(base + player_struct["sprite_id_32"],sprite+1)
	use_menu(5)
	wait_frames(60)
	press_button("B",4)
end 

function spam_items() 
	for i = base+0x838,base+0x838+2000,4 do
		writedword(i,0x00010002)
	end 
end

function debug_set_map()
	writeword(base + 0x22ADA,187)
end

must_be_even = true

function search_ase_jump() 
	-- loop for event_ids 0 - 0x7CF. start addr is base + 0x29694, event id's are a 32 bit value.
	-- format is base + 0x29694 + event_id*0x4
	print("searching for ase jump")
	for event_id = 0,0x7CF do
		addr = base + 0x29694 + event_id*0x4
		execution_addr = readdword(addr) + addr + 4
		if execution_addr%2 == 0 and must_be_even then
			check_memory_area_for_ase(addr,execution_addr,event_id,0,"live")
			check_memory_area_for_ase(addr,execution_addr,event_id,0xEF574,"saved")
			check_memory_area_for_ase(addr,execution_addr,event_id,0x10F594,"backup")
		end
	end

	for event_id = 0x283D,0xFFFF do
		addr = base + 0x29694 + (event_id-0x283D)*0x4
		execution_addr = readdword(addr) + addr + 4
		if execution_addr%2 == 0 and must_be_even then
			check_memory_area_for_ase(addr,execution_addr,event_id,0,"live")
			check_memory_area_for_ase(addr,execution_addr,event_id,0xEF574,"saved")
			check_memory_area_for_ase(addr,execution_addr,event_id,0x10F594,"backup")
		end
	end
end

function check_memory_area_for_ase(addr,execution_addr,event_id, offset, domain)
	if ((execution_addr >= base + 0x5B18 + offset) and (execution_addr <= base + 0x5B18 + 0x600 + offset)) then
		print("ase jump to: Signature: " .. domain)
		print("found event_id "..fmt(event_id,4).." at addr "..fmt(addr,0).." with execution_addr "..fmt(execution_addr,4))
		print("jump amount: "..fmt(execution_addr - (addr+4),8))
	end
	-- same but for base + 0xA8E4 + offset and base + 0xBC3C + offset, data is pal park
	if ((execution_addr >= base + 0xA8E4 + offset) and (execution_addr <= base + 0xBC3C + offset)) then
		print("ase jump to: Pal Park: " .. domain)
		print("found event_id "..fmt(event_id,4).." at addr "..fmt(addr,0).." with execution_addr "..fmt(execution_addr,4))
	end

	-- saùe but for base + 0x838 + offset and base + 0xFB0 + offset, data is items
	if ((execution_addr >= base + 0x838 + offset) and (execution_addr <= base + 0xFB0 + offset)) then
		print("ase jump to: Items: " .. domain)
		print("found event_id "..fmt(event_id,4).." at addr "..fmt(addr,0).." with execution_addr "..fmt(execution_addr,4))
	end

	-- same but for base + 0x138A + offset and base + 0x138A + 0x80 + offset, data is Dot Artist Bitfield
	if ((execution_addr >= base + 0x138A + offset) and (execution_addr <= base + 0x138A + 0x80 + offset)) then
		print("ase jump to: Dot Artist Bitfield: " .. domain)
		print("found event_id "..fmt(event_id,4).." at addr "..fmt(addr,0).." with execution_addr "..fmt(execution_addr,4))
	end

	-- don't check extra offset here, since hof doesn't get saved in normal save data
	if (offset > 0) then return end

	if ((execution_addr >= base + 0x2EAC4) and (execution_addr <= base + 0x2EBF4)) then
		print("ase jump to: Hall of Fame")
		print("found event_id "..fmt(event_id,4).." at addr "..fmt(addr,0).." with execution_addr "..fmt(execution_addr,4))
	end
end

key_configuration = {
	search_ase_jump = {"shift","X"},
	setup_search_collect = {"shift","D"},
	search_ase_manip = {"shift","S"},
	toggle_wtw_state = {"W"},
	toggle_menu_state = {"Q"},
	toggle_map_editing = {"M"},
	toggle_teleport_editing = {"J"},
	toggle_hexview = {"control","H"},
	toggle_memory_addr_editing = {"shift","N"},
	toggle_matrix_mode = {"control","V"},
	auto_movement = {"shift","control","M"},
	increment_menu = {"shift","V"},
	auto_calculate = {"shift","control","C"},
	--auto_sprite_inc = {"B"},
	teleport_up = {"shift","up"},
	teleport_left = {"shift","left"},
	teleport_down = {"shift","down"},
	teleport_right = {"shift","right"},
	toggle_tile_view = {"shift","T"},
	toggle_player_pos = {"shift","P"},
	toggle_bounding_view = {"shift","I"},
	toggle_grid = {"shift","G"},
	toggle_loadlines = {"shift","L"},
	toggle_maplines = {"shift","K"},
	toggle_mapmodellines = {"shift","H"},
	toggle_load_calculations = {"L","C"},
	toggle_debug_tile_print = {"T","C"},
	write_image_to_calculator = {"S","C"},
	reset_scroll = {"shift","space"},
	--spam_items = {"control","I"}
	debug_set_map = {"control","G"}
}

key_configuration_cont = {
	increment_scroll_vertical = {"control","up"},
	decrement_scroll_vertical = {"control","down"},
	increment_scroll_horizontal = {"control","right"},
	decrement_scroll_horizontal = {"control","left"},

}

function run_functions_on_keypress()
	for funct,config_keys in pairs(key_configuration) do
		if check_keys(config_keys) == #config_keys then
			loadstring(funct.."()")()
		end 
	end
end

function run_continuous_function_on_keypress()
	for funct,config_keys in pairs(key_configuration_cont) do
		if check_keys_continuous(config_keys) == #config_keys then
			loadstring(funct.."()")()
		end 
	end
end 


option_x = 20
option_y = 20

function_options = {
	{show_void_pos,"Void viewer"},
	{show_chunks_ow,"Chunks viewer"}
}

function display_options()
	draw_rectangle(option_x,option_y,100,60)
	if is_clicking_area(option_x,option_y-200,100,60) then clicking_option_menu = true end
	for i = 0,#function_options-1 do
		print_to_screen(option_x + 5,option_y + 18 + i*10,function_options[i+1][2])
	end 
end 

function run_functions()
	if map_editing then change_map_id() end 
	if memory_editing then change_memory_addr() end 
	if teleport_editing then change_teleport_amount() end 
end 

function reset_for_base(base_end) 
	if base%0x100 ~= base_end then
		if	base ~= 0 then 
			joy.L = true
			joy.R = true 
			joy.select = true
			joy.start = true
			joypad.set(joy)
			joy = {}
		end 
			else print("Base value found!")
	end 
end 

function show_gui()
	show_boundary_lines()
	show_menu(menu_id)

	print_to_screen(5,15,"Base:"..fmt(base,8),'yellow')
	show_player_data()
end

function main_gui()
	base = readdword(lang_data["base_addr"]) -- check base every loop in case of reset
	--base = readdword(readdword(0x2002848)-4)
	memory_state = get_memory_state() -- check for underground,battletower or overworld state (add: intro?)
	memory_shift = data_table["memory_shift"][memory_state] -- get memory shift based on state

	screen_y = set_screen_params(memory_state)
	
	-- main 
	if bounding_view then 
		show_bounding_boxes(memory_state)
	end 
	show_gui()

	-- print_to_screen(5,10,fmt(base,7),"yellow")
	-- print_to_screen(5,20,memory_state,"red")
	-- print_to_screen(5,30,fmt(memory_shift,4),"red")

	-- display_options()

	-- input functions
	get_keys()
	get_joy()
	get_stylus()
	run_functions_on_keypress()
	run_continuous_function_on_keypress()
	run_functions()

	-- reset game to specific base if necessary
	--reset_for_base(0x60)
end


function main_bruteforce()
	main_gui()
	-- print("Starting brute force search...")

    -- -- Call the brute_force_search function to perform the search
    -- brute_force_search()

    -- -- Print a message to indicate the completion of the brute force process
    -- print("Brute force search completed. Results saved to brute_force_results.lua.")
	-- return
end

gui.register(main_bruteforce)



