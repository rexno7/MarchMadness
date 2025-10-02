class PoolsController < ApplicationController
  def index
    @pools = Pool.all
  end
  
  def show
    @pool = Pool.find(params[:id])
  end
  
  def new
    @pool = Pool.new
    64.times { @pool.teams.build }
  end
  
  def create
    @pool = Pool.new(params[:pool])
    if @pool.save
      flash[:notice] = "Successfully created pool."
      redirect_to @pool
    else
      render :action => 'new'
    end
  end
  
  def edit
    @pool = Pool.find(params[:id])
  end
  
  def update
    @pool = Pool.find(params[:id])
    if @pool.update_attributes(params[:pool])
      flash[:notice] = "Successfully updated pool."
      redirect_to @pool
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @pool = Pool.find(params[:id])
    @pool.destroy
    flash[:notice] = "Successfully destroyed pool."
    redirect_to pools_url
  end
end
