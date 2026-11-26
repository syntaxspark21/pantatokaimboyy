-- SorsHub pack part 1/10
return function(P)
local MergeLib = P.MergeLib
local MergeNoop = P.MergeNoop
local MergeRoot = P.MergeRoot
local lp = P.lp
local svc = P.svc

local lib = MergeLib
local lib2 = MergeNoop
local lib3 = MergeNoop
local v = MergeRoot
local Players = svc.Players
local ReplicatedStorage = svc.RS
local localPlayer = lp
-- [SorsHub fix] bagian fitur memakai getgenv().lp/Players/ReplicatedStorage; isi lebih awal
pcall(function()
    local g = getgenv()
    g.Players = g.Players or Players
    g.ReplicatedStorage = g.ReplicatedStorage or ReplicatedStorage
    g.lp = g.lp or lp
end)
local n = 0
local fn = function()
        n = n + 1
        return "VX_flag_" .. n
    end

P["lib@9463,10-9463,13"] = lib
P["lib2@9464,10-9464,14"] = lib2
P["lib3@9465,10-9465,14"] = lib3
P["v@9466,10-9466,11"] = v
P["fn@9471,10-9471,12"] = fn
end