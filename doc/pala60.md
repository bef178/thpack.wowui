# paladin 60

## 机制

- 正义圣印
    - 神圣伤害
    - 可以触发武器特效、武器附魔(含风怒)，可以刷新目标身上的审判效果
    - 受法伤加成(龟服加成系数`0.728`)
    - 无法暴击
- 正义审判
    - 受法伤加成
    - 可以暴击
- 十字军审判
    - 龟服：若武器特效有控制类效果，则不完全享受30倍机率
        - 武器附魔触发的机率也同步减少
- 命令圣印
    - 物理攻击(会被招架闪避格挡)、神圣伤害
    - 受AP加成
- 命令审判
    - 受法伤加成
    - 可以触发武器特效、武器附魔、可以刷新目标身上的审判效果
- 公正审判
    - 龟服：天赋可点出嘲讽效果
- 光明圣印
    - 数值固定，不受法伤、奶伤加成
    - 每次攻击至多生效一次，单次攻击的多次打击**不会多次触发**
- 光明审判
    - 每次攻击至多生效一次，单次攻击的多次打击**不会多次触发**光明审判debuff
- 智慧圣印
    - 机制同光明圣印
- 智慧审判
    - 单次攻击的多次打击**可能多次触发**智慧审判debuff
- 龟服：十字军打击
    - 物理攻击、物理伤害
    - 可以触发武器附魔
    - 不能触发圣印
- 龟服：神圣打击
    - 作用方式类似英勇打击
    - 物理攻击、神圣伤害
    - 受AP加成也受法伤加成
- 奉献
    - 受法伤加成(龟服加成系数`0.119`)
    - 不会暴击

- 惩罚光环
    - 神圣伤害
    - 不会暴击
    - 不受AP加成、不受法伤加成

## 天赋

### 刷怪练级坦三大，小防骑

[龟服 5/29/17](https://talents.turtle-wow.org/paladin/5-5IVL0JU-5FI0CC)

此为纯PVE天赋。出强化正义之怒、强化公正圣印，可坦三大。因强化公正圣印带有嘲讽，故出强化审判。

惩罚光环，庇护祝福，神圣之盾，奉献，智慧审判，光明圣印。装备智耐板甲，武器攻速越快越好。带有至少一个科技道具，如[电气缠绕之戒]。1级十字军打击、1级神圣打击可毛回蓝。奉献伤害应占五成以上。

### 神圣震怒

[龟服 31/0/20](https://talents.turtle-wow.org/paladin/Z5J0U6V-0-5F0VE)

又名：法伤骑。用双手武器，神恩，神圣震击+神圣打击+正义审判，三爆是可以秒人的。

### 大领主

[龟服 13/7/31](https://talents.turtle-wow.org/paladin/UU12-52-5F1VE36V)

## 装备

### 三大时期

- AH
    - 光铸：腕手腰
    - 烈焰披风
    - 乌瑟尔的力量
    - 野性之皮
- 通灵学院
    - 光铸：头
    - 亡者之骨(5)：胸手腰腿脚
    - 皇家肩甲
    - 近卫臂甲
    - 神权腰带
    - 食尸鬼皮护腿
- 斯坦索姆
    - 光铸：腿脚
    - 生命项链
    - 尊贵法袍
    - 翠绿足垫
    - 石像鬼斗篷
- 黑石深渊
    - 阿格曼奇之戒
    - 复苏之风
    - 传令官之手
    - 恩赐之锤
    - 索瑞森皇家节杖
- 黑下
    - 红木之环
- 黑上
    - 光铸：胸肩
    - 石楠之环
    - 咆哮之牙
- 任务奖励
    - 天选者印记
    - 黎明守护者

### 衣品：美

```
/equip 斩龙者护肩
/equip 暴君胸甲
/equip 野熊之蛮兽护臂
/equip 哈库的板甲手套
/equip 杉德尔船长的腰带
/equip 典狱官热裤
/equip 夜枭之血纹长靴
/equip 命运
```

## 宏

驱邪
```
/startattack
#showtooltip
/cast [nomod] 驱邪术; 神圣愤怒
```

奉献
```
#showtooltip
/cast [nomod] 奉献; 奉献(等级 1)
```

审判
```
/dismount
#showtooltip
/cast [mod] 命令圣印
/stopmacro [mod]
/startattack
/castsequence reset=1 审判, 命令圣印
```

我给你讲个笑话
```
#showtooltip
/cast [mod:alt] 圣盾术; 愤怒之锤
```

制裁
```
#showtooltip
/cast [@mouseover,exists][] 制裁之锤
```

1闪
```
/stand
/dismount
#showtooltip
/cast [mod:alt,@player] [@mouseover,exists] [] 圣光闪现
```

小闪
```
#showtooltip
/cast [mod:alt,@player] [@mouseover,exists] [] 圣光闪现(等级 1)
```

2清
```
/stand
/dismount
#showtooltip
/cast [mod:alt,@player] [@mouseover,exists] [] 清洁术
```

3大光
```
#showtooltip
/cast [mod:alt,@player] [@mouseover,exists] [] 圣光术
```

## leveling

- lv30
    - 光明圣印
- lv38
    - 智慧圣印
- lv51
    - 单刷 Sorrow Hill
- lv52
    - AH购买T0散件

## Appendix

### 键位原则

b 重要但低频的技能

c 读条

e aoe

f 高频攻击技能

r 瞬发/dot

g 最重要的控制

t 短效失能

v 长效失能

h 治疗/恢复道具

q 终结技

alt-q 自保

x 打断

z 位移技能

1 快速治疗

2 瞬发/dot

3 强效治疗

mouse4(backward) 饰品/自利

mouse5(forward) 自动前进

alt-w 自动前进

shift-s 上马

alt-a 宝宝攻击

f1 角色

f2 地图

f3 背包

f9 开关姓名板

f10 系统菜单

### 经典物品

- [平静之剑]
    - [以圣光之名]任务奖励
- [征服者之剑]
    - [与圣光同在]任务奖励
- [灵巧秒表]
    - [至关重要的冷却剂]系列任务奖励
- [雷酒靴中瓶]
    - [琥珀酒]系列任务奖励
- [天选者印记]
    - 凄凉之地，[贱民的指引]任务奖励
- [痛击之刃]
    - [大地的污染]任务奖励
- [黑手饰物] | [比斯巨兽之眼]
    - [达基萨斯将军之死]任务奖励
- [欧莫克的瘦身腰带]
    - 黑石塔，[比修的装置]系列任务奖励
- [黎明守护者]
    - 东瘟疫之地，[档案管理员]系列任务奖励

- [乌瑟尔的力量]
    - 世界掉落
- [风暴护手]
    - 锻造
- [野性之皮]
    - 制皮
- [冒渎圣契]
    - 阿塔哈卡神庙，[预言者迦玛兰]掉落
- [希望圣契]
    - 厄运之槌，[伊萨莉恩]掉落
- [意志之力]
    - 黑石深渊，[安格弗将军]掉落
- [正义之手]
    - 黑石深渊，[达格兰·索瑞森大帝]掉落
- [阿格曼奇之戒]
    - 黑石深渊，[傀儡统帅阿格曼奇]掉落

### 经典任务

- [莱恩的净化]
- [月神的镰刀]
- [失踪的使节]
- [星，手，心]
- [科泰罗的谜题]
- [精灵龙的自由]
- [无人知晓的秘密]
- [小帕米拉]
- [爱与家庭]
    - 是大领主就选[闪光白金战锤]
- [重铸秩序]
- [索瑞森废墟]
    - 救公主

#### 开门任务

- 黑石深渊开门任务
    - [黑铁的遗产]
        - 灵魂状态接
    - item:暗炉钥匙
- 通灵学院，骷髅钥匙
    - [战斗的号角：瘟疫之地！]
        - NPC:公告员古德曼
- 斯坦索姆，城市大门钥匙
    - 巴瑟拉斯镇长掉落
- 黑上(Upper Blackrock Spire)，晋升印章
    - 始于黑下小怪掉落[原始晋升印章]
- OL，龙火护符
    - [黑龙的危胁]
- MC开门任务
    - [熔火之心的传送门]
- MC灭火任务
    - NPC:[海达克西斯公爵]
- 黑翼开门任务
    - [黑手的命令]