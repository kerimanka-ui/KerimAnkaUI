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

-- Measure direction from observed threshold crossings. Movement only refines the current bracket.
function ns.EstimateRange(track, now, low, high, x, y, playerSpeed, targetSpeed)
    if low >= high then return end
    if track.time and (now - track.time > 0.6 or now < track.time) then track = {} end
    local edge, direction
    if track.low and high <= track.low then
        edge, direction = high, -1
    elseif track.high and low >= track.high then
        edge, direction = low, 1
    end

    local distance = track.distance
    if edge then
        local dx = x and track.x and x - track.x
        local dy = y and track.y and y - track.y
        local travelled = dx and math.sqrt(dx * dx + dy * dy)
        track.motion = nil
        if targetSpeed == 0 and travelled and travelled > 0.05 then
            track.motion = { x = x, y = y, dx = dx / travelled, dy = dy / travelled }
        elseif playerSpeed == 0 and targetSpeed and targetSpeed > 0 and track.edgeTime and now > track.edgeTime then
            local rate = (edge - track.edge) / (now - track.edgeTime)
            if rate * direction > 0 and math.abs(rate) <= targetSpeed * 1.5 then
                track.motion = { rate = rate }
            end
        end
        track.edge, track.edgeTime, track.direction = edge, now, direction
        distance = edge
    elseif low ~= track.low or high ~= track.high then
        -- Overlapping bounds can change because a check stopped answering. That is not motion.
        track.motion, track.edge, track.edgeTime = nil, nil, nil
        distance = nil
    elseif track.motion then
        local movement = track.motion
        if movement.x and x and targetSpeed == 0 and now - track.edgeTime <= 1.2 then
            local along = (x - movement.x) * movement.dx + (y - movement.y) * movement.dy
            distance = track.edge + track.direction * along
        elseif movement.rate and playerSpeed == 0 and targetSpeed and targetSpeed > 0 and now - track.edgeTime <= 0.5 then
            distance = track.edge + (now - track.edgeTime) * movement.rate
        else
            track.motion = nil
        end
    end

    if high == math.huge or high - low > 8 then
        distance = nil
    else
        distance = math.max(low, math.min(high, distance or (low + high) / 2))
    end
    track.low, track.high, track.distance = low, high, distance
    track.time, track.x, track.y = now, x, y
    return track, distance
end
