########################################
# ci dessous version SANS le weebhook
########################################
Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
  secret_key:      ENV['STRIPE_SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]


################################################
#
# ci dessous version AVEC le weebhook
#
#############################################
# Rails.configuration.stripe = {
#   publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
#   secret_key:      ENV['STRIPE_SECRET_KEY'],
#   signing_secret:  ENV['STRIPE_WEBHOOK_SECRET_KEY']
# }

# Stripe.api_key = Rails.configuration.stripe[:secret_key]


# StripeEvent.signing_secret = Rails.configuration.stripe[:signing_secret]

# StripeEvent.configure do |events|
#   events.subscribe 'checkout.session.completed', StripeCheckoutSessionService.new
#   events.subscribe 'payout.failed', StripeCheckoutSessionService.new
# end

# Ne pas oublier de dégriser la route dans config/route.rb
