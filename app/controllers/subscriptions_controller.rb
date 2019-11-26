class SubscriptionsController < ApplicationController
  def index
    @subscriptions = Subscription.all
  end

  def new
    @subscription = Subscription.new
  end

  def create
    @subscription = Subscription.new(subscription_params)
    if @subscription.save
      redirect_to services_path
    else
      render :new
    end
  end

  def edit
    @subscription = Subscription.find(params[:id])
  end

  def update
    @subscription = Subscription.find(params[:id])
    if @subscription.update(Subscription_params)
      redirect_to subscription_path
    else
      render :edit
    end
  end

  def destroy
    @subscription = Subscription.find(params[:di])
    @subscription.delete

    redirect_to dashboard_path
  end

  private

  def subscription_params
    params.require(:subscription).permit(:price, :available_places, :identifiant, :password)
  end
end