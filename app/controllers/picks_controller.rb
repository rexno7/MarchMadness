class PicksController < ApplicationController
  before_filter :load_pool_entry

  # GET /entries
  # GET /entries.json
  def index
    @picks_array = @entry.picks.all
    @picks = Hash.new
    @picks_array.each do |pick|
      round = pick.round
      add = 0
      for i in 1...round
        add += 2 ** (6-i)
      end
      @picks[pick.game + add] = pick
    end
    @teams = @pool.teams

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @picks }
    end
  end

  # GET /entries/1
  # GET /entries/1.json
  def show
    @picks = @entry.picks.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @picks }
    end
  end

  # GET /entries/new
  # GET /entries/new.json
  def new
    @pick = @entry.picks.new
    @pick.game = params[:game]
    @pick.round = params[:round]
    @pick.pick = params[:pick]
    @entry.picks.each do |p|
      if p.game == @pick.game && p.round.to_i == @pick.round.to_i && p.pick != @pick.pick
        {:controller => 'picks', :action => 'destroy', :id => p.id}
      end
    end
    @pick.save
    redirect_to :action => 'index'
    #respond_to do |format|
      #format.html # new.html.erb
      #format.json { render json: @pick }
    #end
  end

  # GET /entries/1/edit
  def edit
    @pick = @entry.picks.find(params[:id])
    @pick.pick = params[:pick]
  end

  # POST /entries
  # POST /entries.json
  def create
    @pick = @entry.picks.new(params[:pick])

    respond_to do |format|
      if @pick.save
        format.html { redirect_to [@entry,@pick], notice: 'Entry was successfully created.' }
        format.json { render json: @pick, status: :created, location: @pick }
      else
        format.html { render action: "new" }
        format.json { render json: @pick.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /entries/1
  # PUT /entries/1.json
  def update
    @pick = @entry.picks.find(params[:id])

    respond_to do |format|
      if @pick.update_attributes(params[:entry])
        format.html { redirect_to [@entry,@pick], notice: 'Entry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pick.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entries/1
  # DELETE /entries/1.json
  def destroy
    @pick = @entry.picks.find(params[:id])
    @pick.destroy
    logger.debug("destroy")

    respond_to do |format|
      format.html { redirect_to [@pool,@entry] }
      format.json { head :no_content }
    end
  end

  private

  def load_pool_entry
    @entry = Entry.find(params[:entry_id])
    @pool = Pool.find(@entry.pool_id)
    @master = @pool.entries.find_by_entryname("Master")

    if @master.nil?
      redirect_to new_pool_entry_path(@pool)
    else

      # Convert Master picks to hash
      @mPicks = Hash.new
      @master.picks.all.each do |pick|
        round = pick.round
        add = 0
        for i in 1...round
          add += 2 ** (6-i)
        end
        @mPicks[pick.game + add] = pick
      end
    end
  end
end
