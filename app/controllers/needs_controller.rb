class NeedsController < ApplicationController
  before_action :set_need, only: %i[ show edit update destroy ]

  # GET /needs or /needs.json
  def index
    @needs = Need.all
  end

  # GET /needs/1 or /needs/1.json
  def show
  end

  # GET /needs/new
  def new
    @need = Need.new
  end

  # GET /needs/1/edit
  def edit
  end

  # POST /needs or /needs.json
  def create
    @need = Need.new(need_params)

    respond_to do |format|
      if @need.save
        format.html { redirect_to @need, notice: "Need was successfully created." }
        format.json { render :show, status: :created, location: @need }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @need.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /needs/1 or /needs/1.json
  def update
    respond_to do |format|
      if @need.update(need_params)
        format.html { redirect_to @need, notice: "Need was successfully updated." }
        format.json { render :show, status: :ok, location: @need }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @need.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /needs/1 or /needs/1.json
  def destroy
    @need.destroy!

    respond_to do |format|
      format.html { redirect_to needs_path, status: :see_other, notice: "Need was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_need
      @need = Need.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def need_params
      params.require(:need).permit(:family_id, :name, :beneficiary, :attended)
    end
end
