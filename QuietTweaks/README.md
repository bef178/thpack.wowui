# Quiet Tweaks for vanilla (1.12)

杂项插件合集。轻量，快速，无配置。

应用于[龟龟服](https://turtle-wow.org/)，英文，1.12。

## 功能

### 简单调优项

- pixel-prefect
    - 自动调整UI缩放，使得像素能锐利对齐
    - 不作用于2560x1440分辨率
- add-cloak-checkbox
    - 给3D全身秀添加显示头盔和披风的复选框
- auto-dismount
    - 若因在马上而施法失败，下马
    - 若因未站起而施法失败，站起
- auto-repair
    - 不解释
- auto-sell
    - 不解释
- chat-scroll
    - 允许鼠标滚轮
- exp-speed
    - 显示经验/小时
    - 显示预估升级时间
- format-buff-time
    - 不解释
- minimap-clock
    - 显示当前时间(不要玩得太晚！)
- minimap-zoom
    - 允许鼠标滚轮缩放小地图
- open-all-bags
    - 单击背包时打开/关闭所有包
- pick-action
    - 按住shift时才可从动作条拖出技能
- show-num-available-bag-slots
    - 显示背包剩余容量
- show-num-poison-charges
    - 显示毒药剩余有效次数(Buff)
- show-num-reagents
    - 显示包内施法材料数量(ActionButton)
- switch-chat-type
    - 无输入时按`tab`切换频道
    - 依次为`说` - `小队` - `团队` - `公会` - `说`
- tooltip-healthbar
    - 添加GameTooltip血条的背景、边框和文本
- unitframe/reposition
    - PlayerFrame和TargetFrame现位于居中靠下，便于观察
- unitframe/target-class-icon
    - 在TargetFrame上添加了一个圆形按钮，显示为目标职业，点击可观察目标
- unitframe/target-class-texture
    - PlayerFrame和TargetFrame的名字文本背景色显示为职业颜色

### 新立项

- blessing-bar/aura-bar
    - 一个动作条，持有无需目标的长效buff技能，位于姿态动作条之侧
        - 圣骑士 - 正义之怒
- blessing-bar/blessing-bar
    - 一个动作条，持有可对友方施放的buff技能 - be nice to others
        - 按住shift转为这些技能的高阶版本
        - 圣骑士 - 各种「长效」祝福，i.e. 不含`保护祝福`，`自由祝福`等。
    - 另有seal-bar，持有无需目标的短效buff技能
        - 圣骑士 - 各种圣印
- pda
    - 推荐施法组件，在条件合适时显示相应技能图标，点击可施放
    - pala-a
        - 防骑单刷A怪，实时推荐技能

### 自定义

- x/preset-key-bindings
    - 个人使用的按键设置，默认不启用
