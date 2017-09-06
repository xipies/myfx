
_addon.author   = 'Eleven Pies';
_addon.name     = 'MyEffects';
_addon.version  = '2.0.0';

require 'common'
require 'mob.mobinfo'

local lor_packets = require 'lor.lor_packets_mod'

local tiers = { };
tiers[0] = '';
tiers[1] = ' I';
tiers[2] = ' II';
tiers[3] = ' III';
tiers[4] = ' IV';
tiers[5] = ' V';
tiers[6] = ' VI';
tiers[7] = ' VII';
tiers[8] = ' VIII';
tiers[9] = ' IX';
tiers[10] = ' X';

---------------------------------------------------------------------------------------------------
-- desc: MyEffects global table.
---------------------------------------------------------------------------------------------------
local statuseffects = { };

local emptyStatusInfo = { id = 0, name = 'EMPTY_STATUS' };

-- Server side modifiers, client does not know about these
local modList = { };
modList[54] = 'Fire Resistance';
modList[55] = 'Ice Resistance';
modList[56] = 'Wind Resistance';
modList[57] = 'Earth Resistance';
modList[58] = 'Thunder Resistance';
modList[59] = 'Water Resistance';

local mobStatus = { };
mobStatus[ 6] = 'KO';
mobStatus[20] = 'KO';

local defaultMobStatus = 'UNKNOWN';

-- TODO: Other spells
-- Mapping for cases where no effect message is received (e.g., Dia/Bio) or where effect when receiving/wearing is different (e.g., Lullaby)
-- Unofficial effect for ninjutsu elemental debuffs, using DSP mod ID, see DSP status.lua
local spellEffectMap = { };
spellEffectMap[ 23] = { messageId =   2, aoeMessageId = 264, spellId =  23, spellName = 'Dia',           effectType = 0x01, effectId = 134, effectName = 'Dia'                };
spellEffectMap[ 24] = { messageId =   2, aoeMessageId = 264, spellId =  24, spellName = 'Dia II',        effectType = 0x01, effectId = 134, effectName = 'Dia'                };
spellEffectMap[ 25] = { messageId =   2, aoeMessageId = 264, spellId =  25, spellName = 'Dia III',       effectType = 0x01, effectId = 134, effectName = 'Dia'                };
spellEffectMap[ 33] = { messageId =   2, aoeMessageId = 264, spellId =  33, spellName = 'Diaga',         effectType = 0x01, effectId = 134, effectName = 'Dia'                };
spellEffectMap[230] = { messageId =   2, aoeMessageId = 264, spellId = 230, spellName = 'Bio',           effectType = 0x01, effectId = 135, effectName = 'Bio'                };
spellEffectMap[231] = { messageId =   2, aoeMessageId = 264, spellId = 231, spellName = 'Bio II',        effectType = 0x01, effectId = 135, effectName = 'Bio'                };
spellEffectMap[232] = { messageId =   2, aoeMessageId = 264, spellId = 232, spellName = 'Bio III',       effectType = 0x01, effectId = 135, effectName = 'Bio'                };
spellEffectMap[242] = { messageId = 533, aoeMessageId =   0, spellId = 242, spellName = 'Absorb-ACC',    effectType = 0x01, effectId = 146, effectName = 'Accuracy Down'      }; -- NOTE: Possible DSP bug, other absorb spells return debuff effect instead of buff effect
spellEffectMap[278] = { messageId =   2, aoeMessageId = 264, spellId = 278, spellName = 'Geohelix',      effectType = 0x01, effectId = 186, effectName = 'Helix'              };
spellEffectMap[279] = { messageId =   2, aoeMessageId = 264, spellId = 279, spellName = 'Hydrohelix',    effectType = 0x01, effectId = 186, effectName = 'Helix'              };
spellEffectMap[280] = { messageId =   2, aoeMessageId = 264, spellId = 280, spellName = 'Anemohelix',    effectType = 0x01, effectId = 186, effectName = 'Helix'              };
spellEffectMap[281] = { messageId =   2, aoeMessageId = 264, spellId = 281, spellName = 'Pyrohelix',     effectType = 0x01, effectId = 186, effectName = 'Helix'              };
spellEffectMap[282] = { messageId =   2, aoeMessageId = 264, spellId = 282, spellName = 'Cryohelix',     effectType = 0x01, effectId = 186, effectName = 'Helix'              };
spellEffectMap[283] = { messageId =   2, aoeMessageId = 264, spellId = 283, spellName = 'Ionohelix',     effectType = 0x01, effectId = 186, effectName = 'Helix'              };
spellEffectMap[284] = { messageId =   2, aoeMessageId = 264, spellId = 284, spellName = 'Noctohelix',    effectType = 0x01, effectId = 186, effectName = 'Helix'              };
spellEffectMap[285] = { messageId =   2, aoeMessageId = 264, spellId = 285, spellName = 'Luminohelix',   effectType = 0x01, effectId = 186, effectName = 'Helix'              };
spellEffectMap[320] = { messageId =   2, aoeMessageId = 264, spellId = 320, spellName = 'Katon: Ichi',   effectType = 0x02, effectId =  59, effectName = 'Water Resistance'   };
spellEffectMap[321] = { messageId =   2, aoeMessageId = 264, spellId = 321, spellName = 'Katon: Ni',     effectType = 0x02, effectId =  59, effectName = 'Water Resistance'   };
spellEffectMap[322] = { messageId =   2, aoeMessageId = 264, spellId = 322, spellName = 'Katon: San',    effectType = 0x02, effectId =  59, effectName = 'Water Resistance'   };
spellEffectMap[323] = { messageId =   2, aoeMessageId = 264, spellId = 323, spellName = 'Hyoton: Ichi',  effectType = 0x02, effectId =  54, effectName = 'Fire Resistance'    };
spellEffectMap[324] = { messageId =   2, aoeMessageId = 264, spellId = 324, spellName = 'Hyoton: Ni',    effectType = 0x02, effectId =  54, effectName = 'Fire Resistance'    };
spellEffectMap[325] = { messageId =   2, aoeMessageId = 264, spellId = 325, spellName = 'Hyoton: San',   effectType = 0x02, effectId =  54, effectName = 'Fire Resistance'    };
spellEffectMap[326] = { messageId =   2, aoeMessageId = 264, spellId = 326, spellName = 'Huton: Ichi',   effectType = 0x02, effectId =  55, effectName = 'Ice Resistance'     };
spellEffectMap[327] = { messageId =   2, aoeMessageId = 264, spellId = 327, spellName = 'Huton: Ni',     effectType = 0x02, effectId =  55, effectName = 'Ice Resistance'     };
spellEffectMap[328] = { messageId =   2, aoeMessageId = 264, spellId = 328, spellName = 'Huton: San',    effectType = 0x02, effectId =  55, effectName = 'Ice Resistance'     };
spellEffectMap[329] = { messageId =   2, aoeMessageId = 264, spellId = 329, spellName = 'Doton: Ichi',   effectType = 0x02, effectId =  56, effectName = 'Wind Resistance'    };
spellEffectMap[330] = { messageId =   2, aoeMessageId = 264, spellId = 330, spellName = 'Doton: Ni',     effectType = 0x02, effectId =  56, effectName = 'Wind Resistance'    };
spellEffectMap[331] = { messageId =   2, aoeMessageId = 264, spellId = 331, spellName = 'Doton: San',    effectType = 0x02, effectId =  56, effectName = 'Wind Resistance'    };
spellEffectMap[332] = { messageId =   2, aoeMessageId = 264, spellId = 332, spellName = 'Raiton: Ichi',  effectType = 0x02, effectId =  57, effectName = 'Earth Resistance'   };
spellEffectMap[333] = { messageId =   2, aoeMessageId = 264, spellId = 333, spellName = 'Raiton: Ni',    effectType = 0x02, effectId =  57, effectName = 'Earth Resistance'   };
spellEffectMap[334] = { messageId =   2, aoeMessageId = 264, spellId = 334, spellName = 'Raiton: San',   effectType = 0x02, effectId =  57, effectName = 'Earth Resistance'   };
spellEffectMap[335] = { messageId =   2, aoeMessageId = 264, spellId = 335, spellName = 'Suiton: Ichi',  effectType = 0x02, effectId =  58, effectName = 'Thunder Resistance' };
spellEffectMap[336] = { messageId =   2, aoeMessageId = 264, spellId = 336, spellName = 'Suiton: Ni',    effectType = 0x02, effectId =  58, effectName = 'Thunder Resistance' };
spellEffectMap[337] = { messageId =   2, aoeMessageId = 264, spellId = 337, spellName = 'Suiton: San',   effectType = 0x02, effectId =  58, effectName = 'Thunder Resistance' };
spellEffectMap[376] = { messageId = 237, aoeMessageId = 278, spellId = 376, spellName = 'Horde Lullaby', effectType = 0x01, effectId =   2, effectName = 'sleep'              };
spellEffectMap[463] = { messageId = 237, aoeMessageId = 278, spellId = 463, spellName = 'Foe Lullaby',   effectType = 0x01, effectId =   2, effectName = 'sleep'              };

local jobAbilityEffectMap = { };
jobAbilityEffectMap[36] = { messageId = 120, aoeMessageId = 0, jobAbilityId = 36, jobAbilityName = 'Focus', effectType = 0x01, effectId = 59, effectName = 'Focus' };
jobAbilityEffectMap[37] = { messageId = 121, aoeMessageId = 0, jobAbilityId = 37, jobAbilityName = 'Dodge', effectType = 0x01, effectId = 60, effectName = 'Dodge' };
jobAbilityEffectMap[39] = { messageId = 116, aoeMessageId = 0, jobAbilityId = 39, jobAbilityName = 'Boost', effectType = 0x01, effectId = 45, effectName = 'Boost' };

-- Does not appear to be in "add_efct"
-- TODO: Try handling char update packet
local mobAbilityEffectMap = { };
----mobAbilityEffectMap[617] = { messageId = 185, aoeMessageId = 264, mobAbilityId = 617, mobAbilityName = 'Feather Storm', effectType = 0x01, effectId =  3, effectName = 'poison' };
----mobAbilityEffectMap[620] = { messageId = 185, aoeMessageId = 264, mobAbilityId = 620, mobAbilityName = 'Sweep',         effectType = 0x01, effectId = 10, effectName = 'stun' };

local danceEffectMap = { };
danceEffectMap[184] = { messageId = 100, aoeMessageId = 0, danceId = 184, danceName = 'Drain Samba',    effectType = 0x01, effectId = 368, effectName = 'Drain Samba' };
danceEffectMap[185] = { messageId = 100, aoeMessageId = 0, danceId = 185, danceName = 'Drain Samba II', effectType = 0x01, effectId = 368, effectName = 'Drain Samba' };

-- TODO: Other spells
-- TODO: Base and max durations
local spellDurations = { };
spellDurations[ 23] =  60; -- Dia
spellDurations[ 24] = 120; -- Dia II
spellDurations[ 25] = 150; -- Dia III (max merits) (30s-150s)
spellDurations[ 33] =  60; -- Diaga
spellDurations[ 56] = 120; -- Slow
spellDurations[ 58] = 120; -- Paralyze
spellDurations[ 59] = 120; -- Silence
spellDurations[ 79] = 180; -- Slow II
spellDurations[ 80] = 120; -- Paralyze II
spellDurations[ 98] =  90; -- Repose
spellDurations[112] =  12; -- Flash
spellDurations[216] = 120; -- Gravity
spellDurations[220] =  30; -- Poison
spellDurations[221] = 120; -- Poison II
spellDurations[225] = 120; -- Poisonga
spellDurations[230] =  60; -- Bio
spellDurations[231] = 120; -- Bio II
spellDurations[232] = 150; -- Bio III (max merits) (30s-150s)
spellDurations[235] = 120; -- Burn
spellDurations[236] = 120; -- Frost
spellDurations[237] = 120; -- Choke
spellDurations[238] = 120; -- Rasp
spellDurations[239] = 120; -- Shock
spellDurations[240] = 120; -- Drown
spellDurations[242] =  72; -- Absorb-ACC
spellDurations[252] =   5; -- Stun
spellDurations[253] =  60; -- Sleep
spellDurations[254] = 180; -- Blind
spellDurations[258] =  60; -- Bind
spellDurations[259] =  90; -- Sleep II
spellDurations[266] =  72; -- Absorb-STR
spellDurations[267] =  72; -- Absorb-DEX
spellDurations[268] =  72; -- Absorb-VIT
spellDurations[269] =  72; -- Absorb-AGI
spellDurations[270] =  72; -- Absorb-INT
spellDurations[271] =  72; -- Absorb-MND
spellDurations[272] =  72; -- Absorb-CHR
spellDurations[273] =  60; -- Sleepga
spellDurations[274] =  90; -- Sleepga II
spellDurations[276] = 180; -- Blind II
spellDurations[278] =  90; -- Geohelix
spellDurations[279] =  90; -- Hydrohelix
spellDurations[280] =  90; -- Anemohelix
spellDurations[281] =  90; -- Pyrohelix
spellDurations[282] =  90; -- Cryohelix
spellDurations[283] =  90; -- Ionohelix
spellDurations[284] =  90; -- Noctohelix
spellDurations[285] =  90; -- Luminohelix
spellDurations[320] = 25; -- Katon: Ichi (max merits) (15s-25s)
spellDurations[321] = 25; -- Katon: Ni (max merits) (15s-25s)
spellDurations[322] = 25; -- Katon: San (max merits) (15s-25s)
spellDurations[323] = 25; -- Hyoton: Ichi (max merits) (15s-25s)
spellDurations[324] = 25; -- Hyoton: Ni (max merits) (15s-25s)
spellDurations[325] = 25; -- Hyoton: San (max merits) (15s-25s)
spellDurations[326] = 25; -- Huton: Ichi (max merits) (15s-25s)
spellDurations[327] = 25; -- Huton: Ni (max merits) (15s-25s)
spellDurations[328] = 25; -- Huton: San (max merits) (15s-25s)
spellDurations[329] = 25; -- Doton: Ichi (max merits) (15s-25s)
spellDurations[330] = 25; -- Doton: Ni (max merits) (15s-25s)
spellDurations[331] = 25; -- Doton: San (max merits) (15s-25s)
spellDurations[332] = 25; -- Raiton: Ichi (max merits) (15s-25s)
spellDurations[333] = 25; -- Raiton: Ni (max merits) (15s-25s)
spellDurations[334] = 25; -- Raiton: San (max merits) (15s-25s)
spellDurations[335] = 25; -- Suiton: Ichi (max merits) (15s-25s)
spellDurations[336] = 25; -- Suiton: Ni (max merits) (15s-25s)
spellDurations[337] = 25; -- Suiton: San (max merits) (15s-25s)
spellDurations[341] = 180; -- Jubaku: Ichi
spellDurations[344] = 180; -- Hojo: Ichi
spellDurations[345] = 300; -- Hojo: Ni
spellDurations[347] = 180; -- Kurayami: Ichi
spellDurations[348] = 300; -- Kurayami: Ni
spellDurations[350] =  60; -- Dokumori: Ichi
spellDurations[368] =  63; -- Foe Requiem
spellDurations[369] =  79; -- Foe Requiem II
spellDurations[370] =  95; -- Foe Requiem III
spellDurations[371] = 111; -- Foe Requiem IV
spellDurations[372] = 127; -- Foe Requiem V
spellDurations[373] = 143; -- Foe Requiem VI
spellDurations[376] =  30; -- Horde Lullaby
spellDurations[378] = 120; -- Armys Paeon
spellDurations[379] = 120; -- Armys Paeon II
spellDurations[380] = 120; -- Armys Paeon III
spellDurations[381] = 120; -- Armys Paeon IV
spellDurations[382] = 120; -- Armys Paeon V
spellDurations[383] = 120; -- Armys Paeon VI
spellDurations[386] = 120; -- Mages Ballad
spellDurations[387] = 120; -- Mages Ballad II
spellDurations[388] = 120; -- Mages Ballad III
spellDurations[389] = 120; -- Knights Minne
spellDurations[390] = 120; -- Knights Minne II
spellDurations[391] = 120; -- Knights Minne III
spellDurations[392] = 120; -- Knights Minne IV
spellDurations[393] = 120; -- Knights Minne V
spellDurations[394] = 120; -- Valor Minuet
spellDurations[395] = 120; -- Valor Minuet II
spellDurations[396] = 120; -- Valor Minuet III
spellDurations[397] = 120; -- Valor Minuet IV
spellDurations[398] = 120; -- Valor Minuet V
spellDurations[399] = 120; -- Sword Madrigal
spellDurations[400] = 120; -- Blade Madrigal
spellDurations[401] = 120; -- Hunters Prelude
spellDurations[402] = 120; -- Archers Prelude
spellDurations[403] = 120; -- Sheepfoe Mambo
spellDurations[404] = 120; -- Dragonfoe Mambo
spellDurations[419] = 120; -- Advancing March
spellDurations[420] = 120; -- Victory March
spellDurations[421] = 120; -- Battlefield Elegy
spellDurations[422] = 180; -- Carnage Elegy
spellDurations[454] =  60; -- Fire Threnody
spellDurations[455] =  60; -- Ice Threnody
spellDurations[456] =  60; -- Wind Threnody
spellDurations[457] =  60; -- Earth Threnody
spellDurations[458] =  60; -- Lightning Threnody
spellDurations[459] =  60; -- Water Threnody
spellDurations[460] =  60; -- Light Threnody
spellDurations[461] =  60; -- Dark Threnody
spellDurations[463] =  30; -- Foe Lullaby
spellDurations[466] =  30; -- Maidens Virelai
spellDurations[841] = 120; -- Distract
spellDurations[843] = 120; -- Frazzle

local jobAbilityDurations = { };
jobAbilityDurations[36] = 120; -- Focus
jobAbilityDurations[37] = 120; -- Dodge
jobAbilityDurations[39] = 180; -- Boost

local mobAbilityDurations = { };

local danceDurations = { };
danceDurations[184] = 120; -- Drain Samba
danceDurations[185] = 120; -- Drain Samba II

-- Lower the default duration to prevent unhandled spells (e.g., mob buffs) showing too much
local defaultUnknownDurations = 0;
local defaultBasicDurations = 0;
local defaultSpellDurations = 0;
local defaultJobAbilityDurations = 0;
local defaultMobAbilityDurations = 0;
local defaultDanceDurations = 0;

local defaultUnknownMessageDefinitions = { hasSpell = false, resolveTarget = false, showDecayTime = false, useDuration = false };

local basicMessageDefinitions = { };

basicMessageDefinitions[  6] = { hasSpell = false, resolveTarget = true, showDecayTime = false, useDuration = false }; -- The <player> defeats <target>.
basicMessageDefinitions[ 20] = { hasSpell = false, resolveTarget = true, showDecayTime = false, useDuration = false }; -- <target> falls to the ground.
basicMessageDefinitions[206] = { hasSpell = false, resolveTarget = true, showDecayTime = true,  useDuration = false }; -- <target>'s <param> effect wears off.

local defaultBasicMessageDefinitions = { hasSpell = false, resolveTarget = false, showDecayTime = false, useDuration = false };

local spellMessageDefinitions = { };
spellMessageDefinitions[  2] = { hasSpell = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- The <player> casts <spell>. <target> takes .. points of damage.
spellMessageDefinitions[230] = { hasSpell = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- The <player> casts <spell>. <target> gains the effect of <spell>.
spellMessageDefinitions[236] = { hasSpell = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- The <player> casts <spell>. <target> is <effect>.
spellMessageDefinitions[237] = { hasSpell = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- The <player> casts <spell>. <target> receives the effect of <spell>.
spellMessageDefinitions[264] = { hasSpell = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- <target> takes .. points of damage.
spellMessageDefinitions[266] = { hasSpell = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- <target> gains the effect of <spell>.
spellMessageDefinitions[277] = { hasSpell = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- <target> is <effect>.
spellMessageDefinitions[278] = { hasSpell = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- <target> receives the effect of <spell>.
spellMessageDefinitions[329] = { hasSpell = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- The <player> casts <spell>. <target>'s STR is drained.
spellMessageDefinitions[330] = { hasSpell = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- The <player> casts <spell>. <target>'s DEX is drained.
spellMessageDefinitions[331] = { hasSpell = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- The <player> casts <spell>. <target>'s VIT is drained.
spellMessageDefinitions[332] = { hasSpell = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- The <player> casts <spell>. <target>'s AGI is drained.
spellMessageDefinitions[333] = { hasSpell = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- The <player> casts <spell>. <target>'s INT is drained.
spellMessageDefinitions[334] = { hasSpell = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- The <player> casts <spell>. <target>'s MND is drained.
spellMessageDefinitions[335] = { hasSpell = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- The <player> casts <spell>. <target>'s CHR is drained.
spellMessageDefinitions[341] = { hasSpell = false, resolveTarget = true, showDecayTime = true, useDuration = false }; -- The <player> casts <spell>. <target>'s <effect> effect disappears!
spellMessageDefinitions[533] = { hasSpell = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- The <player> casts <spell>. <target>'s Accuracy is drained.

local defaultSpellMessageDefinitions = { hasSpell = false, resolveTarget = false, showDecayTime = false, useDuration = false };

local jobAbilityMessageDefinitions = { };
jobAbilityMessageDefinitions[116] = { hasJobAbility = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- The <player> uses .. <target>'s attacks are enhanced.
jobAbilityMessageDefinitions[120] = { hasJobAbility = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- The <player> uses .. <target>'s accuracy is enhanced.
jobAbilityMessageDefinitions[121] = { hasJobAbility = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- The <player> uses .. <target>'s evasion is enhanced.

local defaultJobAbilityMessageDefinitions = { hasJobAbility = false, resolveTarget = false, showDecayTime = false, useDuration = false };

local mobAbilityMessageDefinitions = { };
mobAbilityMessageDefinitions[159] = { hasMobAbility = false, resolveTarget = true, showDecayTime = true, useDuration = false }; -- The <player> uses .. <target>'s <effect> effect disappears!
mobAbilityMessageDefinitions[185] = { hasMobAbility = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- The <player> uses .. <target> takes .. points of damage.
mobAbilityMessageDefinitions[186] = { hasMobAbility = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- The <player> uses .. <target> gains the effect of <effect>.
mobAbilityMessageDefinitions[264] = { hasMobAbility = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- <target> takes .. points of damage.
mobAbilityMessageDefinitions[266] = { hasMobAbility = true,  resolveTarget = true, showDecayTime = true, useDuration = true  }; -- <target> gains the effect of <effect>.

local defaultMobAbilityMessageDefinitions = { hasMobAbility = false, resolveTarget = false, showDecayTime = false, useDuration = false };

local danceMessageDefinitions = { };
danceMessageDefinitions[100] = { hasDance = true, resolveTarget = false, showDecayTime = true, useDuration = true };

local defaultDanceMessageDefinitions = { hasDance = false, resolveTarget = false, showDecayTime = false, useDuration = false };

local spellActorTierDefinitions = { };

-- TODO: Other songs
-- Actor/Tier per spell
-- Used for song being sung
-- Lullaby is not handled this way
spellActorTierDefinitions[368] = { hasActorTier = true, tier = 1 }; -- Foe Requiem
spellActorTierDefinitions[369] = { hasActorTier = true, tier = 2 }; -- Foe Requiem II
spellActorTierDefinitions[370] = { hasActorTier = true, tier = 3 }; -- Foe Requiem III
spellActorTierDefinitions[371] = { hasActorTier = true, tier = 4 }; -- Foe Requiem IV
spellActorTierDefinitions[372] = { hasActorTier = true, tier = 5 }; -- Foe Requiem V
spellActorTierDefinitions[373] = { hasActorTier = true, tier = 6 }; -- Foe Requiem VI
spellActorTierDefinitions[378] = { hasActorTier = true, tier = 1 }; -- Armys Paeon
spellActorTierDefinitions[379] = { hasActorTier = true, tier = 2 }; -- Armys Paeon II
spellActorTierDefinitions[380] = { hasActorTier = true, tier = 3 }; -- Armys Paeon III
spellActorTierDefinitions[381] = { hasActorTier = true, tier = 4 }; -- Armys Paeon IV
spellActorTierDefinitions[382] = { hasActorTier = true, tier = 5 }; -- Armys Paeon V
spellActorTierDefinitions[383] = { hasActorTier = true, tier = 6 }; -- Armys Paeon VI
spellActorTierDefinitions[386] = { hasActorTier = true, tier = 1 }; -- Mages Ballad
spellActorTierDefinitions[387] = { hasActorTier = true, tier = 2 }; -- Mages Ballad II
spellActorTierDefinitions[388] = { hasActorTier = true, tier = 3 }; -- Mages Ballad III
spellActorTierDefinitions[389] = { hasActorTier = true, tier = 1 }; -- Knights Minne
spellActorTierDefinitions[390] = { hasActorTier = true, tier = 2 }; -- Knights Minne II
spellActorTierDefinitions[391] = { hasActorTier = true, tier = 3 }; -- Knights Minne III
spellActorTierDefinitions[392] = { hasActorTier = true, tier = 4 }; -- Knights Minne IV
spellActorTierDefinitions[393] = { hasActorTier = true, tier = 5 }; -- Knights Minne V
spellActorTierDefinitions[394] = { hasActorTier = true, tier = 1 }; -- Valor Minuet
spellActorTierDefinitions[395] = { hasActorTier = true, tier = 2 }; -- Valor Minuet II
spellActorTierDefinitions[396] = { hasActorTier = true, tier = 3 }; -- Valor Minuet III
spellActorTierDefinitions[397] = { hasActorTier = true, tier = 4 }; -- Valor Minuet IV
spellActorTierDefinitions[398] = { hasActorTier = true, tier = 5 }; -- Valor Minuet V
spellActorTierDefinitions[399] = { hasActorTier = true, tier = 1 }; -- Sword Madrigal
spellActorTierDefinitions[400] = { hasActorTier = true, tier = 2 }; -- Blade Madrigal
spellActorTierDefinitions[401] = { hasActorTier = true, tier = 1 }; -- Hunters Prelude
spellActorTierDefinitions[402] = { hasActorTier = true, tier = 2 }; -- Archers Prelude
spellActorTierDefinitions[403] = { hasActorTier = true, tier = 1 }; -- Sheepfoe Mambo
spellActorTierDefinitions[404] = { hasActorTier = true, tier = 2 }; -- Dragonfoe Mambo
spellActorTierDefinitions[419] = { hasActorTier = true, tier = 1 }; -- Advancing March
spellActorTierDefinitions[420] = { hasActorTier = true, tier = 2 }; -- Victory March
spellActorTierDefinitions[421] = { hasActorTier = true, tier = 1 }; -- Battlefield Elegy
spellActorTierDefinitions[422] = { hasActorTier = true, tier = 2 }; -- Carnage Elegy
spellActorTierDefinitions[454] = { hasActorTier = true, tier = 1 }; -- Fire Threnody
spellActorTierDefinitions[455] = { hasActorTier = true, tier = 1 }; -- Ice Threnody
spellActorTierDefinitions[456] = { hasActorTier = true, tier = 1 }; -- Wind Threnody
spellActorTierDefinitions[457] = { hasActorTier = true, tier = 1 }; -- Earth Threnody
spellActorTierDefinitions[458] = { hasActorTier = true, tier = 1 }; -- Lightning Threnody
spellActorTierDefinitions[459] = { hasActorTier = true, tier = 1 }; -- Water Threnody
spellActorTierDefinitions[460] = { hasActorTier = true, tier = 1 }; -- Light Threnody
spellActorTierDefinitions[461] = { hasActorTier = true, tier = 1 }; -- Dark Threnody

-- Actor/Tier per status effect
-- Used for effect wearing off
local statusActorTierDefinitions = { };

statusActorTierDefinitions[192] = { hasActorTier = true, tier = 0 }; -- Requiem
statusActorTierDefinitions[193] = { hasActorTier = true, tier = 0 }; -- Lullaby
statusActorTierDefinitions[194] = { hasActorTier = true, tier = 0 }; -- Elegy
statusActorTierDefinitions[195] = { hasActorTier = true, tier = 0 }; -- Paeon
statusActorTierDefinitions[196] = { hasActorTier = true, tier = 0 }; -- Ballad
statusActorTierDefinitions[197] = { hasActorTier = true, tier = 0 }; -- Minne
statusActorTierDefinitions[198] = { hasActorTier = true, tier = 0 }; -- Minuet
statusActorTierDefinitions[199] = { hasActorTier = true, tier = 0 }; -- Madrigal
statusActorTierDefinitions[200] = { hasActorTier = true, tier = 0 }; -- Prelude
statusActorTierDefinitions[201] = { hasActorTier = true, tier = 0 }; -- Mambo
statusActorTierDefinitions[202] = { hasActorTier = true, tier = 0 }; -- Aubade
statusActorTierDefinitions[203] = { hasActorTier = true, tier = 0 }; -- Pastoral
statusActorTierDefinitions[204] = { hasActorTier = true, tier = 0 }; -- Hum
statusActorTierDefinitions[205] = { hasActorTier = true, tier = 0 }; -- Fantasia
statusActorTierDefinitions[206] = { hasActorTier = true, tier = 0 }; -- Operetta
statusActorTierDefinitions[207] = { hasActorTier = true, tier = 0 }; -- Capriccio
statusActorTierDefinitions[208] = { hasActorTier = true, tier = 0 }; -- Serenade
statusActorTierDefinitions[209] = { hasActorTier = true, tier = 0 }; -- Round
statusActorTierDefinitions[210] = { hasActorTier = true, tier = 0 }; -- Gavotte
statusActorTierDefinitions[211] = { hasActorTier = true, tier = 0 }; -- Fugue
statusActorTierDefinitions[212] = { hasActorTier = true, tier = 0 }; -- Rhapsody
statusActorTierDefinitions[213] = { hasActorTier = true, tier = 0 }; -- Aria
statusActorTierDefinitions[214] = { hasActorTier = true, tier = 0 }; -- March
statusActorTierDefinitions[215] = { hasActorTier = true, tier = 0 }; -- Etude
statusActorTierDefinitions[216] = { hasActorTier = true, tier = 0 }; -- Carol
statusActorTierDefinitions[217] = { hasActorTier = true, tier = 0 }; -- Threnody
statusActorTierDefinitions[218] = { hasActorTier = true, tier = 0 }; -- Hymnus
statusActorTierDefinitions[219] = { hasActorTier = true, tier = 0 }; -- Mazurka
statusActorTierDefinitions[220] = { hasActorTier = true, tier = 0 }; -- Sirvente
statusActorTierDefinitions[221] = { hasActorTier = true, tier = 0 }; -- Dirge
statusActorTierDefinitions[222] = { hasActorTier = true, tier = 0 }; -- Scherzo
statusActorTierDefinitions[223] = { hasActorTier = true, tier = 0 }; -- Nocturne

-- Use for both spell-based and status-based
local defaultUnknownActorTierDefinitions = { hasActorTier = false, tier = 0 };

local lastrender = 0;

---------------------------------------------------------------------------------------------------
-- desc: Default MyEffects configuration table.
---------------------------------------------------------------------------------------------------
local default_config =
{
    font =
    {
        name        = 'Tahoma',
        size        = 10,
        color       = 0xFFFFFFFF,
        position    = { 50, 200 },
        bgcolor     = 0x80000000,
        bgvisible   = true
    },
    colors =
    {
        time_long     = '252,252,252',
        time_medium   = '255,255,96',
        time_short    = '252,64,64',
        time_expired  = '128,128,128',
        is_target     = '252,252,252',
        self_name     = '128,184,248',
        player_name   = '192,252,252',
        mob_name      = '252,252,252',
        action_name   = '255,255,176',
        decay         = '128,128,128'
    }
};
local myfx_config = default_config;

---------------------------------------------------------------------------------------------------
-- func: color_entry
-- desc: Colors an entry.
---------------------------------------------------------------------------------------------------
local function color_entry(s, c)
    return string.format('\\cs(%s)%s\\cr', c, s);
end

local function findEntity(entityid)
    -- targid < 0x400
    --   TYPE_MOB || TYPE_NPC || TYPE_SHIP
    -- targid < 0x700
    --   TYPE_PC
    -- targid < 0x800
    --   TYPE_PET

    -- Search players
    for x = 0x400, 0x6FF do
        local ent = GetEntity(x);
        if (ent ~= nil and ent.ServerID == entityid) then
            return { id = entityid, index = x, name = ent.Name };
        end
    end

    return nil;
end

local function getEntityInfo(zoneid, entityid)
    local zonemin = bit.lshift(zoneid, 12) + 0x1000000;

    local entityindex;
    local entityname;
    local entitytype;
    local isself = false;

    -- Check if entity looks like a mobid
    if (bit.band(zonemin, entityid) == zonemin) then
        entityindex = bit.band(entityid, 0xfff);
        entityname = MobNameFromTargetId(entityindex);
        entitytype = 0x04; -- TYPE_MOB
    else
        -- Otherwise try finding player in NPC map
        local entityResult = findEntity(entityid);
        if (entityResult ~= nil) then
            entityindex = entityResult.index;
            entityname = entityResult.name;
            entitytype = 0x01; -- TYPE_PC

            -- If player, determine if player is self
            local selftarget = AshitaCore:GetDataManager():GetParty():GetPartyMemberTargetIndex(0);
            if (entityindex == selftarget) then
                isself = true;
            end
        else
            entityindex = 0;
            entityname = nil;
            entitytype = 0x00;
        end
    end

    if (entityname == nil) then
        entityname = 'UNKNOWN_MOB';
    end

    return { id = entityid, index = entityindex, name = entityname, entitytype = entitytype, isself = isself };
end

local function getStatusInfo(statustype, statusid)
    local statusname;

    if (statustype == 0x01) then
        statusname = AshitaCore:GetResourceManager():GetString('statusnames', statusid);
    elseif (statustype == 0x02) then
        statusname = modList[statusid];
    else
        statusname = 'UNKNOWN_STATUSTYPE';
    end

    if (statusname == nil) then
        statusname = 'UNKNOWN_STATUS';
    end

    return { id = statusid, name = statusname };
end

local function getSpellInfo(spellid)
    local spellobj = AshitaCore:GetResourceManager():GetSpellByID(spellid);
    local spellname;
    if (spellobj ~= nil) then
        spellname = spellobj.Name[0];
    end

    if (spellname == nil) then
        spellname = 'UNKNOWN_SPELL';
    end

    return { id = spellid, name = spellname };
end

local function getJobAbilityInfo(jobabilityid)
    -- Job abilities begin after 512
    local jobabilityobj = AshitaCore:GetResourceManager():GetAbilityByID(jobabilityid + 512);
    local jobabilityname;
    if (jobabilityobj ~= nil) then
        jobabilityname = jobabilityobj.Name[0];
    end

    if (jobabilityname == nil) then
        jobabilityname = 'UNKNOWN_JOBABILITY';
    end

    return { id = jobabilityid, name = jobabilityname };
end

local function getMobAbilityInfo(mobabilityid)
    if (mobabilityid < 256) then
        return { id = mobabilityid, name = 'OUTOFRANGE_MOBABILITY' };
    end

    local mobabilityname = AshitaCore:GetResourceManager():GetString('mobskills', mobabilityid - 256);

    if (mobabilityname == nil) then
        mobabilityname = 'UNKNOWN_MOBABILITY';
    end

    return { id = mobabilityid, name = mobabilityname };
end

local function getDanceInfo(danceid)
    -- Same as job abilities
    -- Job abilities begin after 512
    local danceobj = AshitaCore:GetResourceManager():GetAbilityByID(danceid + 512);
    local dancename;
    if (danceobj ~= nil) then
        dancename = danceobj.Name[0];
    end

    if (dancename == nil) then
        dancename = 'UNKNOWN_DANCE';
    end

    return { id = danceid, name = dancename };
end

local function getMob(mobindex, mobname)
    if (mobindex > 2047) then -- Should never be greater than 0x7ff
        return nil;
    end

    local mobkey = mobindex;

    if (statuseffects.mobs == nil) then
        statuseffects.mobs = { };
    end

    local mobitem = statuseffects.mobs[mobkey];
    if (mobitem == nil) then
        mobitem = { };
        mobitem.index = mobindex;
        mobitem.name = mobname;
        statuseffects.mobs[mobkey] = mobitem;
    end

    return mobitem;
end

local function getMobAction(mobitem, statusid, statusname)
    local statuskey = statusname; -- Using status name since some spells can have distinct status id values, but the same status name, such as Sleep and Sleep II

    if (mobitem.actions == nil) then
        mobitem.actions = { };
    end

    local actionitem = mobitem.actions[statuskey];
    if (actionitem == nil) then
        actionitem = { };
        actionitem.id = statusid;
        actionitem.name = statusname;
        mobitem.actions[statuskey] = actionitem;
    end

    return actionitem;
end

local function getActorTier(actionitem, actorid, actorname, tier)
    -- Need actor and tier for songs
    local actortierkey = tostring(actorid) .. '|' .. tostring(tier);

    if (actionitem.actortiers == nil) then
        actionitem.actortiers = { };
    end

    local actortieritem = actionitem.actortiers[actortierkey];
    if (actortieritem == nil) then
        actortieritem = { };
        actortieritem.actorid = actorid;
        actortieritem.actorname = actorname;
        actortieritem.tier = tier;
        actionitem.actortiers[actortierkey] = actortieritem;
    end

    return actortieritem;
end

---------------------------------------------------------------------------------------------------
-- func: searchActorTier
-- desc: Finds the oldest active actor/tier entry for a particular status on a mob.
---------------------------------------------------------------------------------------------------
local function searchActorTier(actionitem)
    if (actionitem.actortiers == nil) then
        return getActorTier(actionitem, 0, 'UNKNOWN_ACTOR', 0);
    end

    -- User current time as starting point for search
    -- Nothing should really be very close, relatively speaking, to the current time
    local modified = os.clock();
    local actortieritem;

    for k, v in pairs(actionitem.actortiers) do
        -- Check active flag to exclude anything already explicitly flagged as inactive
        -- Otherwise old entries could keep getting found as matches
        if (v.active and modified > v.modified) then
            modified = v.modified
            actortieritem = v;
        end
    end

    if (actortieritem == nil) then
        return getActorTier(actionitem, 0, 'UNKNOWN_ACTOR', 0);
    end

    return actortieritem;
end

local function formatTimespan(value)
    local sign;
    if (value < 0) then
        sign = '-';
        value = 0 - value;
    else
        sign = ' ';
    end

    local hour = math.floor(value / (60 * 60));
    local mins = math.floor((value / 60) - (hour * 60));
    local totalmins = mins + (hour * 60);
    local secs = math.floor(value - (totalmins * 60));
    return string.format('%s%02i:%02i:%02i', sign, hour, mins, secs);
end

local function formatFractionalTimespan(value)
    local sign;
    if (value < 0) then
        sign = '-';
        value = 0 - value;
    else
        sign = ' ';
    end

    local hour = math.floor(value / (60 * 60));
    local mins = math.floor((value / 60) - (hour * 60));
    local totalmins = mins + (hour * 60);
    local secs = math.floor(value - (totalmins * 60));
    local totalsecs = secs + (totalmins * 60);
    local fracsecs = math.floor((value - totalsecs) * 10);
    return string.format('%s%02i:%02i:%02i.%01i', sign, hour, mins, secs, fracsecs);
end

local function handleActionPacket(id, size, packet)
    -- Action packet only sends actor/target id, not index

    local zoneid = MobInfoZoneId();

    local pp = lor_packets.parse_action_full(packet);

    local actorInfo = getEntityInfo(zoneid, pp.actor_id); -- For debug purposes

    for x = 1, pp.target_count do
        local target = pp.targets[x];

        local hasTarget;

        local targetInfo = getEntityInfo(zoneid, target.id);
        if (targetInfo ~= nil and targetInfo.entitytype > 0x00) then
            hasTarget = true;
        else
            hasTarget = false;
        end

        for y = 1, target.action_count do
            local action = target.actions[y];

            local messageDef;
            local actorTierDef;

            local hasStatus;
            local hasSpell;
            local hasJobAbility;
            local hasMobAbility;
            local hasDance;

            local statusInfo;
            local spellInfo;
            local jobAbilityInfo;
            local mobAbilityInfo;
            local danceInfo;

            if (pp.category == 4) then
                messageDef = spellMessageDefinitions[action.message_id];
                if (messageDef == nil) then
                    messageDef = defaultSpellMessageDefinitions;
                end

                if (messageDef.hasSpell) then
                    hasSpell = true;
                    spellInfo = getSpellInfo(pp.param);
                else
                    hasSpell = false;
                    spellInfo = nil;
                end

                -- Handle both standard and AOE versions of each message
                if (action.message_id == 2 or action.message_id == 264) then -- The <player> casts <spell>. <target> takes .. points of damage.
                    -- Dia/Bio are damage spells with additional effects
                    -- Do not get any message indicating if effect received

                    -- Normalize spell to effect name (e.g., "Dia", "Dia II" -> "Dia")
                    if (spellInfo ~= nil) then
                        local spellEffectItem = spellEffectMap[pp.param];
                        if (spellEffectItem ~= nil) then
                            hasStatus = true;
                            statusInfo = getStatusInfo(spellEffectItem.effectType, spellEffectItem.effectId);
                        else
                            -- No other way to get status
                            -- Do not care about spells without additional effects
                            hasStatus = false;
                            statusInfo = emptyStatusInfo;
                        end
                    end
                elseif (action.message_id == 230 or action.message_id == 266) then -- The <player> casts <spell>. <target> gains the effect of <spell>.
                    -- Player/mob buffs
                    hasStatus = true;
                    statusInfo = getStatusInfo(0x01, action.param);

                    actorTierDef = spellActorTierDefinitions[pp.param];
                elseif (action.message_id == 236 or action.message_id == 277) then -- The <player> casts <spell>. <target> is <effect>.
                    hasStatus = true;
                    statusInfo = getStatusInfo(0x01, action.param);
                elseif (action.message_id == 237 or action.message_id == 278) then -- The <player> casts <spell>. <target> receives the effect of <spell>.
                    -- Elemental debuffs use this message
                    -- Some spells have a different effect name when receiving vs wearing

                    -- Normalize spell to effect name (e.g., "Horde Lullaby", "Foe Lullaby" -> "Sleep")
                    if (spellInfo ~= nil) then
                        local spellEffectItem = spellEffectMap[pp.param];
                        if (spellEffectItem ~= nil) then
                            hasStatus = true;
                            statusInfo = getStatusInfo(spellEffectItem.effectType, spellEffectItem.effectId);
                        else
                            -- Use normal way to get status
                            hasStatus = true;
                            statusInfo = getStatusInfo(0x01, action.param);
                        end
                    end

                    actorTierDef = spellActorTierDefinitions[pp.param];
                elseif (action.message_id == 329
                    or action.message_id == 330
                    or action.message_id == 331
                    or action.message_id == 332
                    or action.message_id == 333
                    or action.message_id == 334
                    or action.message_id == 335) then -- The <player> casts <spell>. <target>'s <stat> is drained.
                    -- Absorb-STR
                    -- Absorb-DEX
                    -- Absorb-VIT
                    -- Absorb-AGI
                    -- Absorb-INT
                    -- Absorb-MND
                    -- Absorb-CHR
                    hasStatus = true;
                    statusInfo = getStatusInfo(0x01, action.param);
                elseif (action.message_id == 341) then -- The <player> casts <spell>. <target>'s <effect> effect disappears!
                    -- Spell cast is unrelated to the effect
                    -- Dispel/Finale
                    hasStatus = true;
                    statusInfo = getStatusInfo(0x01, action.param);

                    actorTierDef = statusActorTierDefinitions[action.param];
                elseif (action.message_id == 533) then -- The <player> casts <spell>. <target>'s Accuracy is drained.
                    -- Absorb-ACC

                    -- Normalize spell to effect name
                    -- Server returns player effect (Accuracy Boost (90))
                    -- NOTE: Possible DSP bug, other absorb spells return debuff effect instead of buff effect
                    if (spellInfo ~= nil) then
                        local spellEffectItem = spellEffectMap[pp.param];
                        if (spellEffectItem ~= nil) then
                            hasStatus = true;
                            statusInfo = getStatusInfo(spellEffectItem.effectType, spellEffectItem.effectId);
                        else
                            -- Use normal way to get status
                            hasStatus = true;
                            statusInfo = getStatusInfo(0x01, action.param);
                        end
                    end
                else
                    hasStatus = false;
                    statusInfo = nil;
                end
            elseif (pp.category == 6) then
                messageDef = jobAbilityMessageDefinitions[action.message_id];
                if (messageDef == nil) then
                    messageDef = defaultJobAbilityMessageDefinitions;
                end

                if (messageDef.hasJobAbility) then
                    hasJobAbility = true;
                    jobAbilityInfo = getJobAbilityInfo(pp.param);
                else
                    hasJobAbility = false;
                    jobAbilityInfo = nil;
                end

                if (
                    action.message_id == 116 -- The <player> uses .. <target>'s attacks are enhanced.
                    or action.message_id == 120 -- The <player> uses .. <target>'s accuracy is enhanced.
                    or action.message_id == 121 -- The <player> uses .. <target>'s evasion is enhanced.
                ) then
                    -- ex: Player using Boost
                    -- ex: Player using Focus
                    -- ex: Player using Dodge

                    -- Normalize job ability to effect name
                    -- No effect is sent in this message
                    if (jobAbilityInfo ~= nil) then
                        local jobAbilityEffectItem = jobAbilityEffectMap[pp.param];
                        if (jobAbilityEffectItem ~= nil) then
                            hasStatus = true;
                            statusInfo = getStatusInfo(jobAbilityEffectItem.effectType, jobAbilityEffectItem.effectId);
                        else
                            -- No other way to get status
                            -- Do not care about abilities without additional effects
                            hasStatus = false;
                            statusInfo = emptyStatusInfo;
                        end
                    end
                else
                    hasStatus = false;
                    statusInfo = nil;
                end
            elseif (pp.category == 11) then
                messageDef = mobAbilityMessageDefinitions[action.message_id];
                if (messageDef == nil) then
                    messageDef = defaultMobAbilityMessageDefinitions;
                end

                if (messageDef.hasMobAbility) then
                    hasMobAbility = true;
                    mobAbilityInfo = getMobAbilityInfo(pp.param);
                else
                    hasMobAbility = false;
                    mobAbilityInfo = nil;
                end

                if (action.message_id == 159) then -- The <player> uses .. <target>'s <effect> effect disappears!
                    -- Mob ability is unrelated to the effect
                    -- ex: Opo-opo using Blank Gaze
                    hasStatus = true;
                    statusInfo = getStatusInfo(0x01, action.param);

                    actorTierDef = statusActorTierDefinitions[action.param];
                elseif (action.message_id == 185 or action.message_id == 264) then -- The <player> uses .. <target> takes .. points of damage.
                    -- ex: Yagudo using Feather Storm

                    -- Normalize mob ability to effect name
                    -- No effect is sent in this message
                    if (mobAbilityInfo ~= nil) then
                        local mobAbilityEffectItem = mobAbilityEffectMap[pp.param];
                        if (mobAbilityEffectItem ~= nil) then
                            hasStatus = true;
                            statusInfo = getStatusInfo(mobAbilityEffectItem.effectType, mobAbilityEffectItem.effectId);
                        else
                            -- No other way to get status
                            -- Do not care about abilities without additional effects
                            hasStatus = false;
                            statusInfo = emptyStatusInfo;
                        end
                    end
                elseif (action.message_id == 186 or action.message_id == 266) then -- The <player> uses .. <target> gains the effect of <effect>.
                    -- ex: Bomb using Berserk
                    hasStatus = true;
                    statusInfo = getStatusInfo(0x01, action.param);
                else
                    hasStatus = false;
                    statusInfo = nil;
                end
            elseif (pp.category == 14) then
                messageDef = danceMessageDefinitions[action.message_id];
                if (messageDef == nil) then
                    messageDef = defaultDanceMessageDefinitions;
                end

                if (messageDef.hasDance) then
                    hasDance = true;
                    danceInfo = getDanceInfo(pp.param);
                else
                    hasDance = false;
                    danceInfo = nil;
                end

                if (action.message_id == 100) then -- The <player> uses ..
                    -- ex: Drain Samba

                    -- Normalize dance to effect name
                    -- No effect is sent in this message
                    if (danceInfo ~= nil) then
                        local danceEffectItem = danceEffectMap[pp.param];
                        if (danceEffectItem ~= nil) then
                            hasStatus = true;
                            statusInfo = getStatusInfo(danceEffectItem.effectType, danceEffectItem.effectId);
                        else
                            -- No other way to get status
                            -- Do not care about abilities without additional effects
                            hasStatus = false;
                            statusInfo = emptyStatusInfo;
                        end
                    end
                else
                    hasStatus = false;
                    statusInfo = nil;
                end
            else
                messageDef = defaultUnknownDefinitions;

                hasStatus = false;
                statusInfo = nil;
            end

            if (hasTarget and hasStatus) then
                if (actorTierDef == nil) then
                    actorTierDef = defaultUnknownActorTierDefinitions;
                end

                local mobitem = getMob(targetInfo.index, targetInfo.name);
                local actionitem = getMobAction(mobitem, statusInfo.id, statusInfo.name);

                -- Params needed to color name by type (self, player, or mob)
                mobitem.entitytype = targetInfo.entitytype;
                mobitem.isself = targetInfo.isself;

                mobitem.message_id = nil;
                mobitem.modified = nil;
                mobitem.showDecayTime = nil;
                mobitem.useDuration = nil;
                mobitem.duration = nil;
                mobitem.mobStatus = nil;

                local currentitem;

                if (actorTierDef.hasActorTier) then
                    local actortieritem;

                    if (actorTierDef.tier > 0) then
                        -- Have actor/tier, so get directly
                        -- ex: Song was sung
                        actortieritem = getActorTier(actionitem, pp.actor_id, actorInfo.name, actorTierDef.tier);
                    else
                        -- Do not have actor/tier, so search
                        -- ex: Dispel
                        actortieritem = searchActorTier(actionitem);
                    end

                    currentitem = actortieritem;
                else
                    currentitem = actionitem;
                end

                currentitem.active = true;
                currentitem.message_id = action.message_id;
                currentitem.modified = os.clock();
                currentitem.showDecayTime = messageDef.showDecayTime;
                currentitem.useDuration = messageDef.useDuration;

                if (hasSpell) then
                    local dur = spellDurations[spellInfo.id];
                    if (dur == nil) then
                        dur = defaultSpellDurations;
                    end

                    -- Store spell id/name
                    currentitem.spell_id = spellInfo.id;
                    currentitem.spell_name = spellInfo.name;
                    currentitem.duration = dur;
                elseif (hasJobAbility) then
                    local dur = jobAbilityDurations[jobAbilityInfo.id];
                    if (dur == nil) then
                        dur = defaultJobAbilityDurations;
                    end

                    -- Store job ability id/name
                    currentitem.job_ability_id = jobAbilityInfo.id;
                    currentitem.job_ability_name = jobAbilityInfo.name;
                    currentitem.duration = dur;
                elseif (hasMobAbility) then
                    local dur = mobAbilityDurations[mobAbilityInfo.id];
                    if (dur == nil) then
                        dur = defaultMobAbilityDurations;
                    end

                    -- Store mob ability id/name
                    currentitem.mob_ability_id = mobAbilityInfo.id;
                    currentitem.mob_ability_name = mobAbilityInfo.name;
                    currentitem.duration = dur;
                elseif (hasDance) then
                    local dur = danceDurations[danceInfo.id];
                    if (dur == nil) then
                        dur = defaultDanceDurations;
                    end

                    -- Store dance id/name
                    currentitem.dance_id = danceInfo.id;
                    currentitem.dance_name = danceInfo.name;
                    currentitem.duration = dur;
                else
                    currentitem.spell_id = 0;
                    currentitem.spell_name = nil;
                    currentitem.duration = defaultUnknownDurations;
                end
            end
        end
    end
end

local function handleMessageBasicPacket(id, size, packet)
    -- Use bitmask like with Action packet handling for actor/target index

    local zoneid = MobInfoZoneId();

    local pp = lor_packets.parse_action_message(packet);

    local actorInfo = getEntityInfo(zoneid, pp.actor_id); -- For debug purposes

    local hasTarget;
    local statusType;

    local messageDef = basicMessageDefinitions[pp.message_id];
    if (messageDef == nil) then
        messageDef = defaultBasicMessageDefinitions;
    end

    if (messageDef.resolveTarget) then
        targetInfo = getEntityInfo(zoneid, pp.target_id);
        if (targetInfo ~= nil and targetInfo.entitytype > 0x00) then
            hasTarget = true;
        else
            hasTarget = false;
        end
    end

    local actorTierDef;

    if (pp.message_id == 6) then -- The <player> defeats <target>.
        statusType = 0x01;
    elseif (pp.message_id == 20) then -- <target> falls to the ground.
        statusType = 0x01;
    elseif (pp.message_id == 206) then -- <target>'s <param> effect wears off.
        statusType = 0x02;
        statusInfo = getStatusInfo(0x01, pp.param_1);

        actorTierDef = statusActorTierDefinitions[pp.param_1];
    else
        statusType = 0x00;
    end

    if (hasTarget and (statusType > 0x00)) then
        local mobitem = getMob(targetInfo.index, targetInfo.name);

        -- Params needed to color name by type (self, player, or mob)
        mobitem.entitytype = targetInfo.entitytype;
        mobitem.isself = targetInfo.isself;

        if (statusType == 0x01) then
            local mobStat;
            mobStat = mobStatus[pp.message_id];
            if (mobStat == nil) then
                mobStat = defaultMobStatus;
            end

            mobitem.message_id = pp.message_id;
            mobitem.modified = os.clock();
            mobitem.showDecayTime = messageDef.showDecayTime;
            mobitem.useDuration = messageDef.useDuration;
            mobitem.duration = defaultBasicDurations;
            mobitem.mobStatus = mobStat;
        elseif (statusType == 0x02) then
            if (actorTierDef == nil) then
                actorTierDef = defaultUnknownActorTierDefinitions;
            end

            local actionitem = getMobAction(mobitem, statusInfo.id, statusInfo.name);

            mobitem.message_id = nil;
            mobitem.modified = nil;
            mobitem.showDecayTime = nil;
            mobitem.useDuration = nil;
            mobitem.duration = nil;
            mobitem.mobStatus = nil;

            local currentitem;

            if (actorTierDef.hasActorTier) then
                local actortieritem = searchActorTier(actionitem);
                currentitem = actortieritem;
            else
                currentitem = actionitem;
            end

            currentitem.active = false;
            currentitem.message_id = pp.message_id;
            currentitem.modified = os.clock();
            currentitem.showDecayTime = messageDef.showDecayTime;
            currentitem.useDuration = messageDef.useDuration;
            currentitem.duration = defaultBasicDurations;
        else
            print(string.format('Status type out of range: %d', statusType));
        end
    end
end

local function formatEntry(currenttime, mob_is_target_string, entitytype, isself, mobName, actionName, modified, showDecayTime, useDuration, duration)
    local timeRemaining;
    local time_color;
    if (useDuration) then
        -- Receives effect
        timeRemaining = modified - currenttime + duration;

        -- Color by time remaining
        if (timeRemaining >= 20) then
            time_color = myfx_config.colors.time_long;
        elseif (timeRemaining >= 10) then
            time_color = myfx_config.colors.time_medium;
        else
            time_color = myfx_config.colors.time_short;
        end
    else
        -- Effect wears off
        -- Unknown
        timeRemaining = modified - currenttime;

        -- Always use expired color
        time_color = myfx_config.colors.time_expired;
    end

    local timeRemainingString;
    local displayType;

    -- Display decay for 10 seconds
    if (timeRemaining >= 10) then
        timeRemainingString = formatTimespan(timeRemaining);
        displayType = 0x01;
    elseif (timeRemaining >= 0) then
        timeRemainingString = formatFractionalTimespan(timeRemaining);
        displayType = 0x01;
    elseif (timeRemaining >= -10) then
        timeRemainingString = formatFractionalTimespan(timeRemaining);
        displayType = 0x02;
    elseif (timeRemaining >= -30 and showDecayTime) then
        -- Extra decay time
        timeRemainingString = formatTimespan(timeRemaining);
        displayType = 0x02;
    else
        timeRemainingString = '';
        displayType = 0x00;
    end

    if (not showDecayTime) then
        timeRemainingString = '';
    end

    local mob_name_color;

    -- Color name by type (self, player, or mob)
    if (isself) then
        mob_name_color = myfx_config.colors.self_name;
    elseif (entitytype == 0x01) then
        mob_name_color = myfx_config.colors.player_name;
    else
        mob_name_color = myfx_config.colors.mob_name;
    end

    -- TODO: Purge decayed entries
    -- TODO: Also show "if part resisted" time remaining
    if (displayType == 0x01) then
        return string.format(' %s %s %s %s  ',
            color_entry(mob_is_target_string, myfx_config.colors.is_target),
            color_entry(mobName, mob_name_color),
            color_entry(actionName, myfx_config.colors.action_name),
            color_entry(timeRemainingString, time_color));
    elseif (displayType == 0x02) then
        -- Show entire line in decay color
        return color_entry(
            string.format(' %s %s %s %s  ',
                mob_is_target_string,
                mobName,
                actionName,
                timeRemainingString),
            myfx_config.colors.decay);
    end

    return nil;
end

ashita.register_event('command', function(cmd, nType)
    local args = cmd:GetArgs();

    if (#args > 0 and args[1] == '/fx')  then
        if (#args > 1)  then
            if (args[2] == 'reset')  then
                print('Resetting fx...');
                statuseffects = { };
            elseif (args[2] == 'debug')  then
                -- TODO: Clean up display (e.g., show action per line)
                print('Debug fx...');
                if (statuseffects.mobs ~= nil) then
                    for k, v in pairs(statuseffects.mobs) do
                        print(tostring(k) .. ':' .. settings.JSON:encode(v));
                    end
                else
                    print('Empty!');
                end
            elseif (args[2] == 'dump')  then
                print('Dumping fx...');
                settings:save(_addon.path .. 'settings/dump.json', statuseffects.mobs);
            end
        end
    end
end);

ashita.register_event('incoming_packet', function(id, size, packet)
    __mobinfo_incoming_packet(id, size, packet);

    -- Check for zone-in packets..
    if (id == 0x0A) then
        statuseffects = { };
    end

    if (id == 0x0028) then -- Action (Spells, Abilities, Weapon skills, etc.)
        handleActionPacket(id, size, packet);
        return false;
    end

    if (id == 0x0029) then -- Message Basic
        handleMessageBasicPacket(id, size, packet);
        return false;
    end

    return false;
end );

ashita.register_event('load', function()
    __mobinfo_load();

    -- Attempt to load the MyEffects configuration..
    myfx_config = settings:load(_addon.path .. 'settings/myfx.json') or default_config;
    myfx_config = table.merge(default_config, myfx_config);

    -- Create our font object..
    local f = AshitaCore:GetFontManager():CreateFontObject( '__myfx_addon' );
    f:SetBold( false );
    f:SetColor( myfx_config.font.color );
    f:SetFont( myfx_config.font.name, myfx_config.font.size );
    f:SetPosition( myfx_config.font.position[1], myfx_config.font.position[2] );
    f:SetText( '' );
    f:SetVisibility( true );
    f:GetBackground():SetColor( myfx_config.font.bgcolor );
    f:GetBackground():SetVisibility( myfx_config.font.bgvisible );
end );

ashita.register_event('unload', function()
    local f = AshitaCore:GetFontManager():GetFontObject( '__myfx_addon' );
    myfx_config.font.position = { f:GetPositionX(), f:GetPositionY() };

    -- Ensure the settings folder exists..
    if (not file:dir_exists(_addon.path .. 'settings')) then
        file:create_dir(_addon.path .. 'settings');
    end

    -- Save the configuration..
    settings:save(_addon.path .. 'settings/myfx.json', myfx_config);

    -- Unload our font object..
    AshitaCore:GetFontManager():DeleteFontObject( '__myfx_addon' );
end );

---------------------------------------------------------------------------------------------------
-- func: Render
-- desc: Called when our addon is rendered.
---------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    local currenttime = os.clock();

    -- Only render at 1/10s tick
    if ((lastrender + 0.1) < currenttime) then
        lastrender = currenttime;

        local f = AshitaCore:GetFontManager():GetFontObject( '__myfx_addon' );
        local e = { }; -- Effect entries..

        if (statuseffects.mobs ~= nil) then
            local count = 0;
            local totalcount = 0;
            local mob_is_target_string;
            local target = AshitaCore:GetDataManager():GetTarget():GetTargetEntity();
            local s;

            for k, v in pairs(statuseffects.mobs) do
                local mob = v;

                -- Show asterisk if selected rather than mob index
                if (target ~= nil and mob.index == target.TargetID) then
                    mob_is_target_string = '*';
                else
                    mob_is_target_string = ' ';
                end

                if (mob.message_id ~= nil) then
                    if (count < 32) then
                        s = formatEntry(currenttime, mob_is_target_string, mob.entitytype, mob.isself, mob.name, mob.mobStatus, mob.modified, mob.showDecayTime, mob.useDuration, mob.duration);
                        if (s ~= nil) then
                            table.insert(e, s);
                            count = count + 1;
                        end
                    end

                    totalcount = totalcount + 1;
                else
                    -- Mob status effects
                    for k2, v2 in pairs(mob.actions) do
                        local action = v2;

                        if (action.message_id ~= nil) then
                            if (count < 32) then
                                s = formatEntry(currenttime, mob_is_target_string, mob.entitytype, mob.isself, mob.name, action.name, action.modified, action.showDecayTime, action.useDuration, action.duration);
                                if (s ~= nil) then
                                    table.insert(e, s);
                                    count = count + 1;
                                end
                            end
                        else
                            for k3, v3 in pairs(action.actortiers) do
                                local actortier = v3;

                                if (count < 32) then
                                    local formattedactionname = action.name .. tiers[actortier.tier] .. ' (' .. actortier.actorname .. ')';

                                    s = formatEntry(currenttime, mob_is_target_string, mob.entitytype, mob.isself, mob.name, formattedactionname, actortier.modified, actortier.showDecayTime, actortier.useDuration, actortier.duration);
                                    if (s ~= nil) then
                                        table.insert(e, s);
                                        count = count + 1;
                                    end
                                end

                                totalcount = totalcount + 1;
                            end
                        end

                        totalcount = totalcount + 1;
                    end
                end
            end
        end

        local output = table.concat( e, '\n' );
        f:SetText( output );
    end
end );
