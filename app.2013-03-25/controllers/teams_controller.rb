class TeamsController < ApplicationController
  before_filter :load_pool

  def index
    @teams = @pool.teams

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @teams }
    end
  end

  def new
    @team = @pool.teams.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @team }
    end
  end

  # GET /entries/1/edit
  def edit
    @team = @pool.team.find(params[:id])
  end

  # POST /entries
  # POST /entries.json
  def create
    @team = @pool.team.new(params[:team])

    respond_to do |format|
      if @team.save
        format.html { redirect_to [@pool,@team], notice: 'Team was successfully created.' }
        format.json { render json: @team, status: :created, location: @team }
      else
        format.html { render action: "new" }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  def load_pool
    @pool = Pool.find(params[:pool_id])
  end
end
