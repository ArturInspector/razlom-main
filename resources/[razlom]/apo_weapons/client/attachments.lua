local activeAttachments = {} -- [weaponName] = {objectHandles}

local function cleanupAttachmentObjects(weaponName)
    if activeAttachments[weaponName] then
        for _, obj in ipairs(activeAttachments[weaponName]) do
            if DoesEntityExist(obj) then
                DeleteEntity(obj)
            end
        end
        activeAttachments[weaponName] = nil
    end
end

local function loadModel(model)
    local modelHash = type(model) == 'string' and GetHashKey(model) or model
    if not IsModelValid(modelHash) then return nil end
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 50 do
        Wait(0)
        timeout = timeout + 1
    end
    return modelHash
end

local function attachObjectToWeapon(ped, weaponName, weaponHash, attachmentName)
    local attachmentCfg = Config.Attachments[attachmentName]
    if not attachmentCfg then return end

    local modelHash = loadModel(attachmentCfg.model)
    if not modelHash then return end

    local object = CreateObject(modelHash, 0.0, 0.0, 0.0, false, false, false)
    SetEntityCollision(object, false, false)
    SetEntityCompletelyDisableCollision(object, false, false)
    SetEntityAsMissionEntity(object, true, true)

    -- Прикрепляем к кости оружия (к педу, т.к. нативный attach к weapon prop нестабилен)
    local boneIndex = GetPedBoneIndex(ped, 28422) -- правая рука
    AttachEntityToEntity(
        object,
        ped,
        boneIndex,
        attachmentCfg.offset.x,
        attachmentCfg.offset.y,
        attachmentCfg.offset.z,
        attachmentCfg.rotation.x,
        attachmentCfg.rotation.y,
        attachmentCfg.rotation.z,
        false, false, false, false, 2, true
    )

    activeAttachments[weaponName] = activeAttachments[weaponName] or {}
    table.insert(activeAttachments[weaponName], object)
end

function ApplyAttachments(weaponName, weaponHash, attachments)
    local ped = PlayerPedId()
    cleanupAttachmentObjects(weaponName)

    if not attachments or #attachments == 0 then return end

    for _, attachment in ipairs(attachments) do
        attachObjectToWeapon(ped, weaponName, weaponHash, attachment)
    end
end

function RemoveAttachments(weaponName)
    cleanupAttachmentObjects(weaponName)
end

