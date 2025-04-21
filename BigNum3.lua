local Bnum3 = {}
type Bnum = {man: number, exp: number}

function Bnum3.new(man: number, exp: number): Bnum
	if man == 0 then
		return {man = 0, exp = 0}
	end
	local frac = exp % 1
	if frac ~= 0 then
		man*= 10^frac
		exp -= frac
	end
	local lm = math.log10(math.abs(man))
	exp+=math.floor(lm)
	man/=10^math.floor(lm)
	return {man=man,exp=exp}
end

function Bnum3.fromNumber(val: number): Bnum
	local lman = math.log10(math.abs(val))
	local exp = math.floor(lman)
	local man = val/(10^math.floor(lman))
	return {man=man, exp=exp}
end

function Bnum3.fromScientific(val: string): Bnum
	local split = val:split('e')
	local man = tonumber(split[1])
	local exp = tonumber(split[2])
	return Bnum3.new(man, exp)
end

function Bnum3.toNumber(val): number
	return val.man*10^val.exp
end

function Bnum3.convert(val): Bnum
	if type(val) == 'number' then
		local exp = math.floor(math.log10(val))
		local man = val/10^exp
		return {man=man, exp=exp}
	elseif type(val) == 'string' then
		local split = val:split('e')
		local man = tonumber(split[1])
		local exp = tonumber(split[2])
		return Bnum3.new(man, exp)
	elseif type(val) == 'table' then
		if #val == 2 then
			return {man=val[1], exp=val[2]}
		elseif val.man then
			return {man=val.man, exp=val.exp}
		end
	end
	warn('Failed to convert to Bnum')
	return {man=0,exp=0}
end

function Bnum3.neg(val1): Bnum
	val1 = Bnum3.convert(val1)
	return Bnum3.new(-val1.man, val1.exp)
end

function Bnum3.add(val1, val2): Bnum
	val1, val2 = Bnum3.convert(val1), Bnum3.convert(val2)
	if val1.exp < val2.exp then
		val1, val2 = val2, val1
	end
	local diff = val1.exp - val2.exp
	if diff > 15 then
		return val1
	end
	local man = val1.man+val2.man * 10^(-diff)
	return Bnum3.new(man, val1.exp)
end

function Bnum3.sub(val1, val2): Bnum
	val1, val2 = Bnum3.convert(val1), Bnum3.convert(val2)
	if val1.exp < val2.exp then
		val1, val2 = val2, val1
	end
	local diff = val1.exp - val2.exp
	if diff > 15 then
		return val1
	end
	local man = val1.man-val2.man * 10^(-diff)
	if man < 0 then return {man=0,exp=0} end
	return Bnum3.new(man, val1.exp)
end

function Bnum3.recip(val1): Bnum
	val1 = Bnum3.convert(val1)
	return Bnum3.new(val1.man, -val1.exp)
end

function Bnum3.mul(val1, val2): Bnum
	val1, val2 = Bnum3.convert(val1), Bnum3.convert(val2)
	return Bnum3.new(val1.man * val2.man, val1.exp+val2.exp)
end

function Bnum3.div(val1, val2): Bnum
	val1, val2 = Bnum3.convert(val1), Bnum3.convert(val2)
	return Bnum3.new(val1.man/val2.man, val1.exp-val2.exp)
end

function Bnum3.pow(val1, val2)
	val1, val2 = Bnum3.convert(val1), Bnum3.convert(val2)
	local r = (math.log10(val1.man)+val1.exp) * (val2.man*10^val2.exp)
	return Bnum3.new(10^(r%1), math.floor(r))
end

function Bnum3.pow10(val1): Bnum
	val1 = Bnum3.convert(val1)
	local exp = val1.man * (10^val1.exp)
	return Bnum3.new(1, exp)
end

function Bnum3.log10(val1): Bnum
	val1 = Bnum3.convert(val1)
	local val = math.log10(val1.man) + val1.exp
	return Bnum3.fromNumber(val)
end

function Bnum3.ln(val1): Bnum
	val1 = Bnum3.convert(val1)
	local l10 = math.log10(val1.man) + val1.exp
	local res = l10*2.302585092994046
	return Bnum3.fromNumber(res)
end

function Bnum3.log(val1, val2): Bnum
	val2 = val2 or 2.718281828459045
	val1, val2 = Bnum3.convert(val1), Bnum3.convert(val2)
	local l1 = math.log10(val1.man) + val1.exp
	local l2 = math.log10(val2.man) + val2.exp
	local man = l1/l2
	return Bnum3.fromNumber(man)
end

function Bnum3.root(val1,val2): Bnum
	val1, val2 = Bnum3.convert(val1), Bnum3.convert(val2)
	local lval = math.log10(val1.man)+val1.exp
	local inv = 1/(val2.man*10^val2.exp)
	local r = lval*inv
	return Bnum3.new(10^(r%1), math.floor(r))
end

function Bnum3.sqrt(val1): Bnum
	val1 = Bnum3.convert(val1)
	local r = (math.log10(val1.man) + val1.exp) * 0.5
	return Bnum3.new(10^(r%1), math.floor(r))
end

function Bnum3.showDigits(val, digits: number?): number
	digits = digits or 2
	return math.floor(val*10^digits:: number) / 10^digits:: number
end

function Bnum3.compare(val1, val2): number
	val1, val2 = Bnum3.convert(val1), Bnum3.convert(val2)
	if val1.exp > val2.exp then return 1 elseif val1.exp < val2.exp then return -1 end
	if val1.man > val2.man then return 1 elseif val1.man < val2.man then return - 1 end
	return 0
end

function Bnum3.eq(val1, val2): boolean
	return Bnum3.compare(val1, val2) == 0
end

function Bnum3.me(val1, val2): boolean
	return Bnum3.compare(val1, val2) ~= 0
end

function Bnum3.lt(val1, val2): boolean
	return Bnum3.compare(val1, val2) == -1
end

function Bnum3.lte(val1, val2): boolean
	local cmp = Bnum3.compare(val1, val2)
	return cmp == -1 or cmp == 0
end

function Bnum3.gt(val1, val2): boolean
	return Bnum3.compare(val1, val2) == 1
end

function Bnum3.gte(val1, val2): boolean
	local cmp = Bnum3.compare(val1, val2)
	return cmp == 1 or cmp == 0
end

function Bnum3.between(val1, val2, val3): boolean
	return Bnum3.gte(val1, val2) or Bnum3.lte(val1, val3)
end

function Bnum3.short(val, digits, canComma: boolean?): string
	canComma = canComma or false
	val = Bnum3.convert(val)
	if val.man == -2 then return "NaN" end 
	if val.exp == 1e309 then return "inf" end
	local SNumber1: number, SNumber: number = val.man, val.exp
	local leftover = math.fmod(SNumber, 3)
	SNumber = math.floor(SNumber / 3)-1
	if SNumber <= -1 then return tostring(Bnum3.showDigits(SNumber1 * (10^leftover), digits)) end	
	local FirBigNumOnes: {string} = {"", "U","D","T","Qd","Qn","Sx","Sp","Oc","No"}
	local SecondOnes: {string} = {"", "De","Vt","Tg","qg","Qg","sg","Sg","Og","Ng"}
	local ThirdOnes: {string} = {"", "Ce", "Du","Tr","Qa","Qi","Se","Si","Ot","Ni"}
	local MultOnes: {string} = {"", "Mi","Mc","Na","Pi","Fm","At","Zp","Yc", "Xo", "Ve", "Me", "Due", "Tre", "Te", "Pt", "He", "Hp", "Oct", "En", "Ic", "Mei", "Dui", "Tri", "Teti", "Pti", "Hei", "Hp", "Oci", "Eni", "Tra","TeC","MTc","DTc","TrTc","TeTc","PeTc","HTc","HpT","OcT","EnT","TetC","MTetc","DTetc","TrTetc","TeTetc","PeTetc","HTetc","HpTetc","OcTetc","EnTetc","PcT","MPcT","DPcT","TPCt","TePCt","PePCt","HePCt","HpPct","OcPct","EnPct","HCt","MHcT","DHcT","THCt","TeHCt","PeHCt","HeHCt","HpHct","OcHct","EnHct","HpCt","MHpcT","DHpcT","THpCt","TeHpCt","PeHpCt","HeHpCt","HpHpct","OcHpct","EnHpct","OCt","MOcT","DOcT","TOCt","TeOCt","PeOCt","HeOCt","HpOct","OcOct","EnOct","Ent","MEnT","DEnT","TEnt","TeEnt","PeEnt","HeEnt","HpEnt","OcEnt","EnEnt","Hect", "MeHect"}
	if canComma then
		if SNumber == 0 or SNumber == 1 then
			return Bnum3.AddComma(val)
		elseif SNumber == 2 then
			return tostring(Bnum3.showDigits(SNumber1 * (10^leftover), digits)) .. "b"
		end
	else
		if SNumber == 0 then
			return tostring(Bnum3.showDigits(SNumber1 * (10^leftover), digits)) .. "k"
		elseif SNumber == 1 then 
			return tostring(Bnum3.showDigits(SNumber1 * (10^leftover), digits)) .. "m"
		elseif SNumber == 2 then
			return tostring(Bnum3.showDigits(SNumber1 * (10^leftover), digits)) .. "b"
		end
	end
	local txt: string = ""
	local function suffixpart(n: number)
		local Hundreds: number = math.floor(n/100)
		n = math.fmod(n, 100)
		local Tens: number = math.floor(n/10)
		n = math.fmod(n, 10)
		local Ones: number = math.floor(n/1)
		txt = txt .. FirBigNumOnes[Ones + 1]
		txt = txt .. SecondOnes[Tens + 1]
		txt = txt .. ThirdOnes[Hundreds + 1]
	end
	local function suffixpart2(n: number)
		if n > 0 then
			n = n + 1
		end
		if n > 1000 then
			n = math.fmod(n, 1000)
		end
		local Hundreds = math.floor(n/100)
		n = math.fmod(n, 100)
		local Tens = math.floor(n/10)
		n = math.fmod(n, 10)
		local Ones = math.floor(n/1)
		txt = txt .. FirBigNumOnes[Ones + 1]
		txt = txt .. SecondOnes[Tens + 1]
		txt = txt .. ThirdOnes[Hundreds + 1]
	end
	if SNumber < 1000 then
		suffixpart(SNumber)
		return tostring(Bnum3.showDigits(SNumber1 * (10^leftover), digits)) .. txt
	end
	for i=#MultOnes,0,-1 do
		if SNumber >= 10^(i*3) then
			suffixpart2(math.floor(SNumber / 10^(i*3))- 1)
			txt = txt .. MultOnes[i+1]
			SNumber = math.fmod(SNumber, 10^(i*3))
		end
	end
	return tostring(Bnum3.showDigits(SNumber1 * (10^leftover), digits)) .. txt
end

function Bnum3.shortE(val, digits): string
	val = Bnum3.convert(val)
	local first = {"", "U","D","T","Qd","Qn","Sx","Sp","Oc","No"}
	local second = {"", "De","Vt","Tg","qg","Qg","sg","Sg","Og","Ng"}
	local third = {'', 'Ce'}
	local function suffixPart(index)
		local hun = math.floor(index/100)
		index%=100
		local ten, one = math.floor(index/10), index%10
		return (first[one+1] or '') .. (second[ten+1] or '') .. (third[hun+1] or '')
	end
	local man, exp = val.man, val.exp
	local lf = math.fmod(math.floor(exp), 3)
	local index = 0
	while exp >= 1e3 do
		exp/=1e3
		index +=1
	end
	man = Bnum3.showDigits(man^lf + 0.001, digits)
	exp = math.floor(exp* 100 + 0.001) / 100
	if index == 1 then
		return man .. 'e' .. exp .. 'k'
	elseif index == 2 then
		return man .. 'e' .. exp .. 'm'
	elseif index == 3 then
		return man .. 'e' .. exp .. 'b'
	end
	return man .. 'e' .. exp ..suffixPart(index)
end

function Bnum3.HyperE(val, digit: number?): string
	val = Bnum3.convert(val)
	local man, exp = val.man, val.exp
	local newExp = math.floor(math.log10(exp))
	local lfe = math.fmod(exp, 3)
	exp /= 10^newExp
	man = Bnum3.showDigits(man* 10^ lfe, digit)
	exp = Bnum3.showDigits(exp*10 ^lfe, digit)
	return man .. 'e' .. exp .. 'e' ..  newExp
end

function Bnum3.AddComma(val): string
	val = Bnum3.toNumber(Bnum3.convert(val))
	local left, num, right = tostring(val):match('^([^%d]*%d)(%d*)(.-)$')
	num = num:reverse():gsub('(%d%d%d)', '%1,')
	return left .. num:reverse() .. right
end

function Bnum3.toString(val): string
	return val.man .. 'e' .. val.exp
end

function Bnum3.fshort(val, digit, canComma: boolean?): string
	if Bnum3.between(val, 0, 1) then
		return '1/' .. Bnum3.short(Bnum3.div(1, val), digit, canComma)
	end
	return Bnum3.short(val, digit, canComma)
end

function Bnum3.fshortE(val, digit): string
	if Bnum3.between(val, 0, 1) then
		return '1/' .. Bnum3.shortE(Bnum3.div(1, val), digit)
	end
	return Bnum3.shortE(val, digit)
end

function Bnum3.fHyperE(val): string
	if Bnum3.between(val, 0, 1) then
		return '1/' .. Bnum3.HyperE(Bnum3.div(1, val))
	end
	return Bnum3.HyperE(val)
end

function Bnum3.TimeTracker(value): string
	value = Bnum3.convert(value)
	local totalSeconds = math.floor(Bnum3.toNumber(value))
	local weeks = math.floor(totalSeconds / 604800)
	local days = math.floor((totalSeconds % 6000) / 86400)
	local hours = math.floor(totalSeconds / 3600)
	local minutes = math.floor((totalSeconds % 3600) / 60)
	local seconds = totalSeconds % 60

	local result = {}
	if weeks > 0 then
		table.insert(result, string.format('%dw', weeks))
	end
	if days > 0 then
		table.insert(result, string.format('%dd', days))
	end
	if hours > 0 then
		table.insert(result, string.format('%dh', hours))
	end
	if minutes > 0 then
		table.insert(result, string.format('%dm', minutes))
	end
	if seconds > 0 or #result == 0 then
		table.insert(result, string.format('%ds', seconds))
	end
	return table.concat(result, ":")
end

function Bnum3.roman(value): string
	value = Bnum3.convert(value)
	local num = Bnum3.toNumber(value)
	local res = ''
	local roman = {
		{1000, "M"}, {900, "CM"}, {500, "D"}, {400, "CD"},
		{100, "C"}, {90, "XC"}, {50, "L"}, {40, "XL"},
		{10, "X"}, {9, "IX"}, {5, "V"}, {4, "IV"},
		{1, "I"}
	}
	for _, pair in ipairs(roman) do
		while num >= pair[1] do
			res = res .. pair[2]
			num = num - pair[1]
		end
	end
	return res
end

function Bnum3.Changed(value: Instance, changed: (property: string) -> ())
	value.Changed:Connect(changed)
end

return Bnum3