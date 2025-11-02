-- prediction.lua
-- Prediction calculations

local Services = require("services")

local Prediction = {}

-- Get ping prediction
function Prediction.getPingPrediction(autoPredictionEnabled, manualPrediction, autoPredTable)
    if not autoPredictionEnabled then
        return manualPrediction
    end

    -- Get ping (approximate)
    local ping = Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()

    -- Convert ping to prediction value using the auto prediction table
    if ping >= 30 and ping < 40 then
        return autoPredTable["30-40"]
    elseif ping >= 40 and ping < 50 then
        return autoPredTable["40-50"]
    elseif ping >= 50 and ping < 60 then
        return autoPredTable["50-60"]
    elseif ping >= 60 and ping < 70 then
        return autoPredTable["60-70"]
    elseif ping >= 70 and ping < 80 then
        return autoPredTable["70-80"]
    elseif ping >= 80 and ping < 90 then
        return autoPredTable["80-90"]
    elseif ping >= 90 and ping < 100 then
        return autoPredTable["90-100"]
    elseif ping >= 100 and ping < 110 then
        return autoPredTable["100-110"]
    elseif ping >= 110 and ping < 120 then
        return autoPredTable["110-120"]
    elseif ping >= 120 and ping < 130 then
        return autoPredTable["120-130"]
    elseif ping >= 130 and ping < 140 then
        return autoPredTable["130-140"]
    elseif ping >= 140 and ping < 150 then
        return autoPredTable["140-150"]
    else
        return manualPrediction -- Fallback
    end
end

return Prediction
