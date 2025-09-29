local Struct = require("CoreLib.Struct")

---@class PoE2Lib.Items.Currency
---@field Name string
---@field Metapath string
---@overload fun(fields: PoE2Lib.Items.Currency):PoE2Lib.Items.Currency
local Currency = Struct {
    Name = "",
    Metapath = "",
}

---@class PoE2Lib.Items.Currencies
return {
    Wisdom = Currency { Name = "Scroll of Wisdom", Metapath = "Metadata/Items/Currency/CurrencyIdentification" },
    Transmutation = Currency { Name = "Orb of Transmutation", Metapath = "Metadata/Items/Currency/CurrencyUpgradeToMagic" },
    Augmentation = Currency { Name = "Orb of Augmentation", Metapath = "Metadata/Items/Currency/CurrencyAddModToMagic" },
    Transmutation2 = Currency { Name = "Greater Orb of Transmutation", Metapath = "Metadata/Items/Currency/CurrencyUpgradeToMagic2" },
    Augmentation2 = Currency { Name = "Greater Orb of Augmentation", Metapath = "Metadata/Items/Currency/CurrencyAddModToMagic2" },
    Transmutation3 = Currency { Name = "Perfect Orb of Transmutation", Metapath = "Metadata/Items/Currency/CurrencyUpgradeToMagic3" },
    Augmentation3 = Currency { Name = "Perfect Orb of Augmentation", Metapath = "Metadata/Items/Currency/CurrencyAddModToMagic3" },
    Alchemy = Currency { Name = "Orb of Alchemy", Metapath = "Metadata/Items/Currency/CurrencyUpgradeToRare" },
    Regal = Currency { Name = "Regal Orb", Metapath = "Metadata/Items/Currency/CurrencyUpgradeMagicToRare" },
    Exalt = Currency { Name = "Exalted Orb", Metapath = "Metadata/Items/Currency/CurrencyAddModToRare" },
    Vaal = Currency { Name = "Vaal Orb", Metapath = "Metadata/Items/Currency/CurrencyCorrupt" },
}
