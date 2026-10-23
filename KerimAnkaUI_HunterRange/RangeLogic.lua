local _, ns = ...

-- Inputs have already been checked for restricted/secret values.
-- Unknown readings must not become a claimed dead zone or melee distance.
function ns.Classify(shoot, near, melee, recentSwing)
    if shoot == true then return "ranged" end
    if shoot ~= false then return "unknown" end
    if near == false then return "far" end
    if near ~= true then return "unknown" end
    if melee == true then return "melee" end
    if melee == false then return "dead" end
    if recentSwing then return "melee" end
    return "close"
end
