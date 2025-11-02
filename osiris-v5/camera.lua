-- camera.lua
-- Camera manipulation functions

local Services = require("services")

local Camera = {}
local neverFrameEnabled = true

-- "safeSetCameraCFrame": Snap camera, revert client-side same frame
function Camera.safeSetCameraCFrame(newCF, revertCF)
    if not neverFrameEnabled then
        Services.Camera.CFrame = newCF
        return
    end

    local revertScheduled = false
    local originalCameraType = Services.Camera.CameraType
    Services.Camera.CameraType = Enum.CameraType.Scriptable
    Services.Camera.CFrame = newCF

    -- Store the humanoid and original AutoRotate
    local humanoid = Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local rootPart = Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local originalAutoRotate = humanoid and humanoid.AutoRotate

    -- Disable rotation and lock the root part
    if humanoid then
        humanoid.AutoRotate = false
    end
    if rootPart then
        -- Store original orientation
        local originalRootCF = rootPart.CFrame
        rootPart.CFrame = originalRootCF -- enforce current orientation
    end

    if not revertScheduled then
        revertScheduled = true
        Services.RunService:BindToRenderStep("CameraRevert", Enum.RenderPriority.Camera.Value + 1, function()
            -- Revert camera
            Services.Camera.CFrame = revertCF
            Services.Camera.CameraType = originalCameraType

            -- Restore AutoRotate
            if humanoid and originalAutoRotate ~= nil then
                humanoid.AutoRotate = originalAutoRotate
            end

            -- Restore root orientation
            if rootPart then
                rootPart.CFrame = rootPart.CFrame
            end

            Services.RunService:UnbindFromRenderStep("CameraRevert")
            revertScheduled = false
        end)
    end
end

return Camera
