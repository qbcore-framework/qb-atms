Locales['en'] = {
    
    
    ["failed"] = "Failed!",

    -- client/main.lua
    ['client_main_event_loadATM_progressbar_1'] = "Accessing ATM",
    ['client_main_event_loadATM_notify_1'] = "You do not have a debit card to pay with, please visit a branch to order a card. or ensure one is on your person.",
    ["client_main_callback_removeCard_notify_1"]    = 'Card has deleted.',
    ["client_main_callback_removeCard_notify_2"]    = 'Failed to delete card.',

    -- server/main.lua
    ['server_main_CreateThread_notify'] = "Daily limit resetted.",
    ['server_main_event_doAccountWithdraw_notify_1'] = "Withdraw $%s from credit card. Daily Withdraws: %s",
    ['server_main_event_doAccountWithdraw_notify_2'] = "You cant go into minus in ATM.",
    ['server_main_event_doAccountWithdraw_notify_3'] = "You have reached the daily limit."
}


-- QBCore.Shared._U(Locales, 'server_main_event_doAccountWithdraw_notify_3')