# paladin 60

## 机制

- 正义圣印
    - 神圣伤害
    - 可以触发武器特效、武器附魔(含风怒)，可以刷新目标身上的审判效果
    - 受法伤加成(龟服加成系数`0.728`)
    - 无法暴击
- 正义审判
    - 受法伤加成
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
    - 每次攻击至多生效一次，单次攻击的多次打击不会多次触发
- 光明审判
    - 每次攻击至多生效一次，单次攻击的多次打击不会多次触发光明审判debuff
- 智慧圣印
    - 机制同光明圣印
- 智慧审判
    - 单次攻击的多次打击可能多次触发智慧审判debuff
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

[龟服 31/0/20](https://talents.turtle-wow.org/paladin/Z5J0U6V-0-5F1PE)

又名：法伤骑。用双手武器，神恩+震击+神圣打击+正义审判，三爆是可以秒人的。

[龟服 31/7/13](https://talents.turtle-wow.org/paladin/Z5J0U6V-52-5F01C)

同上，不过将定罪和以眼还眼换成延长自由祝福时间。

### 大领主

[龟服 13/7/31](https://talents.turtle-wow.org/paladin/UU12-52-5F1VE36V)

## 宏

2清
```
/stand
/dismount
#showtooltip
/cast [mod:alt,@player] [@mouseover,exists,noharm,nodead] [] 清洁术
/cast [mod:alt,@player] [@mouseover,exists,noharm,nodead] [] 净化术
```

e奉献
```
#showtooltip
/cast [nomod] 奉献; 奉献(等级 1)
```

g制裁
```
#showtooltip
/cast [@mouseover,exists,harm][@target,exists,harm] Hammer of Justice;
/cast [@mouseover,exists,help][@target,exists,help] Blessing of Protection
```

q我给你讲个笑话
```
#showtooltip
/cast [nomod] Hammer of Wrath
/cast [mod] Divine Shield
/cast [mod] Divine Protection
/use [mod] Hearthstone
```

## Gaming

### 练级

| Level | |
| -: | :- |
|  5 | 北郡毕业 |
| 40 | ~~quest:[以圣光之名](https://www.wowhead.com/classic/cn/quest=1053) for [[平静之剑]](https://www.wowhead.com/classic/cn/item=6829)~~ |
| 42 | ~~quest:[与圣光同在](https://www.wowhead.com/classic/cn/quest=3636) for [[征服者之剑]](https://www.wowhead.com/classic/cn/item=10823)~~ |
| 44 | ~~quest:[琥珀酒](https://www.wowhead.com/classic/cn/quest=53) for [[雷酒靴中瓶]](https://www.wowhead.com/classic/cn/item=744)~~
| 45 | quest:[不祥的感觉](https://www.wowhead.com/classic/cn/quest=778) for [[灵巧秒表]](https://www.wowhead.com/classic/cn/item=2820)
| 47 | AH for [[乌瑟尔的力量]](https://www.wowhead.com/classic/cn/item=11302) |
| 48 | quest:[贱民的指引](https://www.wowhead.com/classic/cn/quest=7067) for [[天选者印记]](https://www.wowhead.com/classic/cn/item=17774) |
| 51 | ~~quest:[大地的污染](https://www.wowhead.com/classic/cn/quest=7065) for [[痛击之刃]](https://www.wowhead.com/classic/cn/item=17705)~~ |
| 51 | 单刷 Sorrow Hill |
| 52 | AH for [[光铸护腕]](https://www.wowhead.com/classic/cn/item=16722) |
| 53 | AH for [[光铸腰带]](https://www.wowhead.com/classic/cn/item=16723) |
| 54 | AH for [[光铸护手]](https://www.wowhead.com/classic/cn/item=16724) |

#### 经典任务与物品

- [莱恩的净化]
- [月神的镰刀]
- [失踪的使节]
- [星，手，心]
- [科泰罗的谜题]
- [精灵龙的自由]
- [无人知晓的秘密]
- [小帕米拉]
- [爱与家庭]
- quest:[第一个和最后一个](https://www.wowhead.com/classic/cn/quest=6182)
    - 纳萨诺斯·玛瑞斯
- quest:[索瑞森废墟](https://www.wowhead.com/classic/cn/quest=3702)
    - 救公主
- [[冒渎圣契]](https://www.wowhead.com/classic/cn/item=220605) - 神庙
- [保护者之剑] - 银翼声望

### Pre-raid

#### 装备

- AH
    - [烈焰披风](https://database.turtle-wow.org/?item=3475)
    - [风暴护手](https://database.turtle-wow.org/?item=12632)
    - [野性之皮](https://database.turtle-wow.org/?item=18510)
- 任务奖励
    - [黑手饰物](https://database.turtle-wow.org/?item=13965)
    - [黎明守护者](https://database.turtle-wow.org/?item=13243)
    - [欧莫克的瘦身腰带](https://database.turtle-wow.org/?item=13959)
- 通灵学院
    - 光铸：头
    - 亡者之骨(5)：胸手腰腿脚
    - [皇家肩甲](https://database.turtle-wow.org/?item=14548)
    - [近卫臂甲](https://database.turtle-wow.org/?item=13969)
    - [神权腰带](https://database.turtle-wow.org/?item=18702)
    - [食尸鬼皮护腿](https://database.turtle-wow.org/?item=18682)
- 斯坦索姆
    - 光铸：腿脚
    - [生命项链](https://database.turtle-wow.org/?item=18723)
    - [尊贵法袍](https://database.turtle-wow.org/?item=13346)
    - [翠绿足垫](https://database.turtle-wow.org/?item=13954)
    - [石像鬼斗篷](https://database.turtle-wow.org/?item=13397)
- 黑石深渊
    - 安格弗将军
        - [[意志之力]](https://www.wowhead.com/classic/cn/item=11810)
    - 傀儡统帅阿格曼奇
        - [[阿格曼奇之戒]](https://www.wowhead.com/classic/cn/item=11669)
        - [[复苏之风]](https://www.wowhead.com/classic/cn/item=11819)
    - 达格兰·索瑞森大帝
        - [[正义之手]](https://www.wowhead.com/classic/cn/item=11815)
        - [[索瑞森皇家节杖]](https://www.wowhead.com/classic/cn/item=11928)
    - [[传令官之手]](https://www.wowhead.com/classic/cn/item=12554)
    - [[恩赐之锤]](https://www.wowhead.com/classic/cn/item=11923)
- 黑上
    - 光铸：胸肩
    - 杰德
        - [[石楠之环]](https://www.wowhead.com/classic/cn/item=12930)
    - 达基萨斯将军
        - [[咆哮之牙]](https://www.wowhead.com/classic/cn/item=13141)
- 黑下
    - 乌洛克
        - [[红木之环]](https://www.wowhead.com/classic/cn/item=13178)
- 厄运之槌
    - 伊萨莉恩
        - [[希望圣契]](https://www.wowhead.com/classic/cn/item=22401)

#### 开门任务

- 黑石深渊，[[暗炉钥匙]](https://www.wowhead.com/classic/cn/item=11000)
- 通灵学院，[[骷髅钥匙]](https://www.wowhead.com/classic/cn/item=13704)
- 斯坦索姆，[[城市大门钥匙]](https://www.wowhead.com/classic/cn/item=12382)
- 黑上(Upper Blackrock Spire)，[[晋升印章]](https://www.wowhead.com/classic/cn/item=12344)
- 黑龙，[[龙火护符]](https://www.wowhead.com/classic/cn/item=16309)
- MC，quest:[熔火之心的传送门](https://www.wowhead.com/classic/cn/quest=7848)
- MC灭火，NPC:[海达克西斯公爵](https://www.wowhead.com/classic/cn/npc=13278)
- 黑翼，quest:[黑手的命令](https://www.wowhead.com/classic/cn/quest=7761)

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
