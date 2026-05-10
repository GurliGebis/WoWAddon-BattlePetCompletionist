--[[
    Copyright (C) 2023-2026 GurliGebis

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]

local addonName, _ = ...
local L_Broker = LibStub("AceLocale-3.0"):NewLocale(addonName .. "_Broker", "zhCN")

if L_Broker then
-- 数据代理（Broker）相关
L_Broker["Battle Pet Completionist"] = "战斗宠物收藏家"
L_Broker["Battle Pets"] = "战斗宠物"
L_Broker["Left Click to toggle goal tracker"] = "|cffffff00左键点击|r 切换目标追踪器"
L_Broker["Met goal"] = "达成目标: %d/%d"
L_Broker["No pets found for current zone"] = "当前区域未发现可收集的宠物"
L_Broker["Right Click for options"] = "|cffffff00右键点击|r 打开设置选项"
L_Broker["Suffix - Collected"] = "已收集"
L_Broker["Suffix - Max Collected"] = "收集已满"
L_Broker["Suffix - Max Rare"] = "精良收集已满"
L_Broker["Suffix - Rare"] = "精良"

end

local L_Capture = LibStub("AceLocale-3.0"):NewLocale(addonName .. "_Capture", "zhCN")

if L_Capture then
-- 宠物捕捉相关
L_Capture["Rare pet upgrade found"] = "发现可升级的精良宠物"
L_Capture["Rare pet upgrades found"] = "发现多个可升级的精良宠物"
L_Capture["Uncollected pet found"] = "发现未收集的宠物！"
L_Capture["Uncollected pets found"] = "发现多个未收集的宠物！"

end

local L_Combat = LibStub("AceLocale-3.0"):NewLocale(addonName .. "_Combat", "zhCN")

if L_Combat then
-- 战斗相关
L_Combat["Friend accepted"] = "%s 已接受你的互助请求|n|n请等待对方放弃战斗"
L_Combat["Friend declined"] = "%s 拒绝了你的互助请求"
L_Combat["Friend has pets"] = "你的队友（%s - 区域: %s）为你提供以下战斗宠物。|n|n点击“接受”后，将创建TomTom导航点并发送通知。|n|n需求宠物: %s"
L_Combat["Friend needs pets"] = "你的队友（%s）需要你正在对战的一只或多只宠物。|n|n是否愿意向其提供这些宠物并发送你的位置？|n|n所需宠物: %s"
L_Combat["No pet upgrades, forfeit?"] = "无可用的宠物品质升级（或低于设定起始品质）|n|n是否放弃战斗？"
L_Combat["Tomtom Waypoint Text"] = "战斗宠物收藏家好友 - %s"

end

local L_Config = LibStub("AceLocale-3.0"):NewLocale(addonName .. "_Config", "zhCN")

if L_Config then
-- 设置界面相关
L_Config["Add a suffix to the displayed text"] = "为显示的文本添加进度后缀"
L_Config["Broker Goal - Collect at least one"] = "至少一只"
L_Config["Broker Goal - Collect at least one rare"] = "至少一只精良"
L_Config["Broker Goal - Collect maximum amount"] = "收集最大数量"
L_Config["Broker Goal - Collect maximum amount rare"] = "收集精良最大数量"
L_Config["Combat mode"] = "战斗模式"
L_Config["Combat Mode - Forfeit"] = "提示投降"
L_Config["Combat Mode - Help a Friend"] = "队友互助"
L_Config["Combat Mode - None"] = "无"
L_Config["Config Section - Battle Pet Completionist"] = "战斗宠物收藏家"
L_Config["Description - Classic settings"] = "怀旧服设置"
L_Config["Description - Combat settings"] = "战斗设置"
L_Config["Description - Data Broker settings"] = "Data Broker 模块设置"
L_Config["Description - Integration settings"] = "集成设置"
L_Config["Description - Map pins settings"] = "地图标记设置"
L_Config["Description - Minimap settings"] = "小地图设置"
L_Config["Description - Objective Tracker settings"] = "目标追踪设置"
L_Config["Description - Rare Upgrade"] = "精良品质升级"
L_Config["Description - Tooltip and notification settings"] = "提示与通知设置"
L_Config["Display Goal"] = "显示收集目标"
L_Config["Enable Objective Tracker"] = "启用目标追踪"
L_Config["Enable the minimap icon"] = "启用小地图按钮"
L_Config["Enable tooltips for pet cages and auction listings"] = "启用宠物笼和拍卖行宠物提示"
L_Config["Enter part the name to filter by"] = "输入宠物名称关键词进行筛选"
L_Config["Forfeit prompt unless"] = "以下情况不弹出投降提示"
L_Config["Forfeit Prompt Unless - Missing"] = "有未收集"
L_Config["Forfeit Prompt Unless - Not maximum amount collected"] = "收集未满"
L_Config["Forfeit Prompt Unless - Not maximum rare collected"] = "精良收集未满"
L_Config["Forfeit Prompt Unless - Not rare"] = "非精良"
L_Config["Forfeit threshold"] = "投降起始品质"
L_Config["Forfeit Threshold - Common"] = "普通"
L_Config["Forfeit Threshold - Poor"] = "弱小"
L_Config["Forfeit Threshold - Rare"] = "精良"
L_Config["Forfeit Threshold - Uncommon"] = "优秀"
L_Config["Header - Combat"] = "战斗相关"
L_Config["Header - Display"] = "显示相关"
L_Config["Header - Integrations"] = "插件集成"
L_Config["Header - Map pins"] = "地图标记"
L_Config["Header - Objective Tracker"] = "目标追踪"
L_Config["Header - Tooltips and Notifications"] = "提示与通知"
L_Config["How to function when pet battles are started"] = "宠物对战模式"
L_Config["Include goal text"] = "包含目标文本"
L_Config["Map Pin Filter - All"] = "全部宠物"
L_Config["Map Pin Filter - Missing"] = "未收集的宠物"
L_Config["Map Pin Filter - Name filter"] = "名称筛选"
L_Config["Map Pin Filter - None"] = "无"
L_Config["Map Pin Filter - Not maximum amount collected"] = "收集未满的宠物"
L_Config["Map Pin Filter - Not maximum rare collected"] = "精良收集未满的宠物"
L_Config["Map Pin Filter - Not rare"] = "还不是精良的宠物"
L_Config["Map pin icon type"] = "图标类型"
L_Config["Map Pin Icon Type - Pet Family"] = "宠物类型"
L_Config["Map Pin Icon Type - Pet Icon"] = "宠物种类"
L_Config["Map pin size"] = "图标大小"
L_Config["Map Pin Size - Extra small"] = "极小"
L_Config["Map Pin Size - Large"] = "大"
L_Config["Map Pin Size - Medium"] = "中"
L_Config["Map Pin Size - Small"] = "小"
L_Config["Map pin sources"] = "显示图标的宠物来源"
L_Config["Map pins to include"] = "图标包括"
L_Config["Notify if a Rare upgrade is found to an existing pet"] = "发现已有宠物可升级为精良品质时发送通知"
L_Config["Notify on Rare upgrade"] = "精良品质升级通知"
L_Config["Objective Tracker - All pets"] = "全部宠物"
L_Config["Objective Tracker - Missing pets only"] = "仅未收集的宠物"
L_Config["Partial pet name"] = "宠物名称关键词"
L_Config["Pets to show in tracker"] = "追踪器中显示的宠物"
L_Config["SHIFT + left clicking a map pin creates a TomTom waypoint"] = "按住 SHIFT 左键点击地图标记可创建 TomTom 导航点"
L_Config["Show a notification window when one or more uncollected pets can be captured"] = "当发现可捕捉的未收集宠物时显示通知窗口"
L_Config["Show a tooltip when hovering over a Pet Cage item or a pet in the auction UI"] = "鼠标悬停在宠物笼或拍卖行宠物上时显示提示"
L_Config["Show an icon on the minimap"] = "在小地图上显示插件按钮"
L_Config["Show battle pets in the objective tracker"] = "在目标追踪中显示战斗宠物收集进度"
L_Config["Show notification when uncollected pets are in the enemy team"] = "敌方队伍中有未收集宠物时发送通知"
L_Config["The condition for when to not forfeit"] = "不触发投降提示的条件"
L_Config["The goal to track in the data source"] = "在数据来源中追踪的收集目标"
L_Config["The kind of icon to show in the pins on the map"] = "宠物地图标记图标的类型"
L_Config["The size of the pins on the map"] = "宠物地图标记图标的大小"
L_Config["The sources for pets to show on the map"] = "此来源的宠物可在地图上显示"
L_Config["The threshold for when to always suggest forfeit"] = "始终建议标记投降的起始宠物品质"
L_Config["Tomtom"] = "TomTom 导航插件"
L_Config["Use Retail data in Classic"] = "在怀旧服使用正式服数据"
L_Config["Use the data from Retail in Classic"] = "在怀旧服环境下加载正式服的宠物数据"
L_Config["Which map pins should be shown on the map"] = "要在地图上显示的宠物"
L_Config["Which pets to show in the objective tracker"] = "要在目标追踪中显示的宠物"

end

local L_GoalTracker = LibStub("AceLocale-3.0"):NewLocale(addonName .. "_GoalTracker", "zhCN")

if L_GoalTracker then
-- 目标追踪器相关
L_GoalTracker["BattlePets Goal Tracker"] = "战斗宠物收集目标追踪器"
L_GoalTracker["Collected"] = "%d/%d 已收集"
L_GoalTracker["Uncollected"] = "%d/%d 未收集"

end

local L_Map = LibStub("AceLocale-3.0"):NewLocale(addonName .. "_Map", "zhCN")

if L_Map then
-- 地图相关
L_Map["Collected"] = "已收集: %s"
L_Map["Dropdown Headline"] = "战斗宠物收藏家:"
L_Map["No pet data loaded! Please install the Battle Pet Completionist data addon BattlePetCompletionist_PetData or disable this addon."] = "未加载宠物数据！|n|n请安装 Battle Pet Completionist 的数据插件 BattlePetCompletionist_PetData，或禁用本插件。"
L_Map["Show Battle Pets"] = "显示战斗宠物"
L_Map["Tracking disabled"] = "战斗宠物收藏家 - 追踪已禁用"
L_Map["Tracking enabled"] = "战斗宠物收藏家 - 追踪已启用"

end

local L_ObjectiveTracker = LibStub("AceLocale-3.0"):NewLocale(addonName .. "_ObjectiveTracker", "zhCN")

if L_ObjectiveTracker then
-- 目标追踪集成相关
L_ObjectiveTracker["Battle Pets"] = "战斗宠物"
L_ObjectiveTracker["Battle Pets in %s"] = "%s 区域的战斗宠物"
L_ObjectiveTracker["current zone"] = "当前区域"

end
