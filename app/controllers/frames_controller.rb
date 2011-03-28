class FramesController < ApplicationController
  # GET /frames
  # GET /frames.xml
  def index
    @frames = Frame.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @frames }
    end
  end

  # GET /frames/1
  # GET /frames/1.xml
  def show
    @frame = Frame.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @frame }
    end
  end

  # GET /frames/new
  # GET /frames/new.xml
  def new
    @frame = Frame.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @frame }
    end
  end

  # GET /frames/1/edit
  def edit
    @frame = Frame.find(params[:id])
  end

  # POST /frames
  # POST /frames.xml
  def create
    @frame = Frame.new(params[:frame])

    respond_to do |format|
      if @frame.save
        format.html { redirect_to(@frame, :notice => 'Frame was successfully created.') }
        format.xml  { render :xml => @frame, :status => :created, :location => @frame }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @frame.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /frames/1
  # PUT /frames/1.xml
  def update
    @frame = Frame.find(params[:id])

    respond_to do |format|
      if @frame.update_attributes(params[:frame])
        format.html { redirect_to(@frame, :notice => 'Frame was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @frame.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /frames/1
  # DELETE /frames/1.xml
  def destroy
    @frame = Frame.find(params[:id])
    @frame.destroy

    respond_to do |format|
      format.html { redirect_to(frames_url) }
      format.xml  { head :ok }
    end
  end
end
