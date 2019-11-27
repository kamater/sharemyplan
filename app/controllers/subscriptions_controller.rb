class SubscriptionsController < ApplicationController
  def index
    @subscriptions = Subscription.all
    @service = Service.find(params[:service_id])
  end

  def new
    # @services = Service.select("category").group(:category)
    # @service = Service.where(:categroy => @services)
    # @options = Service.all.order(category: :asc)
    @service = Service.find(params[:service_id])
    @subscription = Subscription.new
  end

  def create
    @subscription             = Subscription.new(subscription_params)
    @service                  = Service.find(params[:service_id])
    @subscription.user        = current_user
    @subscription.service     = @service
    if @subscription.save
      # redirect_to subscriptions_path(@subscription)
      redirect_to root_path
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
