class LendingsController < ApplicationController

  before_action :authenticate_user!
  def index
    @lendings=current_user.lendings
  end

  def show
    @lending=Lending.find(params[:id])
  end

  def new
    @lending=Lending.new
  end

  def create
    @lending = current_user.lendings.new(lending_params)
    if @lending.save
      redirect_to lendings_path, notice: 'Loan request was successfully created.'
    else
      render :new
    end
  end

  def edit
    @lending=Lending.find(params[:id])
  end

  def update
    @lending=Lending.find(params[:id])
    @admin_user = AdminUser.first
    @user=current_user
    unless current_user.customer?  
      if @lending.amount != lending_params[:amount].to_f || @lending.interest_rate != lending_params[:interest_rate].to_f
        @lending.update(state: "adjustment")
        flash[:notice] = "Loan state changed to Adjustment."
      end
    end
    if params[:state] == "confirm"
      @lending.update(state: "open")
      flash[:notice] = "Loan state changed to Open." 
      @admin_user.update(wallet: @admin_user.wallet - @lending.amount) 
      CalInterestRateJob.perform_at(10.seconds.from_now)
      @user.update(wallet:@user.wallet+@lending.amount)
    elsif params[:state] == "reject"
      @lending.update(state: "rejected")
      flash[:notice] = "Loan state changed to Rejected."
    else
      @lending.update(state: "closed")
      flash[:notice] = "Loan is paid." 
      @user.update(wallet:@user.wallet-(@lending.amount+@lending.simple_interest) )
      @admin_user.update(wallet:@admin_user.wallet+(@lending.amount+@lending.simple_interest) )
    end  
    if @lending.update(lending_params)
      redirect_to lendings_path, notice: 'Lending money was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @lending=Lending.find(params[:id])
    @lending.destroy
    redirect_to lendings_path, notice: 'Lending money was successfully destroyed.'
  end
  
  private
  def lending_params
    params.require(:lending).permit(:amount, :interest_rate)
  end

end
