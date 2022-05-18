local Translations = {
	error = {
		failed = 'Falló',
		visit_branch = 'Por favor visita una sucursal para solicitar una tarjeta',
		failed_delete_card = 'No se pudo borrar la tarjeta',
		not_enough_money = 'No tienes suficiente dinero',
		daily_limit_reached = 'Has alcanzado el límite de retiros diario',

	},
	success = {
		card_deleted = 'La tarjeta ha sido borrada',
		daily_withdraw_limit_reset = 'Límite de retiros diario de extracción reseteado',
		withraw_from_credit_card = 'Retira $%{amount} de la tarjta de crédito. Retiro diario: %{withdraws}',

	}
    action = {
        use_atm = 'Usar ATM',
        accessing_atm = 'Accediento ATM...',
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
