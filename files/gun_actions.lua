-- For all actions in the actions list, remove max_uses giving player unlimited ammo
for i, action in ipairs(actions) do
    actions[i].max_uses = nil
end