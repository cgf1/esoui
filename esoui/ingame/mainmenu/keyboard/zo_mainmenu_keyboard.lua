local MainMenu_Keyboard = ZO_CallbackObject:Subclass()

-- If you disable a category in MainMenu.lua you should also disable it in PlayerMenu.lua
local CATEGORY_LAYOUT_INFO =
{
    [MENU_CATEGORY_MARKET] =
    {
        binding = "TOGGLE_MARKET",
        categoryName = SI_MAIN_MENU_MARKET,

        descriptor = MENU_CATEGORY_MARKET,
        normal = "EsoUI/Art/MainMenu/menuBar_market_up.dds",
        pressed = "EsoUI/Art/MainMenu/menuBar_market_down.dds",
        disabled = "EsoUI/Art/MainMenu/menuBar_market_disabled.dds",
        highlight = "EsoUI/Art/MainMenu/menuBar_market_over.dds",
        --override the sizes set by AddCategories because these icons are twice as big as the others
        overrideNormalSize = 102,
        overrideDownSize = 128,

        onInitializeCallback =  function(button)
                                    local animationTexture = button:GetNamedChild("ImageAnimation")
                                    animationTexture:SetTexture("EsoUI/Art/MainMenu/menuBar_market_animation.dds")
                                    animationTexture:SetHidden(false)
                                    animationTexture:SetBlendMode(TEX_BLEND_MODE_ADD)
                                    button.animationTexture = animationTexture

                                    button.timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_CrownStoreShineAnimation", animationTexture)
                                    button.timeline:PlayFromStart()

                                    local isSubscriber = IsESOPlusSubscriber()
                                    local membershipControl = button:GetNamedChild("Membership")
                                    local remainingCrownsControl = button:GetNamedChild("RemainingCrowns")
                                    membershipControl:SetHidden(not isSubscriber)
                                    membershipControl:SetText(GetString(SI_ESO_PLUS_TITLE))
                                    remainingCrownsControl:SetHidden(false)
                                    local currentBalance = GetPlayerCrowns()
                                    remainingCrownsControl:SetText(ZO_CommaDelimitNumber(currentBalance))
                                    button:RegisterForEvent(EVENT_CROWN_UPDATE, function(currencyAmount)
                                                                                                    local currentBalance = GetPlayerCrowns()
                                                                                                    remainingCrownsControl:SetText(ZO_CommaDelimitNumber(currentBalance))
                                                                                                 end)
                                end,
        onResetCallback =   function(button)
                                button.animationTexture:SetHidden(true)
                                button.timeline:PlayInstantlyToStart()
                                button.timeline:Stop()
                                button:UnregisterForEvent(EVENT_CROWN_UPDATE)
                                button:GetNamedChild("Membership"):SetHidden(true)
                                button:GetNamedChild("RemainingCrowns"):SetHidden(true)
                            end,
        onButtonStatePressed =  function(button)
                                    button.animationTexture:SetHidden(true)
                                    button.timeline:PlayInstantlyToStart()
                                button.timeline:Stop()
                                end,
        onButtonStateNormal =   function(button)
                                    button.animationTexture:SetHidden(false)
                                    button.timeline:PlayFromStart()
                                end,
        onButtonStateDisabled = function(button)
                                    button.animationTexture:SetHidden(true)
                                    button.timeline:PlayInstantlyToStart()
                                    button.timeline:Stop()
                                end,
    },
    [MENU_CATEGORY_CROWN_CRATES] =
    {
        binding = "TOGGLE_CROWN_CRATES",
        categoryName = SI_MAIN_MENU_CROWN_CRATES,
        scene = "crownCrateKeyboard",
        previousButtonExtraPadding = 10,
        barPadding = 20,
        hideCategoryBar = true,

        descriptor = MENU_CATEGORY_CROWN_CRATES,
        normal = "EsoUI/Art/MainMenu/menuBar_crownCrates_up.dds",
        pressed = "EsoUI/Art/MainMenu/menuBar_crownCrates_down.dds",
        disabled = "EsoUI/Art/MainMenu/menuBar_crownCrates_disabled.dds",
        highlight = "EsoUI/Art/MainMenu/menuBar_crownCrates_over.dds",
        --override the sizes set by AddCategories because these icons are twice as big as the others
        overrideNormalSize = 102,
        overrideDownSize = 128,
        
        disableWhenDead = true,
        disableWhenReviving = true,
        disableWhenSwimming = true,
        disableWhenWerewolf = true,

        indicators = function()
            if GetNumOwnedCrownCrateTypes() > 0 then
                return { ZO_KEYBOARD_NEW_ICON }
            end
        end,
        visible = function()
            --An unusual case, we don't want to blow away this option if you're already in the scene when it's disabled
            --Crown crates will properly refresh again when it closes its scene
            return CanInteractWithCrownCratesSystem() or SYSTEMS:IsShowing("crownCrate")
        end,
    },
    [MENU_CATEGORY_INVENTORY] =
    {
        binding = "TOGGLE_INVENTORY",
        categoryName = SI_MAIN_MENU_INVENTORY,

        descriptor = MENU_CATEGORY_INVENTORY,
        normal = "EsoUI/Art/MainMenu/menuBar_inventory_up.dds",
        pressed = "EsoUI/Art/MainMenu/menuBar_inventory_down.dds",
        disabled = "EsoUI/Art/MainMenu/menuBar_inventory_disabled.dds",
        highlight = "EsoUI/Art/MainMenu/menuBar_inventory_over.dds",

        indicators = function()
            if SHARED_INVENTORY then
                if SHARED_INVENTORY:AreAnyItemsNew(nil, nil, BAG_BACKPACK, BAG_VIRTUAL) then
                    return { ZO_KEYBOARD_NEW_ICON }
                end
            end
        end,
    },
    [MENU_CATEGORY_CHARACTER] =
    {
        binding = "TOGGLE_CHARACTER",
        categoryName = SI_MAIN_MENU_CHARACTER,

        descriptor = MENU_CATEGORY_CHARACTER,
        normal = "EsoUI/Art/MainMenu/menuBar_character_up.dds",
        pressed = "EsoUI/Art/MainMenu/menuBar_character_down.dds",
        disabled = "EsoUI/Art/MainMenu/menuBar_character_disabled.dds",
        highlight = "EsoUI/Art/MainMenu/menuBar_character_over.dds",
    },
    [MENU_CATEGORY_SKILLS] =
    {
        binding = "TOGGLE_SKILLS",
        categoryName = SI_MAIN_MENU_SKILLS,

        descriptor = MENU_CATEGORY_SKILLS,
        normal = "EsoUI/Art/MainMenu/menuBar_skills_up.dds",
        pressed = "EsoUI/Art/MainMenu/menuBar_skills_down.dds",
        disabled = "EsoUI/Art/MainMenu/menuBar_skills_disabled.dds",
        highlight = "EsoUI/Art/MainMenu/menuBar_skills_over.dds",

        indicators = function()
            if NEW_SKILL_CALLOUTS and NEW_SKILL_CALLOUTS:AreAnySkillLinesNew() then
                return { ZO_KEYBOARD_NEW_ICON }
            end
        end,
    },
    [MENU_CATEGORY_CHAMPION] =
    {
        binding = "TOGGLE_CHAMPION",
        categoryName = SI_MAIN_MENU_CHAMPION,

        descriptor = MENU_CATEGORY_CHAMPION,
        normal = "EsoUI/Art/MainMenu/menuBar_champion_up.dds",
        pressed = "EsoUI/Art/MainMenu/menuBar_champion_down.dds",
        highlight = "EsoUI/Art/MainMenu/menuBar_champion_over.dds",
        indicators = function()
            if CHAMPION_PERKS then
                local indicators = {}
                if CHAMPION_PERKS:IsChampionSystemNew() then
                    table.insert(indicators, ZO_KEYBOARD_NEW_ICON)
                end
                if CHAMPION_PERKS:HasAnySpendableUnspentPoints() then
                    table.insert(indicators, "EsoUI/Art/MainMenu/menuBar_pointsToSpend.dds")
                end
                return indicators
            end
        end,
        hideCategoryBar = true,
        visible = function()
            return IsChampionSystemUnlocked()
        end,
    },
    [MENU_CATEGORY_JOURNAL] =
    {
        binding = "TOGGLE_JOURNAL",
        categoryName = SI_MAIN_MENU_JOURNAL,

        descriptor = MENU_CATEGORY_JOURNAL,
        normal = "EsoUI/Art/MainMenu/menuBar_journal_up.dds",
        pressed = "EsoUI/Art/MainMenu/menuBar_journal_down.dds",
        disabled = "EsoUI/Art/MainMenu/menuBar_journal_disabled.dds",
        highlight = "EsoUI/Art/MainMenu/menuBar_journal_over.dds",
    },
    [MENU_CATEGORY_COLLECTIONS] =
    {
        binding = "TOGGLE_COLLECTIONS_BOOK",
        categoryName = SI_MAIN_MENU_COLLECTIONS,

        descriptor = MENU_CATEGORY_COLLECTIONS,
        normal = "EsoUI/Art/MainMenu/menuBar_collections_up.dds",
        pressed = "EsoUI/Art/MainMenu/menuBar_collections_down.dds",
        disabled = "EsoUI/Art/MainMenu/menuBar_collections_disabled.dds",
        highlight = "EsoUI/Art/MainMenu/menuBar_collections_over.dds",

        indicators = function()
            if COLLECTIONS_BOOK and COLLECTIONS_BOOK:HasAnyNewCollectibles() then
                return { ZO_KEYBOARD_NEW_ICON }
            end
        end,
    },
    [MENU_CATEGORY_MAP] =
    {
        binding = "TOGGLE_MAP",
        categoryName = SI_MAIN_MENU_MAP,

        descriptor = MENU_CATEGORY_MAP,
        normal = "EsoUI/Art/MainMenu/menuBar_map_up.dds",
        pressed = "EsoUI/Art/MainMenu/menuBar_map_down.dds",
        disabled = "EsoUI/Art/MainMenu/menuBar_map_disabled.dds",
        highlight = "EsoUI/Art/MainMenu/menuBar_map_over.dds",
    },
    [MENU_CATEGORY_GROUP] =
    {
        binding = "TOGGLE_GROUP",
        categoryName = SI_MAIN_MENU_GROUP,

        descriptor = MENU_CATEGORY_GROUP,
        normal = "EsoUI/Art/MainMenu/menuBar_group_up.dds",
        pressed = "EsoUI/Art/MainMenu/menuBar_group_down.dds",
        disabled = "EsoUI/Art/MainMenu/menuBar_group_disabled.dds",
        highlight = "EsoUI/Art/MainMenu/menuBar_group_over.dds",
    },
    [MENU_CATEGORY_CONTACTS] =
    {
        binding = "TOGGLE_CONTACTS",
        categoryName = SI_MAIN_MENU_CONTACTS,

        descriptor = MENU_CATEGORY_CONTACTS,
        normal = "EsoUI/Art/MainMenu/menuBar_social_up.dds",
        pressed = "EsoUI/Art/MainMenu/menuBar_social_down.dds",
        disabled = "EsoUI/Art/MainMenu/menuBar_social_disabled.dds",
        highlight = "EsoUI/Art/MainMenu/menuBar_social_over.dds",
    },
    [MENU_CATEGORY_GUILDS] =
    {
        binding = "TOGGLE_GUILDS",
        categoryName = SI_MAIN_MENU_GUILDS,

        descriptor = MENU_CATEGORY_GUILDS,
        normal = "EsoUI/Art/MainMenu/menuBar_guilds_up.dds",
        pressed = "EsoUI/Art/MainMenu/menuBar_guilds_down.dds",
        disabled = "EsoUI/Art/MainMenu/menuBar_guilds_disabled.dds",
        highlight = "EsoUI/Art/MainMenu/menuBar_guilds_over.dds",
    },
    [MENU_CATEGORY_ALLIANCE_WAR] =
    {
        binding = "TOGGLE_ALLIANCE_WAR",
        categoryName = SI_MAIN_MENU_ALLIANCE_WAR,

        descriptor = MENU_CATEGORY_ALLIANCE_WAR,
        normal = "EsoUI/Art/MainMenu/menuBar_ava_up.dds",
        pressed = "EsoUI/Art/MainMenu/menuBar_ava_down.dds",
        disabled = "EsoUI/Art/MainMenu/menuBar_ava_disabled.dds",
        highlight = "EsoUI/Art/MainMenu/menuBar_ava_over.dds",
    },
    [MENU_CATEGORY_MAIL] =
    {
        binding = "TOGGLE_MAIL",
        categoryName = SI_MAIN_MENU_MAIL,
        scene = "mailInbox",

        descriptor = MENU_CATEGORY_MAIL,
        normal = "EsoUI/Art/MainMenu/menuBar_mail_up.dds",
        pressed = "EsoUI/Art/MainMenu/menuBar_mail_down.dds",
        disabled = "EsoUI/Art/MainMenu/menuBar_mail_disabled.dds",
        highlight = "EsoUI/Art/MainMenu/menuBar_mail_over.dds",
        disableWhenDead = true,
        disableWhenInCombat = true,
        disableWhenReviving = true,
    },
    [MENU_CATEGORY_NOTIFICATIONS] =
    {
        binding = "TOGGLE_NOTIFICATIONS",
        categoryName = SI_MAIN_MENU_NOTIFICATIONS,

        descriptor = MENU_CATEGORY_NOTIFICATIONS,
        normal = "EsoUI/Art/MainMenu/menuBar_notifications_up.dds",
        pressed = "EsoUI/Art/MainMenu/menuBar_notifications_down.dds",
        disabled = "EsoUI/Art/MainMenu/menuBar_notifications_disabled.dds",
        highlight = "EsoUI/Art/MainMenu/menuBar_notifications_over.dds",
    },
    [MENU_CATEGORY_HELP] =
    {
        binding = "TOGGLE_HELP",
        categoryName = SI_MAIN_MENU_HELP,

        descriptor = MENU_CATEGORY_HELP,
        normal = "EsoUI/Art/MenuBar/menuBar_help_up.dds",
        pressed = "EsoUI/Art/MenuBar/menuBar_help_down.dds",
        disabled = "EsoUI/Art/MenuBar/menuBar_help_disabled.dds",
        highlight = "EsoUI/Art/MenuBar/menuBar_help_over.dds",
    },
    [MENU_CATEGORY_ACTIVITY_FINDER] =
    {
        binding = "TOGGLE_ACTIVITY_FINDER",
        descriptor = MENU_CATEGORY_ACTIVITY_FINDER,
        hidden = true,
        alias = MENU_CATEGORY_GROUP, --On keyboard, we want the activity finder keybind to just take you to group naturally for now
    },
}


local ENABLE_CATEGORY = true
local DISABLE_CATEGORY = false
function MainMenu_Keyboard:SetCategoriesEnabled(categoryFilterFunction, shouldBeEnabled)
    for i = 1, #CATEGORY_LAYOUT_INFO do
        local categoryInfo = CATEGORY_LAYOUT_INFO[i]
        if categoryFilterFunction(categoryInfo) then
            if not shouldBeEnabled and self:IsShowing() and (self.lastCategory == i) then
                self:Hide()
            end
            ZO_MenuBar_SetDescriptorEnabled(self.categoryBar, i, shouldBeEnabled)
        end
    end
end

function MainMenu_Keyboard:New(control)
    local manager = ZO_CallbackObject.New(self)
    manager:Initialize(control)
    return manager
end

function MainMenu_Keyboard:Initialize(control)
    ADD_ON_MANAGER = ZO_AddOnManager:New(true)

    self.control = control

    self.categoryBar = GetControl(self.control, "CategoryBar")
    ZO_MenuBar_ClearClickSound(self.categoryBar)
    self.categoryBarFragment = ZO_FadeSceneFragment:New(self.categoryBar)

    self.sceneGroupBar = GetControl(self.control, "SceneGroupBar")
    self.sceneGroupBarLabel = GetControl(self.control, "SceneGroupBarLabel")

    self.tabPressedCallback =   function(control)
                                    if control.sceneGroupName then
                                        self:OnSceneGroupTabClicked(control.sceneGroupName)
                                    end
                                end

    self.sceneShowCallback =   function(oldState, newState)
                                    if(newState == SCENE_SHOWING) then
                                        local sceneGroupInfo = self.sceneGroupInfo[self.sceneShowGroupName] 
                                        self:SetupSceneGroupBar(sceneGroupInfo.category, self.sceneShowGroupName)
                                        local scene = SCENE_MANAGER:GetCurrentScene()
                                        scene:UnregisterCallback("StateChange", self.sceneShowCallback)
                                    end
                                end

    self:AddCategories()

    self.lastCategory = MENU_CATEGORY_INVENTORY

    local function OnBlockingSceneActivated(activatedByMouseClick, isSceneGroup)
        if activatedByMouseClick then
            local SKIP_ANIMATION = true
            if isSceneGroup then
                ZO_MenuBar_RestoreLastClickedButton(self.sceneGroupBar, SKIP_ANIMATION)
            else
                ZO_MenuBar_RestoreLastClickedButton(self.categoryBar, SKIP_ANIMATION)
            end
        end
    end

    local function OnBlockingSceneCleared(nextSceneData, showBaseScene)
        if not IsInGamepadPreferredMode() then
            if nextSceneData then
                if nextSceneData.sceneGroup then
                    nextSceneData.sceneGroup:SetActiveScene(nextSceneData.sceneName)
                    self:Update(nextSceneData.category, nextSceneData.sceneName)
                elseif nextSceneData.category then
                    self:ToggleCategory(nextSceneData.category)
                end
            end
        end
    end

    MAIN_MENU_MANAGER:RegisterCallback("OnPlayerStateUpdate", function() self:UpdateCategories() end)
    MAIN_MENU_MANAGER:RegisterCallback("OnBlockingSceneActivated", OnBlockingSceneActivated)
    MAIN_MENU_MANAGER:RegisterCallback("OnBlockingSceneCleared", OnBlockingSceneCleared)

    self:UpdateCategories()
end

function MainMenu_Keyboard:AddCategories()
    local categoryBarData =
    {
        buttonPadding = 16,
        normalSize = 51,
        downSize = 64,
        animationDuration = DEFAULT_SCENE_TRANSITION_TIME,
        buttonTemplate = "ZO_MainMenuCategoryBarButton",
    }

    ZO_MenuBar_SetData(self.categoryBar, categoryBarData)

    self.categoryInfo = {}
    self.sceneInfo = {}
    self.sceneGroupInfo = {}
    self.categoryAreaFragments = {}

    for i = 1, #CATEGORY_LAYOUT_INFO do
        local categoryLayoutInfo = CATEGORY_LAYOUT_INFO[i]
        categoryLayoutInfo.callback = function() self:OnCategoryClicked(i) end
        ZO_MenuBar_AddButton(self.categoryBar, categoryLayoutInfo)

        local subcategoryBar = CreateControlFromVirtual("ZO_MainMenuSubcategoryBar", self.control, "ZO_MainMenuSubcategoryBar", i)
        subcategoryBar:SetAnchor(TOP, self.categoryBar, BOTTOM, 0, 7)
        local subcategoryBarFragment = ZO_FadeSceneFragment:New(subcategoryBar)
        self.categoryInfo[i] =
        {
            barControls = {},
            subcategoryBar = subcategoryBar,
            subcategoryBarFragment = subcategoryBarFragment,
        }
    end

    self:RefreshCategoryIndicators()
    self:AddCategoryAreaFragment(self.categoryBarFragment)
end

function MainMenu_Keyboard:AddCategoryAreaFragment(fragment)
    self.categoryAreaFragments[#self.categoryAreaFragments + 1] = fragment
end

function MainMenu_Keyboard:AddRawScene(sceneName, category, categoryInfo, sceneGroupName)
    local scene = SCENE_MANAGER:GetScene(sceneName)

    local hideCategoryBar = CATEGORY_LAYOUT_INFO[category].hideCategoryBar
    if hideCategoryBar == nil or hideCategoryBar == false then
        scene:AddFragment(categoryInfo.subcategoryBarFragment)
        for i, categoryAreaFragment in ipairs(self.categoryAreaFragments) do
            scene:AddFragment(categoryAreaFragment)
        end
    end

    local sceneInfo =
    {
        category = category,
        sceneName = sceneName,
        sceneGroupName = sceneGroupName,
    }
    self.sceneInfo[sceneName] = sceneInfo

    return scene
end

function MainMenu_Keyboard:SetLastSceneName(categoryInfo, sceneName)
    categoryInfo.lastSceneName = sceneName
    categoryInfo.lastSceneGroupName = nil
end

function MainMenu_Keyboard:SetLastSceneGroupName(categoryInfo, sceneGroupName)
    categoryInfo.lastSceneGroupName = sceneGroupName
    categoryInfo.lastSceneName = nil
end

function MainMenu_Keyboard:HasLast(categoryInfo)
    return categoryInfo.lastSceneName ~= nil or categoryInfo.lastSceneGroupName ~= nil
end

function MainMenu_Keyboard:AddScene(category, sceneName)
    local categoryInfo = self.categoryInfo[category]    
    self:AddRawScene(sceneName, category, categoryInfo)
    if(not self:HasLast(categoryInfo)) then
        self:SetLastSceneName(categoryInfo, sceneName)
    end
end

function MainMenu_Keyboard:SetSceneEnabled(sceneName, enabled)
    local sceneInfo = self.sceneInfo[sceneName]
    if(sceneInfo) then
        local sceneGroupName = sceneInfo.sceneGroupName
        if(sceneGroupName) then
            local sceneGroupInfo = self.sceneGroupInfo[sceneGroupName]
            local menuBarIconData = sceneGroupInfo.menuBarIconData
            local sceneGroupBarFragment = sceneGroupInfo.sceneGroupBarFragment
            for i = 1, #menuBarIconData do
                local layoutData = menuBarIconData[i]
                if(layoutData.descriptor == sceneName) then
                    layoutData.enabled = enabled
                    
                    if(sceneGroupBarFragment:IsShowing()) then
                        self:UpdateSceneGroupBarEnabledStates(sceneGroupName)
                    end

                    return
                end
            end
        end
    end
end

function MainMenu_Keyboard:AddSceneGroup(category, sceneGroupName, menuBarIconData, sceneGroupPreferredSceneFunction)
    local categoryInfo = self.categoryInfo[category]

    local sceneGroup = SCENE_MANAGER:GetSceneGroup(sceneGroupName)
    
    for i=1, sceneGroup:GetNumScenes() do
        local sceneName = sceneGroup:GetSceneName(i)
        local scene = self:AddRawScene(sceneName, category, categoryInfo, sceneGroupName)
    end

    if(not self:HasLast(categoryInfo)) then
        self:SetLastSceneGroupName(categoryInfo, sceneGroupName)
    end

    local sceneGroupBarFragment = ZO_FadeSceneFragment:New(self.sceneGroupBar)
    for i=1, #menuBarIconData do
        local sceneName = menuBarIconData[i].descriptor
        local scene = SCENE_MANAGER:GetScene(sceneName)
        scene:AddFragment(sceneGroupBarFragment)
    end

    self.sceneGroupInfo[sceneGroupName] =
    {
        menuBarIconData = menuBarIconData,
        category = category,
        sceneGroupPreferredSceneFunction = sceneGroupPreferredSceneFunction,
        sceneGroupBarFragment = sceneGroupBarFragment,
    }
end

local FORCE_SELECTION = true
function MainMenu_Keyboard:EvaluateSceneGroupVisibilityOnEvent(sceneGroupName, event)
    local sceneInfo = self.sceneGroupInfo[sceneGroupName]
    if sceneInfo then
        EVENT_MANAGER:RegisterForEvent(self.control:GetName() .. sceneGroupName, event, function()
            if self.sceneShowGroupName == sceneGroupName then
                ZO_MenuBar_UpdateButtons(self.sceneGroupBar, FORCE_SELECTION)
            end
        end)
    end
end

function MainMenu_Keyboard:EvaluateSceneGroupVisibilityOnCallback(sceneGroupName, callbackName)
    local sceneInfo = self.sceneGroupInfo[sceneGroupName]
    if sceneInfo then
        CALLBACK_MANAGER:RegisterCallback(callbackName, function()
            if self.sceneShowGroupName == sceneGroupName then
                ZO_MenuBar_UpdateButtons(self.sceneGroupBar, FORCE_SELECTION)
            end
        end)
    end
end

function MainMenu_Keyboard:RefreshCategoryIndicators()
    for i, categoryLayoutData in ipairs(CATEGORY_LAYOUT_INFO) do
        local indicators = categoryLayoutData.indicators
        if indicators then
            local buttonControl = ZO_MenuBar_GetButtonControl(self.categoryBar, categoryLayoutData.descriptor)
            if buttonControl then
                local indicatorTexture = buttonControl:GetNamedChild("Indicator")
                local textures
                if type(indicators) == "table" then
                    textures = indicators
                elseif type(indicators) == "function" then
                    textures = indicators()
                end
                if textures and #textures > 0 then
                    indicatorTexture:ClearIcons()
                    for _, texture in ipairs(textures) do
                        indicatorTexture:AddIcon(texture)
                    end
                    indicatorTexture:Show()
                else
                    indicatorTexture:Hide()
                end
            end
        end
    end
end

function MainMenu_Keyboard:RefreshCategoryBar(forceSelection)
    if forceSelection == nil then
        forceSelection = FORCE_SELECTION
    end
    ZO_MenuBar_UpdateButtons(self.categoryBar, forceSelection)
    self:RefreshCategoryIndicators()
end

function MainMenu_Keyboard:AddButton(category, name, callback)
    local categoryInfo = self.categoryInfo[category]
    
    --sub category bar
    local numControls = #categoryInfo.barControls
    local button = CreateControlFromVirtual("ZO_MainMenu"..category.."Button", categoryInfo.subcategoryBar, "ZO_MainMenuSubcategoryButton", numControls + 1)
    local lastControl = categoryInfo.barControls[numControls]
    if(lastControl) then
        button:SetAnchor(TOPLEFT, lastControl, TOPRIGHT, 20, 0)
    else
        button:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 0)
    end
    
    button:SetText(GetString(name))
    button:SetHandler("OnMouseUp", callback)

    table.insert(categoryInfo.barControls, button)
end

function MainMenu_Keyboard:IsShowing()
    return self.categoryBarFragment:IsShowing()
end

function MainMenu_Keyboard:Hide()
    SCENE_MANAGER:ShowBaseScene()
end

function MainMenu_Keyboard:UpdateSceneGroupBarEnabledStates(sceneGroupName)
    local menuBarIconData = self.sceneGroupInfo[sceneGroupName].menuBarIconData
    for i, layoutData in ipairs(menuBarIconData) do
        ZO_MenuBar_SetDescriptorEnabled(self.sceneGroupBar, layoutData.descriptor, (layoutData.enabled == nil or layoutData.enabled == true))
    end
end

function MainMenu_Keyboard:UpdateSceneGroupButtons(groupName)
    if self:IsShowing() and self.sceneShowGroupName == groupName then
        ZO_MenuBar_UpdateButtons(self.sceneGroupBar)
        if not ZO_MenuBar_GetSelectedDescriptor(self.sceneGroupBar) then
            ZO_MenuBar_SelectFirstVisibleButton(self.sceneGroupBar, true)
        end
    end
end

function MainMenu_Keyboard:SetupSceneGroupBar(category, sceneGroupName)
    if self.sceneGroupInfo[sceneGroupName] then
        -- This is a scene group
        ZO_MenuBar_ClearButtons(self.sceneGroupBar)

        local sceneGroup = SCENE_MANAGER:GetSceneGroup(sceneGroupName)
        local menuBarIconData = self.sceneGroupInfo[sceneGroupName].menuBarIconData
        for i, layoutData in ipairs(menuBarIconData) do
            local sceneName = layoutData.descriptor
            layoutData.callback = function()
                if not self.ignoreCallbacks then
                    if MAIN_MENU_MANAGER:HasBlockingScene() then
                        local CLICKED_BY_MOUSE = true
                        local sceneData = {
                            category = category,
                            sceneName = sceneName,
                            sceneGroup = sceneGroup,
                        }
                        MAIN_MENU_MANAGER:ActivatedBlockingScene_Scene(sceneData, CLICKED_BY_MOUSE)
                    else
                        sceneGroup:SetActiveScene(sceneName)
                        self:Update(category, sceneName)
                    end
                end 
            end
            ZO_MenuBar_AddButton(self.sceneGroupBar, layoutData)
            ZO_MenuBar_SetDescriptorEnabled(self.sceneGroupBar, layoutData.descriptor, (layoutData.enabled == nil or layoutData.enabled == true))
        end

        local activeSceneName = sceneGroup:GetActiveScene()
        local layoutData
        for i = 1, #menuBarIconData do
            if(menuBarIconData[i].descriptor == activeSceneName) then
                layoutData = menuBarIconData[i]
                break
            end
        end

        self.ignoreCallbacks = true

        if(layoutData) then
            if not ZO_MenuBar_SelectDescriptor(self.sceneGroupBar, activeSceneName) then
                self.ignoreCallbacks = false
                ZO_MenuBar_SelectFirstVisibleButton(self.sceneGroupBar, true)
            end

            self.sceneGroupBarLabel:SetHidden(false)
            self.sceneGroupBarLabel:SetText(GetString(layoutData.categoryName))
        end

        self.ignoreCallbacks = false
    end
end

function MainMenu_Keyboard:Update(category, sceneName)
    self.ignoreCallbacks = true

    local categoryInfo = self.categoryInfo[category]
    
    -- This is a scene
    local sceneInfo = self.sceneInfo[sceneName]
    local skipAnimation = not self:IsShowing()
    ZO_MenuBar_SelectDescriptor(self.categoryBar, category, skipAnimation)
    self.lastCategory = category

    self:SetLastSceneName(categoryInfo, sceneName)
    
    if sceneInfo.sceneGroupName then
        -- This scene is part of a scene group, need to update the selected
        local scene = SCENE_MANAGER:GetScene(sceneName)
        self.sceneShowGroupName = sceneInfo.sceneGroupName
        scene:RegisterCallback("StateChange", self.sceneShowCallback)
        local sceneGroup = SCENE_MANAGER:GetSceneGroup(sceneInfo.sceneGroupName)
        sceneGroup:SetActiveScene(sceneName)
        self:SetLastSceneGroupName(categoryInfo, sceneInfo.sceneGroupName)
    end

    SCENE_MANAGER:Show(sceneName)

    self.ignoreCallbacks = false
end

function MainMenu_Keyboard:ShowScene(sceneName)
    local sceneInfo = self.sceneInfo[sceneName]
    if sceneInfo.sceneGroupName then
        self:ShowSceneGroup(sceneInfo.sceneGroupName, sceneName)
    else
        self:Update(sceneInfo.category, sceneName)
    end
end

function MainMenu_Keyboard:ToggleScene(sceneName)
    local sceneInfo = self.sceneInfo[sceneName]
    if(SCENE_MANAGER:IsShowing(sceneName)) then
        SCENE_MANAGER:ShowBaseScene()
    else
        self:RefreshCategoryBar()
        self:ShowScene(sceneName)
    end
end

function MainMenu_Keyboard:SetPreferredActiveScene(sceneGroupInfo, sceneGroup)
    if sceneGroupInfo.sceneGroupPreferredSceneFunction then
        local sceneNameToShow = sceneGroupInfo.sceneGroupPreferredSceneFunction()
        if sceneNameToShow then
            sceneGroup:SetActiveScene(sceneNameToShow)
        end
    end
end

function MainMenu_Keyboard:ShowSceneGroup(sceneGroupName, specificScene)
    local sceneGroupInfo = self.sceneGroupInfo[sceneGroupName]
    if(not specificScene) then
        local sceneGroup = SCENE_MANAGER:GetSceneGroup(sceneGroupName)
        self:SetPreferredActiveScene(sceneGroupInfo, sceneGroup)
        specificScene = sceneGroup:GetActiveScene()
    end

    self:Update(sceneGroupInfo.category, specificScene)
end

function MainMenu_Keyboard:ToggleSceneGroup(sceneGroupName, specificScene)
    local sceneGroupInfo = self.sceneGroupInfo[sceneGroupName]
    if(not specificScene) then
        local sceneGroup = SCENE_MANAGER:GetSceneGroup(sceneGroupName)
        self:SetPreferredActiveScene(sceneGroupInfo, sceneGroup)
        specificScene = sceneGroup:GetActiveScene()
    end
    
    if self:IsShowing() and self.lastCategory == sceneGroupInfo.category then
        SCENE_MANAGER:ShowBaseScene()
    else
        self:Update(sceneGroupInfo.category, specificScene)
    end
end

function MainMenu_Keyboard:ShowCategory(category)
    --Keyboard and gamepad aren't always one-to-one, so sometimes we might need a binding to do the exact same thing as a different binding
    local categoryLayoutInfo = CATEGORY_LAYOUT_INFO[category]
    if categoryLayoutInfo.alias then
        category = categoryLayoutInfo.alias
        categoryLayoutInfo = CATEGORY_LAYOUT_INFO[category]
    end

    if(categoryLayoutInfo.visible == nil or categoryLayoutInfo.visible()) then
        local categoryInfo = self.categoryInfo[category]
        if(categoryInfo.lastSceneName) then
            self:ShowScene(categoryInfo.lastSceneName)
        else
            self:ShowSceneGroup(categoryInfo.lastSceneGroupName)
        end
    end
end

do
    local function GetCategoryState(categoryInfo)
        if MAIN_MENU_MANAGER:IsPlayerDead() and categoryInfo.disableWhenDead then
            return MAIN_MENU_CATEGORY_DISABLED_WHILE_DEAD
        elseif MAIN_MENU_MANAGER:IsPlayerInCombat() and categoryInfo.disableWhenInCombat then
            return MAIN_MENU_CATEGORY_DISABLED_WHILE_IN_COMBAT
        elseif MAIN_MENU_MANAGER:IsPlayerReviving() and categoryInfo.disableWhenReviving then
            return MAIN_MENU_CATEGORY_DISABLED_WHILE_REVIVING
        elseif MAIN_MENU_MANAGER:IsPlayerSwimming() and categoryInfo.disableWhenSwimming then
            return MAIN_MENU_CATEGORY_DISABLED_WHILE_SWIMMING
        elseif MAIN_MENU_MANAGER:IsPlayerWerewolf() and categoryInfo.disableWhenWerewolf then
            return MAIN_MENU_CATEGORY_DISABLED_WHILE_WEREWOLF
        else
            return MAIN_MENU_CATEGORY_ENABLED
        end
    end

    local function ZO_MainMenuManager_ToggleCategoryInternal(self, category)
        local categoryLayoutInfo = CATEGORY_LAYOUT_INFO[category]
        local categoryState = GetCategoryState(categoryLayoutInfo)

        if categoryState == MAIN_MENU_CATEGORY_DISABLED_WHILE_DEAD then
            ZO_AlertEvent(EVENT_UI_ERROR, SI_CANNOT_DO_THAT_WHILE_DEAD)
        elseif categoryState == MAIN_MENU_CATEGORY_DISABLED_WHILE_IN_COMBAT then
            ZO_AlertEvent(EVENT_UI_ERROR, SI_CANNOT_DO_THAT_WHILE_IN_COMBAT)
        elseif categoryState == MAIN_MENU_CATEGORY_DISABLED_WHILE_REVIVING then
            ZO_AlertEvent(EVENT_UI_ERROR, SI_CANNOT_DO_THAT_WHILE_REVIVING)
        elseif categoryState == MAIN_MENU_CATEGORY_DISABLED_WHILE_SWIMMING then
            ZO_AlertEvent(EVENT_UI_ERROR, SI_CANNOT_DO_THAT_WHILE_SWIMMING)
        elseif categoryState == MAIN_MENU_CATEGORY_DISABLED_WHILE_WEREWOLF then
            ZO_AlertEvent(EVENT_UI_ERROR, SI_CANNOT_DO_THAT_WHILE_WEREWOLF)
        else
            if(categoryLayoutInfo.visible == nil or categoryLayoutInfo.visible()) then
                local categoryInfo = self.categoryInfo[category]
                if(categoryInfo.lastSceneName) then
                    self:ToggleScene(categoryInfo.lastSceneName)
                else
                    self:ToggleSceneGroup(categoryInfo.lastSceneGroupName)
                end
            end
        end
    end

    function MainMenu_Keyboard:ToggleCategory(category)
        --Keyboard and gamepad aren't always one-to-one, so sometimes we might need a binding to do the exact same thing as a different binding
        local categoryLayoutInfo = CATEGORY_LAYOUT_INFO[category]
        if categoryLayoutInfo.alias then
            category = categoryLayoutInfo.alias
        end

        if MAIN_MENU_MANAGER:HasBlockingScene() then
            local sceneData = {
                category = category,
            }
            MAIN_MENU_MANAGER:ActivatedBlockingScene_Scene(sceneData)
        else
            ZO_MainMenuManager_ToggleCategoryInternal(self, category)
        end
    end

    function MainMenu_Keyboard:ShowLastCategory()
        local categoryLayoutInfo = CATEGORY_LAYOUT_INFO[self.lastCategory]
        local categoryState = GetCategoryState(categoryLayoutInfo)

        if categoryState == MAIN_MENU_CATEGORY_ENABLED then
            self:ShowCategory(self.lastCategory)
        else -- if a category is disabled, default to the character menu
            self:ToggleCategory(MENU_CATEGORY_CHARACTER)
        end
    end

    function MainMenu_Keyboard:UpdateCategories()
        for i = 1, #CATEGORY_LAYOUT_INFO do
            local categoryInfo = CATEGORY_LAYOUT_INFO[i]
            local shouldBeEnabled = GetCategoryState(categoryInfo) == MAIN_MENU_CATEGORY_ENABLED
            if not shouldBeEnabled and (self.lastCategory == i) and SCENE_MANAGER:IsShowing(categoryInfo.scene) then
                self:Hide()
            end
            ZO_MenuBar_SetDescriptorEnabled(self.categoryBar, i, shouldBeEnabled)
        end
    end
end

function MainMenu_Keyboard:ToggleLastCategory()
    self:ToggleCategory(self.lastCategory)
end

--Events

function MainMenu_Keyboard:OnCategoryClicked(category)
    if(not self.ignoreCallbacks) then
        if(MAIN_MENU_MANAGER:HasBlockingScene()) then
            local CLICKED_BY_MOUSE = true
            local sceneData = {
                category = category,
            }
            MAIN_MENU_MANAGER:ActivatedBlockingScene_Scene(sceneData, CLICKED_BY_MOUSE)
        else
            self:ShowCategory(category)
        end
    end
end

function MainMenu_Keyboard:OnSceneGroupTabClicked(sceneGroupName)
    if(not self.ignoreCallbacks) then
        self:ShowSceneGroup(sceneGroupName)
    end
end

function MainMenu_Keyboard:OnSceneGroupBarLabelTextChanged()
    -- SetText will get called before self.sceneGroupBar refrshes its anchors, so the position of the label needs
    -- to let that update before it notifies anyone of it's new rectangle
    zo_callLater(function() MAIN_MENU_KEYBOARD:FireCallbacks("OnSceneGroupBarLabelTextChanged", self.sceneGroupBarLabel) end, 10)
end

--Global XML

function ZO_MainMenuCategoryBarButton_OnMouseEnter(self)
    ZO_MenuBarButtonTemplate_OnMouseEnter(self)
    InitializeTooltip(InformationTooltip, self:GetParent(), LEFT, 15, 2)

    local buttonData = ZO_MenuBarButtonTemplate_GetData(self)
    local bindingString = ZO_Keybindings_GetHighestPriorityBindingStringFromAction(buttonData.binding)
    local button = self.m_object.m_menuBar:ButtonObjectForDescriptor(buttonData.descriptor)
    
    local tooltipText = GetString(SI_MAIN_MENU_TOOLTIP_DISABLED_BUTTON)
    if (button.m_state ~= BSTATE_DISABLED) then
        tooltipText = zo_strformat(SI_MAIN_MENU_KEYBIND, GetString(buttonData.categoryName), bindingString or GetString(SI_ACTION_IS_NOT_BOUND))
    end
    
    SetTooltipText(InformationTooltip, tooltipText)
end

function ZO_MainMenuCategoryBarButton_OnMouseExit(self)
    ZO_MenuBarButtonTemplate_OnMouseExit(self)
    ClearTooltip(InformationTooltip)
end

function ZO_MainMenu_OnSceneGroupBarLabelTextChanged()
    MAIN_MENU_KEYBOARD:OnSceneGroupBarLabelTextChanged()
end

function ZO_MainMenu_OnInitialized(self)
    MAIN_MENU_KEYBOARD = MainMenu_Keyboard:New(self)
    SYSTEMS:RegisterKeyboardObject("mainMenu", MAIN_MENU_KEYBOARD)
end
