class EntriesController < ApplicationController
  before_filter :load_pool

  # GET /entries
  # GET /entries.json
  def index
    @entries = @pool.entries.all
    @entries.delete_if { |entry| entry.entryname == "Master" }

    # Convert Master picks to hash
    @mPicks = get_picks_hash(@master.picks.all)

    roundPoints = [ 1, 2, 3, 4, 6, 8 ]
    roundSize = [ 32, 48, 56, 60, 62, 63 ]

    @finalFourPicks = Hash.new

    @entries.each do |entry|

      log = Logger.new(STDOUT)
      log.debug(entry.entryname)

      # Convert entry picks to hash
      #@ePicks = Hash.new
      @ePicks = get_picks_hash(entry.picks.all)

      # Calculate the score and maxscore
      # Note: maxscore does not subtract for future empty entry picks
      score = 0
      maxscore = 124
      @mPicks.keys.each do |mkey|
        mpick = @mPicks[mkey]
        epick = @ePicks[mkey]
        if !mpick.nil?
          if epick.nil?
            maxscore -= roundPoints[mpick.round - 1]
            next
          end
          if mpick.pick == epick.pick
            score += roundPoints[mpick.round - 1]
          else
            log.debug("  " + epick.round.to_s + ": " + epick.pick + "==" + mpick.pick)

            maxscore -= roundPoints[mpick.round - 1]
            add = roundSize[mpick.round - 1]
            badpick = epick.pick
            mpick = @mPicks[add + (mpick.game / 2)]
            epick = @ePicks[add + (epick.game / 2)]
            while !epick.nil? && mpick.nil? do
              log.debug("    " + epick.round.to_s + ": " + epick.pick + "==" + badpick)

              if epick.pick == badpick
                maxscore -= roundPoints[epick.round - 1]
                add = roundSize[epick.round - 1]
                mpick = @mPicks[add + (epick.game / 2)]
                epick = @ePicks[add + (epick.game / 2)]
              else
                break
              end
            end
          end
        end
      end

      # Check for empty future picks to subtract from maxscore
      63.times do |key|
        if @mPicks[key].nil? && @ePicks[key].nil?
          for i in 0...(roundSize.length) do
            logger.debug(entry.entryname + ": " + key.to_s + " - " + i.to_s)
            if key < roundSize[i]
              maxscore -= roundPoints[i]
              break
            end
          end
        end
      end

      entry.points = score
      entry.maxpoints = maxscore

      winner = entry.picks.find_all_by_round(6)[0].pick
      runnerup = nil
      entry.picks.find_all_by_round(5).each do |t|
        if t.pick != winner
          runnerup = t.pick
          break
        end
      end
      othertwo = Array.new
      entry.picks.find_all_by_round(4).each do |t|
        if t.pick != winner && t.pick != runnerup
          othertwo.push(t.pick)
        end
      end

      finalfour = [ winner, runnerup, othertwo[0], othertwo[1] ]
      @finalFourPicks[entry.id] = finalfour

    end

    if params[:sort_by] == "entryname"
      @entries = @entries.sort! { |a,b| a.entryname <=> b.entryname }
    elsif params[:sort_by] == "maxpoints"
      @entries = @entries.sort! { |a,b| b.maxpoints <=> a.maxpoints }
    else
      @entries = @entries.sort! { |a,b| b.points <=> a.points }
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @entries }
    end
  end

  # GET /entries/1
  # GET /entries/1.json
  def show
    @entry = @pool.entries.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @entry }
    end
  end

  # GET /entries/new
  # GET /entries/new.json
  def new
    @entry = @pool.entries.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @entry }
    end
  end

  # GET /entries/1/edit
  def edit
    @entry = @pool.entries.find(params[:id])
  end

  # POST /entries
  # POST /entries.json
  def create
    @entry = @pool.entries.new(params[:entry])
    @entry.maxpoints = 124
    @entry.points = 0

    respond_to do |format|
      if @entry.save
        format.html { redirect_to [@pool,@entry], notice: 'Entry was successfully created.' }
        format.json { render json: @entry, status: :created, location: @entry }
      else
        format.html { render action: "new" }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /entries/1
  # PUT /entries/1.json
  def update
    @entry = @pool.entries.find(params[:id])

    respond_to do |format|
      if @entry.update_attributes(params[:entry])
        format.html { redirect_to [@pool,@entry], notice: 'Entry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entries/1
  # DELETE /entries/1.json
  def destroy
    @entry = @pool.entries.find(params[:id])
    @entry.destroy

    respond_to do |format|
      format.html { redirect_to pool_entries_path(@pool) }
      format.json { head :no_content }
    end
  end

  def calculate
    @entries = @pool.entries.all
    points = [ 1, 2, 3, 4, 6, 8 ]
    @entries.each do |entry|
      if entry.entryname == "master"
        @master = entry
        break
      end
    end

    @entries.each do |entry|
      if entry.entryname != "master"
        # Update score
        score = 0
        master.picks.all.each do |mpick|
          entry.picks.all.each do |epick|
            if mpick.game == epick.game && mpick.round == epick.round && mpick.pick == mpick.pick
              score += points[mpick.round-1]
            end
          end
        end
        puts entry.entryname + ": " + score
      end
    end

    #route_to 'index'
  end

  private

  def load_pool
    @pool = Pool.find(params[:pool_id])

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

  def get_picks_hash (pickArray)
    pickHash = Hash.new
    pickArray.each do |pick|
      round = pick.round
      add = 0
      for i in 1...round
        add += 2 ** (6-i)
      end
      pickHash[pick.game + add] = pick
    end

    return pickHash
  end
end
