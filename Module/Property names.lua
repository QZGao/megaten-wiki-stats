---
-- Megami Tensei Wiki
-- page=Module:Property names
--
-- Licensed under CC BY-SA 3.0
---


local property_names = {
	name = { 'Name', 'name' },
	image = { 'Image', 'image' },
	quote = { 'Quote', 'quote', 'FusedQuote', 'fusedquote', 'fquote1' },
	profile = { 'Profile', 'profile', 'FusingQuote', 'fusingquote', 'fquote2', 'Password', 'password' },
	vanilla = { 'Vanilla', 'vanilla' },
	enemy = { 'Enemy', 'enemy' },
	boss = { 'Boss', 'boss' },
	guest = { 'Guest', 'guest', 'Guest1', 'guest1', 'Guest2', 'guest2' },
	essence = { 'Essence', 'essence' },
	alignment = { 'Alignment', 'Align', 'alignment', 'align', default = '?' },
	formation = { 'Formations', 'formations', 'Formation', 'formation', 'Form', 'form', default = '' },
	hp = { 'HP', 'hp', 'HitPoints', 'HitPoint' },
	mp = { 'MP', 'mp', 'ManaPoints', 'ManaPoint', 'SP', 'sp', 'PP', 'pp' },
	maxhp = { 'maxhp', 'MaxHP', 'Maxhp', 'MAXHP' },
	maxmp = { 'maxmp', 'MaxMP', 'Maxmp', 'MAXMP', 'MaxSP', 'Maxsp', 'MAXSP', 'MaxPP', 'Maxpp', 'MAXPP' },
	level = { 'Level', 'level', 'Lv', 'lv', 'lvl', 'LV', 'LVL', 'Rank', 'rank', 'grade', 'Grade', default = '?' },
	race = { 'Race', 'race', 'Clan', 'clan', 'type', 'species', 'Order', 'order' },
	order2 = { 'Order2', 'order2' }, -- Persona 1 PSP order which differs from PSX version.
	arcana = { 'Arcana', 'arcana' },
	class = { 'Class', 'class' },
	etype = { 'Type', 'etype', 'Affinity', 'affinity', 'Element', 'element', 'align' },
	element = { 'Element', 'element', 'Subtype', 'subtype' },
	bonus = { 'Bonus', 'bonus' },
	mag = { 'MAG Per Step', 'MAG', 'Mag', 'mag', 'Mag Drop', 'Magnetite', 'magnetite' },
	cp = { 'CP', 'cp' },
	capacity = { 'Capacity', 'capacity' },
	buildspeed = { 'BuildSpeed', 'Buildspeed', 'build', 'buildspeed' },
	destroyspeed = { 'DestroySpeed', 'Destroyspeed', 'destroy', 'destroyspeed' },
	condition = { 'Condition', 'condition', 'Conditional', 'conditional', 'MAG Cost', 'Cost', 'CP' },
	summoncost = { 'MAG Summon', 'summoncost' },
	normal = { 'Normal', 'normal', 'Drops', 'drops', 'Drop', 'drop' },
	rare = { 'Rare', 'rare' },
	drop1 = { 'Drop1', 'drop1', 'Negotiation1' },
	drop2 = { 'Drop2', 'drop2', 'Negotiation2' },
	drop3 = { 'Drop3', 'drop3', 'Negotiation3' },
	dropc = { 'DropC', 'Dropc', 'dropc', 'Drop4', 'drop4', 'Negotiation4' },
	elecchair = { 'elecchair', 'ElecChair', 'Elecchair', 'elecChair', 'ElectricChair', 'Electricchair', 'electricchair', 'electricChair', 'ece', 'Ece', 'ECE' },
	gift = { 'gift', 'Gift', 'GIFT' },
	preturn = { 'Return', 'Return Item', 'Heart', 'heart' },
	card = { 'Cards', 'cards', 'Card', 'card', 'Tarot', 'tarot', 'Tarot Card Number', 'Extract', 'extract' },
	fragment = { 'Fragment', 'fragment' },
	totem = { 'Totem', 'totem' },
	material = { 'Material', 'material' },
	evolvef = { 'evolved from', 'Evolvedfrom', 'evolvef' },
	evolvefl = { 'Evolvedfromlevel', 'evolvefl' },
	evolvet = { 'evolves into', 'Evolveinto', 'evolvet' },
	evolvetl = { 'Evolveintolevel', 'evolvetl' },
	fusion = { 'Fusion', 'fusion', 'Specialfusion', 'special fusion' },
	requiredquest = { 'Requiredquest', 'requiredquest' },
	relatedquest = { 'Relatedquest', 'relatedquest' },
	type1 = { 'Type1', 'type1' },
	type2 = { 'Type2', 'type2' },
	type3 = { 'Type3', 'type3' },
	desc1 = { 'Description1', 'description1' },
	desc2 = { 'Description2', 'description2' },
	desc3 = { 'Description3', 'description3' },
	unknown = { 'Unknown Power', 'unknown' },
	investigate = { 'Investigate', 'investigate', 'Investigation', 'investigation', default = '' },
	call = { 'Call', 'CALL', 'call', default = '' },
	spell = { 'Spell', 'spell', 'SPL', 'Spl', 'spl', 'SP', 'Sp', 'sp', default = '' },
	support = { 'Support', 'support', default = '' },
	number = { 'NO', 'no', 'Number', 'number', default = '' },
	equip = { 'Equipment', 'equipment', 'Equip', 'equip', default = '' },
	move = { 'Movement', 'MOVEMENT', 'movement', 'Move', 'MOVE', 'move', default = '' },
	movetype = { 'Move Type', 'move type', 'movetype', default = '' },
	power = { 'Power', 'POWER', 'power', 'Pwr', 'PWR', 'pwr', default = '' },
	might = { 'Might', 'MIGHT', 'might', 'Mgt', 'MGT', 'mgt', default = '' },
	exclusive = { 'Exclusive', 'exclusive' },
	traits = { 'Traits', 'traits', 'Trait', 'trait', 'Personality', 'personality', 'PSRN' },
	ptraits = { 'PersonaTraits', 'Personatraits', 'personatraits', 'PersonaTrait', 'Personatrait', 'personatrait', 'PTrait', 'Ptrait', 'ptrait', "Characteristics", "characteristics", "Characteristic", "characteristic", "Character", "character" },
	theurgia = { 'Theurgia', 'theurgia', 'Theurgy', 'theurgy', "theurgy", 'TheurgyGauge', "theurgygauge", "theurgyGauge", "GaugeCondition", "gaugeCondition", "gaugecondition" },
	convo = { 'special conversation', 'Conver', 'conver', 'Convo', 'convo', 'PTalk', 'Ptalk', 'ptalk' },
	recruit = { 'Recruit', 'recruit', 'Confine', 'confine', 'Confinable', 'confinable', default = '' },
	obtain = { 'Obtainable', 'obtainable', 'Obtain', 'obtain', default = '' },
	turnicon = { 'Turnicon', 'turnicon', 'turn', 'icon' },
	noa = { 'NOA', 'NOH', 'noa', 'noh', 'Normalattack', 'Basicattack', 'Regularattack', 'normalattack', 'basicattack', 'regularattack', 'AttackType', 'attacktype', 'Att Type', 'Range', 'range', default = '' },
	hit = { 'Hit', 'HIT', 'hit', 'PHit', 'PHIT', 'phit', default = '' },
	atk = { 'Attack', 'ATTACK', 'attack', 'ATK', 'Atk', 'atk', 'ATT', 'Att', 'att', 'PATK', default = '' },
	def = { 'Defense', 'DEFENSE', 'defense', 'DEF', 'Def', 'def', 'BDEF', 'PHYSDEF', 'PhysDef', 'pd', default = '' },
	matk = { 'MAttack', 'mAttack', 'MATK', 'MAtk', 'Matk', 'matk', 'MAATK', 'md', default = '' },
	mdef = { 'MDefense', 'mDefense', 'MDEF', 'MDef', 'Mdef', 'mdef', 'MADEF', 'MagDef', 'MD', default = '' },
	mpw = { 'MPower', 'mpower', 'MPW', 'MPw', 'Mpw', default = '' },
	mef = { 'MEffect', 'meffect', 'MEF', 'MEf', 'Mef', 'MHIT', 'mhit', default = '' },
	itin = { 'ITIN', 'itin', 'Intuition', 'intuition', default = '' },
	wllpow = { 'WLLPOW', 'wllpow', 'Will Power', 'will power', default = '' },
	dvnprt = { 'DVNPRT', 'dvnprt', 'Divine Protestion', 'divine protection', default = '' },
	avd = { 'Avoid', 'avoid', 'AVD', 'Avd', 'avd', 'Evasion', 'Eva', 'eva', default = '' },
	critical = { 'Critical', 'critical', 'Crit', 'CRIT', 'crit', 'CRI', 'cri', 'CRT', 'crt', default = '' },
	critdef = { 'CritDef', 'cd', default = '' },
	stagger = { 'staggergauge', 'Staggergauge', 'StaggerGauge', 'Stagger', 'Gauge', 'gauge' },
	restype = { 'restype' },
	res = { 'Resistance', 'resistance', 'RES', 'Res', 'res', 'Ailmentresistance', 'ailmentresistance', default = '' },
	growth = { 'Growth', 'growth', 'Grow', 'grow', default = '' },
	feature = { 'Features', 'features', 'Feature', 'feature', default = '' },
	seealso = { 'SeeAlso', 'seealso' },
	almres = { 'Almightyresistance', 'almightyresistance', default = '' },
	str = { 'Strength', 'strength', 'STR', 'Str', 'str', 'ST', 'St', 'st', default = '' },
	int = { 'Intelligence', 'intelligence', 'INT', 'Int', 'int', 'IN', 'In', 'in', 'Wisdom', 'wisdom', 'WSM', 'wsm', 'Intellect', 'intellect', default = '' },
	magic = { 'Magic', 'magic', 'MGC', 'Mgc', 'mgc', 'MAG', 'Mag', 'mag', 'MA', 'Ma', 'ma', default = '' },
	vit = { 'Vitality', 'vitality', 'VIT', 'Vit', 'vit', 'VI', 'Vi', 'vi', 'Endurance', 'endurance', 'EN', 'En', 'en', 'END', 'End', 'end', 'ENDU', 'Endu', 'endu', 'Stamina', 'stamina', 'STM', 'Stm', 'stm', default = '' },
	vit2 = { 'VIT2', 'Vit2', 'vit2', 'VI2', 'Vi2', 'vi2', },
	dex = { 'Dexterity', 'dexterity', 'DEX', 'Dex', 'dex', 'DX', 'Dx', 'dx', 'Technique', 'technique', 'Technicality', 'technicality', 'TEC', 'Tec', 'tec', default = '' },
	dex2 = { 'DEX2', 'Dex2', 'dex2', 'DX2', 'Dx2', 'dx2', },
	agl = { 'Agility', 'agility', 'AGL', 'Agl', 'agl', 'AGI', 'Agi', 'agi', 'AG', 'Ag', 'ag', 'Speed', 'speed', 'SPD', 'Spd', 'spd', 'Sp', default = '' },
	quick = { 'Quick', 'quick', 'QCK', 'Qck', 'qck', default = '' },
	luc = { 'Luck', 'luck', 'LCK', 'Lck', 'lck', 'LUC', 'Luc', 'luc', 'LUK', 'Luk', 'luk', 'LU', 'Lu', 'lu', default = '' },
	chm = { 'CHM', 'chm', 'Charm', 'charm', default = '' },
	weapon = { 'Weapon', 'WEAPON', 'weapon', default = '' },
	boost = { 'Boost', 'boost' },
	resist = { 'Resist', 'Resists', 'resist', 'resists' },
	block = { 'Block', 'Null', 'Immune', 'Shield', 'Void', 'block', 'null', 'immune', 'shield', 'void' },
	absorb = { 'Absorb', 'Absorbs', 'Drain', 'Drains', 'absorb', 'absorbs', 'drain', 'drains' },
	reflect = { 'Reflect', 'Reflects', 'Repel', 'Repels', 'reflect', 'reflects', 'repel', 'repels' },
	weak = { 'Weak', 'weak', 'Weakness', 'weakness' },
	frail = { 'Frail', 'frail' },
	phys = { 'Phys', 'Physical', 'phys', 'physical' },
	pierce = { 'Pierce', 'pierce', 'Stab', 'stab', 'Ranged', 'ranged', 'RN', 'Rn', 'rn' },
	gun = { 'Gun', 'gun', 'Gunfire', 'gunfire', 'GunFire' },
	closerange = { 'CloseRng', 'cr' },
	longrange = { 'LongRng', 'lr' },
	onehand = { '1h' },
	twohand = { '2h' },
	sword = { 'Sword', 'sword', 'SW', 'Sw', 'sw', 'Cut', 'cut', 'Slash', 'slash', 'Sl', 'SL', 'sl' },
	spear = { 'Spear', 'spear', 'Sp', 'Lance', 'lance'},
	axe = { 'Axe', 'axe', 'AX', 'Ax', 'ax' },
	whip = { 'Whip', 'whip', 'WP', 'Wp', 'wp' },
	thrown = { 'Thrown', 'thrown', 'Throw', 'throw', 'TH', 'Th', 'th' },
	arrow = { 'Arrows', 'Arrow', 'arrows', 'arrow', 'AR', 'Ar', 'ar', 'Bow', 'bow' },
	fist = { 'Fist', 'fist', 'FS', 'Fs', 'fs' },
	handgun = { 'Handgun', 'handgun', 'HG', 'Hg', 'hg' },
	machinegun = { 'Machinegun', 'machinegun', 'MG', 'Mg', 'mg' },
	shotgun = { 'Shotgun', 'shotgun', 'SG', 'Sg', 'sg' },
	rifle = { 'Rifle', 'rifle', 'RI', 'Ri', 'ri' },
	strike = { 'Strike', 'strike', 'SK', 'Sk', 'sk', 'Bash', 'bash' },
	tech = { 'Tech', 'TECH', 'tech', 'TE', 'Te', 'te', },
	rush = { 'Rush', 'rush', 'RU', 'Ru', 'ru', 'Havoc', 'havoc', 'HV', 'Hv', 'hv' },
	fire = { 'Fire', 'fire', 'FI', 'Fi', 'fi' },
	water = { 'Water', 'water', 'WT', 'Wt', 'wt' },
	earth = { 'Earth', 'earth', 'ER', 'Er', 'er' },
	ice = { 'Ice', 'ice', 'IC', 'Ic', 'ic' },
	elec = { 'Electricity', 'electricity', 'ELEC', 'Elec', 'elec', 'EL', 'El', 'el', 'Lightning', 'lightning', 'LIT', 'Lit', 'lit' },
	wind = { 'Wind', 'wind', 'WI', 'Wi', 'wi' },
	force = { 'Force', 'force' },
	nuclear = { 'Nuclear', 'nuclear', 'Nucl', 'nucl', 'Nuke', 'nuke', 'NC', 'Nc', 'nc' },
	blast = { 'Blast', 'blast', 'BL', 'Bl', 'bl' },
	gravity = { 'Gravity', 'gravity', 'GR', 'Gr', 'gr' },
	psy = { 'Psychic', 'psychic', 'Psy', 'psy', 'Psi', 'psi', 'PS', 'Ps', 'ps' },
	expel = { 'Expel', 'expel', 'EX', 'Ex', 'ex', 'Light', 'light', 'LI', 'Li', 'li', 'Holy', 'holy' },
	miracle = { 'Miracle', 'miracle', 'MI', 'Mi', 'mi' },
	death = { 'Death', 'death', 'DE', 'De', 'de' },
	dark = { 'Darkness', 'darkness', 'Dark', 'dark', 'DK', 'Dk', 'dk' },
	curse = { 'Curse', 'curse', 'CU', 'Cu', 'cu' },
	nerve = { 'Nerve', 'nerve', 'NR', 'Nr', 'nr' },
	mind = { 'Mind', 'mind', 'MN', 'Mn', 'mn' },
	ruin = { 'Ruin', 'ruin' },
	hiero = { '???', 'hiero' },
	mystic = { 'Mystic', 'mystic', 'mys' },
	poison = { 'Poison', 'poison' },
	paralyze = { 'Paralyze', 'paralyze', 'Paralysis', 'paralysis', 'Para', 'para', 'Stun', 'stun' },
	stone = { 'Stone', 'stone', 'Petrify', 'petrify', 'Petrification', 'petrification', 'Petra', 'petra' },
	strain = { 'Strain', 'strain' },
	sleep = { 'Sleep', 'sleep', 'Asleep', 'asleep' },
	charm = { 'Charm', 'charm' },
	mute = { 'Mute', 'mute', 'Seal', 'seal' },
	fear = { 'Fear', 'fear' },
	bomb = { 'Bomb', 'bomb' },
	rage = { 'Rage', 'rage' },
	ko = { 'KO', 'ko', 'instkill', 'kill' },
	panic = { 'Panic', 'panic', 'Confusion', 'confusion', 'Confuse', 'confuse' },
	down = { 'Down', 'down' },
	stbind = { 'St Bind', 'stbind' },
	mabind = { 'Ma Bind', 'mabind' },
	agbind = { 'Ag Bind', 'agbind' },
	racial = { 'Racial', 'racial' },
	alm = { 'Almighty', 'almighty', 'ALM', 'Alm', 'alm', 'AL', 'Al', 'al' },
	inherit = { 'Inherit', 'inherit', 'Inheritance', 'inheritance' },
	moon = { 'Moon', 'moon' },
	forceslot = { 'ForceSlot', 'forceslot', default = '' },
	wild = { 'Wild Effects', 'wild' },
	yen = { 'Yen', 'yen', 'Money', 'money', 'Macca', 'macca', 'Dollar', 'dollar' },
	xp = { 'EXP', 'Exp', 'exp', 'Karma', 'karma', 'XP', 'Xp', 'xp' },
	location = { 'Location', 'location' },
	skills = { 'Skills', 'Skill1', 'Skill 1', 'skills', 'Skill', 'skill' },
	extra = { 'Extra', 'extra', },
	dskills = { 'Skillds', 'SkillD1', 'Skilld1', 'Skilld 1', 'skillds', 'Skilld', 'skilld', 'DSkills', 'dSkills', 'Dskills', 'dskills', 'DSkill', 'dSkill', 'Dskill', 'dskill' },
	fskills = { 'FSkill', 'FSkill1', 'Fskill', 'Fskill1', 'fskill', 'fskill1', 'FSkills', 'Fskills', 'fskills', 'Combo1', 'combo1', 'Combos', 'combos', 'Combo', 'combo' },
	pskills = { 'Passives', 'Passive', 'Passive1', 'passives', 'passive', 'pskill', 'pskills', 'D-Skill1', 'D-Skill', 'D-Skills', 'dskills', 'dskill' },
	askills = { 'AucSkill', 'AucSkills', 'AucSkill1', 'aucskill', 'aucskills', 'askill', 'askills', 'Item1', 'Items', 'items', 'Item', 'item' },
	apskills = { 'AucPassives', 'AucPassive', 'AucPassive1', 'aucpassives', 'aucpassive', 'apskill', 'apskills' },
	cskills = { 'ComboAttacks', 'ComboAttack', 'Comboattack', 'comboattack', 'ComboSkill', 'Comboskill', 'comboskill', 'ChargeAttacks', 'ChargeAttack', 'Chargeattack', 'chargeattack', 'ChargeSkill', 'Chargeskill', 'chargeskill', 'Cskills', 'CSkills', 'cSkills', 'Cskill', 'CSkill', 'cSkill', 'cskill' },
	specialty = { 'specialty', 'Specialty', 'specialties', 'Specialties', },
	reslevels = { 'reslevels', 'reslevel', 'ResistLevel', 'ResistLV', },
	equiptype = { 'EquipType', 'equiptype'},
	equipment = {'equipment', 'Equipment'},
	rarity = {'rarity', 'Rarity'},
	nocat = { 'nocat', 'nocate', },
	essence = { 'Essence', 'essence', 'isEssence', 'IsEssence' },
}

return property_names


-- [[Category:Modules]]
