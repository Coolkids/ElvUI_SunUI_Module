local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = LibStub("LibSharedMedia-3.0")

function E:CreateFS(parent, fontSize, justify, fontname, fontStyle)
    local f = parent:CreateFontString(nil, "OVERLAY")
	
	if fontname == nil then
		f:FontTemplate(nil, fontSize, fontStyle)
	else
		f:FontTemplate(fontname, fontSize, fontStyle)
	end

    if justify then f:SetJustifyH(justify) end

    return f
end

local function FontTemplate(fs, font, fontSize, fontStyle)
	fs.font = font
	fs.fontSize = fontSize
	fs.fontStyle = fontStyle
	
	if not font then font = LSM:Fetch("font", E.db['general'].font) end
	if not fontSize then fontSize = E.db.general.fontSize end
	if not fontStyle then fontStyle = "THINOUTLINE" end
	
	fs:SetFont(font, fontSize, fontStyle)
	if fontStyle then
		fs:SetShadowColor(0, 0, 0, 0.2)
	else
		fs:SetShadowColor(0, 0, 0, 1)
	end
	fs:SetShadowOffset((E.mult or 1), -(E.mult or 1))
	
	E["texts"][fs] = true
end

local function GetTemplate(t, isPixelPerfectForced)
	backdropa = 0.3

	if t == "ClassColor" then
		if CUSTOM_CLASS_COLORS then
			borderr, borderg, borderb = CUSTOM_CLASS_COLORS[E.myclass].r, CUSTOM_CLASS_COLORS[E.myclass].g, CUSTOM_CLASS_COLORS[E.myclass].b
		else
			borderr, borderg, borderb = RAID_CLASS_COLORS[E.myclass].r, RAID_CLASS_COLORS[E.myclass].g, RAID_CLASS_COLORS[E.myclass].b
		end
		if t ~= "Transparent" then
			backdropr, backdropg, backdropb = unpack(E["media"].backdropcolor)
		else
			backdropr, backdropg, backdropb, backdropa = unpack(E["media"].backdropfadecolor)
		end
	elseif t == "Transparent" then
		borderr, borderg, borderb = unpack(E["media"].bordercolor)
		backdropr, backdropg, backdropb, backdropa = unpack(E["media"].backdropfadecolor)
	else
		borderr, borderg, borderb = unpack(E["media"].bordercolor)
		backdropr, backdropg, backdropb = unpack(E["media"].backdropcolor)
	end
	
	if(isPixelPerfectForced) then
		borderr, borderg, borderb = 0, 0, 0
	end	
end

local function SetTemplate(f, t, glossTex, ignoreUpdates, forcePixelMode)
	GetTemplate(t, f.forcePixelMode or forcePixelMode)

	if(t) then
	   f.template = t
	end

	if(glossTex) then
	   f.glossTex = glossTex
	end

	if(ignoreUpdates) then
	   f.ignoreUpdates = ignoreUpdates
	end
	
	if(forcePixelMode) then
		f.forcePixelMode = forcePixelMode
	end
	
	if E.private.general.pixelPerfect or f.forcePixelMode then
		f:SetBackdrop({
		  bgFile = E["media"].blankTex,
		  edgeFile = E["media"].blankTex,
		  tile = false, tileSize = 0, edgeSize = E.mult,
		  insets = { left = 0, right = 0, top = 0, bottom = 0}
		})
	else
		f:SetBackdrop({
		  bgFile = E["media"].blankTex,
		  edgeFile = E["media"].blankTex,
		  tile = false, tileSize = 0, edgeSize = E.mult,
		  insets = { left = -E.mult, right = -E.mult, top = -E.mult, bottom = -E.mult}
		})
	end

	if not f.backdropTexture and t ~= 'Transparent' then
		local backdropTexture = f:CreateTexture(nil, "BORDER")
		backdropTexture:SetDrawLayer("BACKGROUND", 1)
		f.backdropTexture = backdropTexture
	elseif t == 'Transparent' then
		f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)

		if f.backdropTexture then
			f.backdropTexture:Hide()
			f.backdropTexture = nil
		end

		if not f.oborder and not f.iborder and not E.private.general.pixelPerfect and not f.forcePixelMode then
			local border = CreateFrame("Frame", nil, f)
			border:SetInside(f, E.mult, E.mult)
			border:SetBackdrop({
				edgeFile = E["media"].blankTex,
				edgeSize = E.mult,
				insets = { left = E.mult, right = E.mult, top = E.mult, bottom = E.mult }
			})
			border:SetBackdropBorderColor(0, 0, 0, 1)
			f.iborder = border

			if f.oborder then return end
			local border = CreateFrame("Frame", nil, f)
			border:SetOutside(f, E.mult, E.mult)
			border:SetFrameLevel(f:GetFrameLevel() + 1)
			border:SetBackdrop({
				edgeFile = E["media"].blankTex,
				edgeSize = E.mult,
				insets = { left = E.mult, right = E.mult, top = E.mult, bottom = E.mult }
			})
			border:SetBackdropBorderColor(0, 0, 0, 1)
			f.oborder = border
		end
	end

	if f.backdropTexture then
		f:SetBackdropColor(0, 0, 0, backdropa)
		f.backdropTexture:SetVertexColor(backdropr, backdropg, backdropb)
		f.backdropTexture:SetAlpha(backdropa)
		if glossTex then
			f.backdropTexture:SetTexture(E["media"].glossTex)
		else
			f.backdropTexture:SetTexture(E["media"].blankTex)
		end

		if(f.forcePixelMode or forcePixelMode) then
			f.backdropTexture:SetInside(f, E.mult, E.mult)
		else
			f.backdropTexture:SetInside(f)
		end
	end

	f:SetBackdropBorderColor(borderr, borderg, borderb)

	if not f.ignoreUpdates and not f.forcePixelMode then
		E["frames"][f] = true
	end
end

local function addapi(object)
	local mt = getmetatable(object).__index
	if object.FontTemplate then mt.FontTemplate = FontTemplate end
	if object.SetTemplate then mt.SetTemplate = SetTemplate end
end
local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())
object = EnumerateFrames()
while object do
	if handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end

