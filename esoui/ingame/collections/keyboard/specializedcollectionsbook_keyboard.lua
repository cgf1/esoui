local NOTIFICATIONS_PROVIDER = NOTIFICATIONS:GetCollectionsProvider()

ZO_SpecializedCollectionsBook_Keyboard = ZO_Object:Subclass()

function ZO_SpecializedCollectionsBook_Keyboard:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function ZO_SpecializedCollectionsBook_Keyboard:Initialize(control, sceneName, ...)
    control.owner = self
    self.control = control

    self.sceneName = sceneName
    self.collectibleCategoryTypes = { ... }
    
    self:InitializeControls()
    self:InitializeNavigationList()
    self:InitializeEvents()

    local specializedBookScene = ZO_Scene:New(self.sceneName, SCENE_MANAGER)

    specializedBookScene:RegisterCallback("StateChange", function(oldState, newState)
                                                             if(newState == SCENE_SHOWN) then
                                                                 self:RefreshListIfDirty()
                                                             end
                                                         end)
end

function ZO_SpecializedCollectionsBook_Keyboard:InitializeControls()
    self.navigationList = self.control:GetNamedChild("NavigationList")

    local contents = self.control:GetNamedChild("Contents")
    self.imageControl = contents:GetNamedChild("Image")
    self.nameLabel = contents:GetNamedChild("Name")

    local scrollSection = contents:GetNamedChild("ScrollContainer"):GetNamedChild("ScrollChild")
    self.descriptionLabel = scrollSection:GetNamedChild("Description")
end

function ZO_SpecializedCollectionsBook_Keyboard:DoesCollectibleHaveAlert(data)
    --Override for additional checks if a collectible has been updated
    return IsCollectibleNew(data.collectibleId)
end

function ZO_SpecializedCollectionsBook_Keyboard:InitializeNavigationList()
    self.navigationTree = ZO_Tree:New(self.navigationList:GetNamedChild("ScrollChild"), 60, -10, 300)

    local OPEN_TEXTURE = "EsoUI/Art/Buttons/tree_open_up.dds"
    local CLOSED_TEXTURE = "EsoUI/Art/Buttons/tree_closed_up.dds"
    local OVER_OPEN_TEXTURE = "EsoUI/Art/Buttons/tree_open_over.dds"
    local OVER_CLOSED_TEXTURE = "EsoUI/Art/Buttons/tree_closed_over.dds"

    local function TreeHeaderSetup(node, control, name, open)
        control.text:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
        control.text:SetText(name)

        control.icon:SetTexture(open and OPEN_TEXTURE or CLOSED_TEXTURE)
        control.iconHighlight:SetTexture(open and OVER_OPEN_TEXTURE or OVER_CLOSED_TEXTURE)

        local ENABLED = true
        local DISABLE_SCALING = true
        ZO_IconHeader_Setup(control, open, ENABLED, DISABLE_SCALING)
    end

    self.navigationTree:AddTemplate("ZO_SpecializedCollection_Book_NavigationHeader_Keyboard", TreeHeaderSetup, nil, nil, nil, 0)

    local function TreeEntrySetup(node, control, data, open)
        control:SetText(zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, data.name))
        control:SetSelected(node:IsSelected())

        control.statusIcon = control:GetNamedChild("StatusIcon")
        data.notificationId = NOTIFICATIONS_PROVIDER:GetNotificationIdForCollectible(data.collectibleId)
        local isNew = data.notificationId or self:DoesCollectibleHaveAlert(data)
        control.statusIcon:SetHidden(not isNew)
    end

    local function TreeEntryOnSelected(control, data, selected, reselectingDuringRebuild)
        control:SetSelected(selected)

         if selected then
            self.selectedId = data.collectibleId
            if not reselectingDuringRebuild then
                self:RefreshDetails()
            end

            if data.notificationId then
                RemoveCollectibleNotification(data.notificationId)
            end

            ClearCollectibleNewStatus(data.collectibleId)
        end
    end

    local function TreeEntryEquality(left, right)
        return left.name == right.name
    end

    self.navigationTree:AddTemplate("ZO_SpecializedCollection_Book_NavigationEntry_Keyboard", TreeEntrySetup, TreeEntryOnSelected, TreeEntryEquality)
    self.navigationTree:SetOpenAnimation("ZO_TreeOpenAnimation")

    self.headerNodes = {}
    self.collectibleIdToTreeNode = {}

    self:RefreshList()
end

function ZO_SpecializedCollectionsBook_Keyboard:RefreshListIfDirty()
    if self.dirty then
        self:RefreshList()
        self.dirty = false
    end
end

function ZO_SpecializedCollectionsBook_Keyboard:InitializeEvents()
    COLLECTIONS_BOOK_SINGLETON:RegisterCallback("OnCollectibleUpdated", function(...) self:OnCollectibleUpdated(...) end)
    COLLECTIONS_BOOK_SINGLETON:RegisterCallback("OnCollectionUpdated", function() self:OnCollectionUpdated() end)
    COLLECTIONS_BOOK_SINGLETON:RegisterCallback("OnCollectiblesUpdated", function() self:OnCollectionUpdated() end)
    COLLECTIONS_BOOK_SINGLETON:RegisterCallback("OnCollectionNotificationRemoved", function(...) self:OnCollectionNotificationRemoved(...) end)
    COLLECTIONS_BOOK_SINGLETON:RegisterCallback("OnCollectibleNewStatusRemoved", function(...) self:OnCollectibleNewStatusRemoved(...) end)
end

function ZO_SpecializedCollectionsBook_Keyboard:GetSelectedData()
    return self.navigationTree:GetSelectedData()
end

function ZO_SpecializedCollectionsBook_Keyboard:FocusCollectibleId(id)
    local node = self.collectibleIdToTreeNode[id]

    if node then
        if self.navigationTree:GetSelectedNode() == node then
            local RESELECT = true
            node:OnSelected(RESELECT)
        else
            self.navigationTree:SelectNode(node)
        end
    end
end

function ZO_SpecializedCollectionsBook_Keyboard:SetupAdditionalCollectibleData(data)
    --Override to add additional data if needed
end

do
    local function DefaultSort(entry1, entry2)
        if entry1.sortOrder ~= entry2.sortOrder then
            return entry1.sortOrder < entry2.sortOrder
        else
            return entry1.name < entry2.name
        end
    end

    function ZO_SpecializedCollectionsBook_Keyboard:SortCollectibleData(collectibleData)
        table.sort(collectibleData, DefaultSort)
    end
end

function ZO_SpecializedCollectionsBook_Keyboard:GetRelevantCollectibles()
    local collectiblesData = {}

    for _, collectibleCategoryType in ipairs(self.collectibleCategoryTypes) do
        for i = 1, GetTotalCollectiblesByCategoryType(collectibleCategoryType) do
            local collectibleId = GetCollectibleIdFromType(collectibleCategoryType, i)
            local name, description, _, _, unlocked, purchasable, active, _, hint, isPlaceholder = GetCollectibleInfo(collectibleId)
            if not isPlaceholder then
                if hint and hint ~= "" then
                    hint = ZO_CachedStrFormat(ZO_CACHED_STR_FORMAT_NO_FORMATTER, hint)
                end

                local data =
                {
                    collectibleId = collectibleId,
                    name = name,
                    description = description,
                    background = GetCollectibleKeyboardBackgroundImage(collectibleId),
                    unlockState = GetCollectibleUnlockStateById(collectibleId),
                    active = active,
                    purchasable = purchasable,
                    unlocked = unlocked,
                    hint = hint,
                    nickname = GetCollectibleNickname(collectibleId),
                    referenceId = GetCollectibleReferenceId(collectibleId),
                    sortOrder = GetCollectibleSortOrder(collectibleId),
                }

                self:SetupAdditionalCollectibleData(data)
                table.insert(collectiblesData, data)
            end
        end
    end

    self:SortCollectibleData(collectiblesData)

    return collectiblesData
end

function ZO_SpecializedCollectionsBook_Keyboard:GetCategorizedLists()
    local collectiblesData = self:GetRelevantCollectibles()

    local unlockedList = {}
    local lockedList = {}
    local lists = 
    {
        {
            name = GetString("SI_COLLECTIBLEUNLOCKSTATE", COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED),
            collectibles = unlockedList,
        },
        {
            name = GetString("SI_COLLECTIBLEUNLOCKSTATE", COLLECTIBLE_UNLOCK_STATE_LOCKED),
            collectibles = lockedList,
        },
    }

    for _, data in ipairs(collectiblesData) do
        if data.unlocked then
            table.insert(unlockedList, data)
        else
            table.insert(lockedList, data)
        end
    end

    return lists
end

function ZO_SpecializedCollectionsBook_Keyboard:RefreshList()
    ZO_ClearTable(self.headerNodes)
    ZO_ClearTable(self.collectibleIdToTreeNode)
    self.navigationTree:Reset()

    local categorizedLists = self:GetCategorizedLists()
    
    local firstNode = nil
    local selectedNode = nil

    for _, categorizedList in ipairs(categorizedLists) do
        if #categorizedList.collectibles > 0 then
            local headerNode = self.navigationTree:AddNode("ZO_SpecializedCollection_Book_NavigationHeader_Keyboard", categorizedList.name, nil, SOUNDS.JOURNAL_PROGRESS_CATEGORY_SELECTED)

            for _, collectibleData in ipairs(categorizedList.collectibles) do
                local node = self.navigationTree:AddNode("ZO_SpecializedCollection_Book_NavigationEntry_Keyboard", collectibleData, headerNode, SOUNDS.JOURNAL_PROGRESS_SUB_CATEGORY_SELECTED)
                self.collectibleIdToTreeNode[collectibleData.collectibleId] = node
                if not firstNode then
                    firstNode = node
                end

                if self.selectedId and self.selectedId == collectibleData.collectibleId then
                    selectedNode = node
                end
            end
        end
    end

    self.navigationTree:Commit()
    local navigateToNode = selectedNode or firstNode

    if navigateToNode then
        self.navigationTree:SelectNode(navigateToNode)
    end
    self:RefreshDetails()
end

function ZO_SpecializedCollectionsBook_Keyboard:RefreshDetails()
    local data = self.navigationTree:GetSelectedData()

    if data then
        self.imageControl:SetTexture(data.background)
        self.nameLabel:SetText(zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, data.name))
        self.descriptionLabel:SetText(data.description)
    end
end

function ZO_SpecializedCollectionsBook_Keyboard:BrowseToCollectible(collectibleId)
    self:FocusCollectibleId(collectibleId)
    MAIN_MENU_KEYBOARD:ToggleSceneGroup("collectionsSceneGroup", self.sceneName)
end

function ZO_SpecializedCollectionsBook_Keyboard:OnCollectibleUpdated(collectibleId, justUnlocked)
    if justUnlocked then
        self:RefreshList()
    else
        local node = self.collectibleIdToTreeNode[collectibleId]
        if node then
            local data = node:GetData()

            local wasActive = data.active
            data.active = select(7, GetCollectibleInfo(collectibleId))
            data.nickname = GetCollectibleNickname(collectibleId)
            local unlockState = GetCollectibleUnlockStateById(collectibleId)
            if data.unlockState ~= unlockState then
                self:RefreshList()
            else
                if data.active ~= wasActive then
                    node:RefreshControl()
                end
                self:RefreshDetails()
            end
        end
    end
end

function ZO_SpecializedCollectionsBook_Keyboard:UpdateCollectibleTreeEntry(collectibleId)
    if not SCENE_MANAGER:IsShowing(self.sceneName) then
        self.dirty = true
    else
        local node = self.collectibleIdToTreeNode[collectibleId]
        if node then
            node:RefreshControl()
        end
    end
end

function ZO_SpecializedCollectionsBook_Keyboard:OnCollectionNotificationRemoved(notificationId, collectibleId)
    self:UpdateCollectibleTreeEntry(collectibleId)
end

function ZO_SpecializedCollectionsBook_Keyboard:OnCollectibleNewStatusRemoved(collectibleId)
    self:UpdateCollectibleTreeEntry(collectibleId)
end

function ZO_SpecializedCollectionsBook_Keyboard:OnCollectionUpdated()
    if not SCENE_MANAGER:IsShowing(self.sceneName) then
        self.dirty = true
    else
        self:RefreshList()
    end
end