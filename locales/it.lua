Locales['it'] = {
    
    
    ["failed"] = "Fallito!",

    -- client/main.lua
    ['client_main_event_loadATM_progressbar_1'] = "Accesso ATM",
    ['client_main_event_loadATM_notify_1'] = "Non hai una carta di debito con cui pagare, visita una filiale per ordinare una carta.",
    ["client_main_callback_removeCard_notify_1"]    = 'La scheda è stata eliminata.',
    ["client_main_callback_removeCard_notify_2"]    = 'Impossibile eliminare la scheda.',

    -- server/main.lua
    ['server_main_CreateThread_notify'] = "Limite giornaliero reimpostato.",
    ['server_main_event_doAccountWithdraw_notify_1'] = "Ritirati $%s dalla carta di credito. Ritiri gionalieri: %s",
    ['server_main_event_doAccountWithdraw_notify_2'] = "Non puoi andare in negativo.",
    ['server_main_event_doAccountWithdraw_notify_3'] = "Hai raggiunto il limite giornaliero."
}


-- QBCore.Shared._U(Locales, 'server_main_event_doAccountWithdraw_notify_3')