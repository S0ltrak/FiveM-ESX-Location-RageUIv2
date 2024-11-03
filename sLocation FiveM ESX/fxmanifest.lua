fx_version "cerulean"
game "gta5" 
author "S0ltrak"


shared_scripts {
    "@ox_lib/init.lua",
    "Config_Location.lua",

}

server_scripts {
    "Config_Location.lua",

    "sv_location.lua",

}


client_scripts {
    "Config_Location.lua",

    "RageUI/RMenu.lua",
    "RageUI/menu/RageUI.lua",
    "RageUI/menu/Menu.lua",
    "RageUI/menu/MenuController.lua",
    "RageUI/components/*.lua",
    "RageUI/menu/elements/*.lua",
    "RageUI/menu/items/*.lua",
    "RageUI/menu/panels/*.lua",
    "RageUI/menu/windows/*.lua",

    "cl_location.lua",
}