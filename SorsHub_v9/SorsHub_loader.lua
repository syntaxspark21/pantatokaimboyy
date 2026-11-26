-- ============================================================
-- SorsHub READFILE LOADER (untuk Delta / executor mobile lain)
--
-- CARA PAKAI:
--   1. Ekstrak SorsHub_V20_FindPath_Fix.zip ke workspace executor.
--      (Hasilnya folder "SorsHub_v9" berisi SorsHub_main.lua + parts/.)
--   2. Simpan file ini di workspace, mis. sebagai "SorsHub_loader.lua"
--      (boleh di dalam SorsHub_v9 atau di root workspace).
--   3. Jalankan satu baris ini di executor:
--
--        loadstring(readfile("SorsHub_loader.lua"))()
--
--      (sesuaikan path kalau file ini ditaruh di dalam folder, mis.
--       loadstring(readfile("SorsHub_v9/SorsHub_loader.lua"))() )
--
-- Loader ini:
--   * mencari SorsHub_main.lua di SorsHub_v9/, SorsHub/, atau root workspace
--   * menyalin main + 10 pack ke folder "SorsHub/" (lokasi yang dibaca main,
--     jadi file lama otomatis tertimpa versi baru)
--   * menjalankan main dengan nama chunk "SorsHub_main.lua" supaya error
--     di console menyebut nama file, bukan string acak
-- ============================================================

local readfile_   = readfile
local writefile_  = writefile
local isfile_     = isfile
local isfolder_   = isfolder
local makefolder_ = makefolder
local compile     = loadstring or load

if type(readfile_) ~= "function" then
    error("[SorsHub loader] Executor ini tidak punya readfile().")
end
if type(compile) ~= "function" then
    error("[SorsHub loader] Executor ini tidak punya loadstring/load.")
end

local function readOk(path)
    local ok, res = pcall(readfile_, path)
    if ok and type(res) == "string" and #res > 0 then
        return res
    end
    return nil
end

local function fileExists(path)
    if type(isfile_) == "function" then
        local ok, res = pcall(isfile_, path)
        if ok and res == true then return true end
    end
    return readOk(path) ~= nil
end

local function ensureFolder(path)
    if type(makefolder_) ~= "function" then return end
    if type(isfolder_) == "function" then
        local ok, exists = pcall(isfolder_, path)
        if ok and exists then return end
    end
    pcall(makefolder_, path)
end

local function dirOf(path)
    return path:match("^(.*)/[^/]+$") or ""
end

local function join(dir, name)
    if dir == "" then return name end
    return dir .. "/" .. name
end

-- ------------------------------------------------------------
-- 1) Cari SorsHub_main.lua. Folder zip (SorsHub_v9) didahulukan
--    supaya versi baru menang atas cache lama di SorsHub/.
-- ------------------------------------------------------------
local CANDIDATES = {
    "SorsHub_v9/SorsHub_main.lua",
    "SorsHub/SorsHub_main.lua",
    "SorsHub_main.lua",
}

local mainPath, mainSrc
for _, path in ipairs(CANDIDATES) do
    if fileExists(path) then
        local src = readOk(path)
        if src and #src > 1000 then
            mainPath, mainSrc = path, src
            break
        end
    end
end

if not mainSrc then
    error("[SorsHub loader] SorsHub_main.lua tidak ditemukan di: "
        .. table.concat(CANDIDATES, ", ")
        .. ". Ekstrak zip ke workspace executor dulu.")
end

print("[SorsHub loader] main ditemukan: " .. mainPath .. " (" .. #mainSrc .. " byte)")

-- ------------------------------------------------------------
-- 2) Pastikan main + semua pack ada di "SorsHub/" — main membaca
--    pack dari SorsHub/parts/pack_XX.lua, bukan dari folder zip.
-- ------------------------------------------------------------
local TARGET_DIR = "SorsHub"
local PACK_FILES = {
    "pack_01.lua", "pack_02.lua", "pack_03.lua", "pack_04.lua", "pack_05.lua",
    "pack_06.lua", "pack_07.lua", "pack_08.lua", "pack_09.lua", "pack_10.lua",
}

local srcDir   = dirOf(mainPath)
local partsDir = join(srcDir, "parts")

-- Cek semua pack di folder sumber dulu supaya errornya jelas di awal.
local packSrc, missing = {}, {}
for _, name in ipairs(PACK_FILES) do
    local src = readOk(join(partsDir, name))
    if src and #src > 50 then
        packSrc[name] = src
    else
        table.insert(missing, name)
    end
end
if #missing > 0 then
    error("[SorsHub loader] Pack tidak ditemukan di " .. partsDir .. "/: "
        .. table.concat(missing, ", ")
        .. ". Ekstrak zip lengkap (termasuk folder parts).")
end

local needSync = (srcDir ~= TARGET_DIR)
if needSync then
    if type(writefile_) ~= "function" then
        error("[SorsHub loader] Executor tidak punya writefile(), jadi tidak bisa "
            .. "menyalin ke SorsHub/. Taruh manual: isi folder SorsHub_v9 "
            .. "(main + parts) ke folder SorsHub/ di workspace, lalu jalankan lagi.")
    end
    ensureFolder(TARGET_DIR)
    ensureFolder(TARGET_DIR .. "/parts")

    local okMain = pcall(writefile_, TARGET_DIR .. "/SorsHub_main.lua", mainSrc)
    if not okMain then
        error("[SorsHub loader] Gagal menulis " .. TARGET_DIR .. "/SorsHub_main.lua")
    end
    for _, name in ipairs(PACK_FILES) do
        local okPack = pcall(writefile_, TARGET_DIR .. "/parts/" .. name, packSrc[name])
        if not okPack then
            error("[SorsHub loader] Gagal menulis " .. TARGET_DIR .. "/parts/" .. name)
        end
    end
    print("[SorsHub loader] sinkronisasi selesai: main + " .. #PACK_FILES
        .. " pack disalin ke " .. TARGET_DIR .. "/ (versi lama tertimpa)")
else
    print("[SorsHub loader] main sudah di " .. TARGET_DIR .. "/, tidak perlu salin")
end

-- ------------------------------------------------------------
-- 3) Compile + jalankan main. Nama chunk dibuat terbaca supaya traceback
--    menyebut "SorsHub_main.lua:baris", bukan string acak.
-- ------------------------------------------------------------
local fn, cerr
local okCompile, a, b = pcall(compile, mainSrc, "@SorsHub_main.lua")
if okCompile then
    fn, cerr = a, b
else
    fn, cerr = compile(mainSrc) -- executor yang tidak menerima argumen chunkname
end
if type(fn) ~= "function" then
    error("[SorsHub loader] Gagal compile main: " .. tostring(cerr))
end

print("[SorsHub loader] menjalankan SorsHub_main.lua ...")
local okRun, runErr = xpcall(fn, function(e)
    if debug and type(debug.traceback) == "function" then
        return debug.traceback(tostring(e), 2)
    end
    return tostring(e)
end)
if not okRun then
    error("[SorsHub loader] Main error: " .. tostring(runErr))
end
