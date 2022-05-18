local Translations = {
    error = {
        failed = 'Failed',
        visit_branch = 'Please visit a branch to order a card',
        failed_delete_card = 'Failed to delete card',
        not_enough_money = 'Not Enough Money',
        daily_limit_reached = 'You have reached the daily limit'
    },
    success = {
        card_deleted = 'Card has been deleted',
        daily_withdraw_limit_reset = 'Daily Withdraw Limit Reset',
        withraw_from_credit_card = 'Withdraw $%{amount} from credit card. Daily Withdraws: %{withdraws}'
    },
    action = {
        use_atm = 'Use ATM',
        accessing_atm = 'Accessing ATM...'
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
