class CotisationsController < ApplicationController
  def show
    @cotisation = Cotisation.find(params[:id])
    @subscription = @cotisation.subscription
    authorize @cotisation
  end

  def destroy
    @cotisation = Cotisation.find(params[:id])
    authorize @cotisation
    @subscription = @cotisation.subscription
    @subscription.available_places += 1
    @subscription.save

    @cotisation.stripe_subs_token.nil? ? raise : Stripe::Subscription.delete(@cotisation.stripe_subs_token)

    @cotisation.destroy
    redirect_to dashboard_path
  end

  def new
    @subscription = Subscription.find(params[:subscription_id])
    @cotisation = Cotisation.new
    authorize @cotisation
  end

  def create
    @subscription            = Subscription.find(params[:subscription_id])
    @cotisation              = Cotisation.new
    @cotisation.user         = current_user
    @cotisation.start_date   = Date.today
    @cotisation.subscription = @subscription
    @cotisation.state        = "pending"
    @cotisation.price_cents  = cotisation_price_per_month(@subscription.service)

    authorize @cotisation

    if @cotisation.save
      @cotisation.stripe_subs_token = init_abo
      init_session

      cagnotte_update
      @notification = Notification.create!(user: @subscription.user)
      notification

      redirect_to new_cotisation_payment_path(@cotisation)
    else
      render :new
    end
  end

  def cotisation_price_per_month(service)
    (service.total_price * 100 / service.number_of_places) + 30
  end

  def cagnotte_update
    @subscription.user.cagnotte += @subscription.price
    @subscription.available_places = @subscription.available_places - 1
    @subscription.save
    @subscription.user.save
  end

def stripe_checkout_session
  @stripe_checkout_session ||= Stripe::Checkout::Session.create(
    payment_method_types: ["card"],

    locale: :fr,
    customer: @company.stripe_id,
    success_url: cotisation_url(@cotisation),
    cancel_url: cotisation_url(@cotisation)
  )
  end

  def init_session
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      subscription_data: {
        items: [{
          plan: "plan_GIZVizVHFEes7d"
        }]
      },
      success_url: cotisation_url(@cotisation),
      cancel_url: cotisation_url(@cotisation),
      customer_email: @cotisation.user.email
    )
    @cotisation.update(checkout_session_id: session.id)
    return session
  end

  def init_abo
    customer = create_or_retrieve_customer(@cotisation.user)
    # Amount in cents
    @amount = @cotisation.price_cents
    begin
      stripe_subs_token = Stripe::Subscription.create(
        {
          customer: customer.id,
          items: [{ plan: 'plan_GIDRIFO3ktBxOk' }]
        }
      )
      # Stripe::Subscription.create(customer: customer.id, items: [{ plan: Rails.application.secrets.stripe[:premium_plan_id] }])
      # Stripe::Subscription.create(customer: customer.id, items: [{ plan: ENV['STRIPE_SECRET_KEY'] }])
    rescue Stripe::CardError => e
      flash[:error] = e.message
      raise
      redirect_to new_cotisation_payment_path(@cotisation)
    end
    stripe_subs_token.id
  end

  def create_or_retrieve_customer(user)
    # Try to retreive Stripe customer and create if not already registered
    customer = retrieve_stripe_customer(user)

    if customer.nil?
      customer = Stripe::Customer.create({
          name: user.first_name + ' ' + user.first_name,
          email: user.email
          # payment_method:  ['card'],
          # invoice_settings: { default_payment_method: 'card', },
      })

      user.update! stripe_token: customer.id
    end
    customer
  end

  def retrieve_stripe_customer(user)
    # @params [User]
    # @return [Stripe::Customer|Nil]
    return nil if user.stripe_token.nil?

    begin
      customer = Stripe::Customer.retrieve user.stripe_token
    rescue Stripe::InvalidRequestError
      # if stripe token is invalid, remove it!
      user.update! stripe_token: nil
      return nil
    end
    customer
  end

  def cotisation_next_payment(cotisation)
    next_payment = cotisation.updated_at
    next_payment += 1.month until next_payment > DateTime.now
    next_payment
  end

  def cotisation_last_payment(cotisation)
    last_payment = cotisation.created_at
    last_payment += 1.month while last_payment <= DateTime.now
    last_payment
  end


  def stripe_subscription__item_list(subscription_id)
    Stripe::SubscriptionItem.list(subscription: subscription_id)
  end

  private

  def params_cotisation
    params.require(:cotisation).permit(:start_date)
  end
end
