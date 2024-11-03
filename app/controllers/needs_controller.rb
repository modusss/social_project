class NeedsController < ApplicationController
  before_action :set_family
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
    @need = @family.needs.build
  end

  # GET /needs/1/edit
  def edit
    @need = @family.needs.find(params[:id])
  end

  # POST /needs or /needs.json
  def create
    @needs = if params[:needs].present?
      params[:needs].map do |need_params|
        @family.needs.build(need_params.permit(:name, :beneficiary, :attended))
      end
    else
      [@family.needs.build(need_params)]
    end

    success = @needs.all? { |need| need.save }

    respond_to do |format|
      if success
        format.html { redirect_to family_path(@family), notice: "Necessidades registradas com sucesso." }
        format.json { render :show, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @needs.map(&:errors), status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /needs/1 or /needs/1.json
  def update
    @need = @family.needs.find(params[:id])
    
    respond_to do |format|
      if @need.update(need_params)
        format.html { redirect_to family_path(@family), notice: "Necessidade atualizada com sucesso." }
        format.json { render :show, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @need.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /needs/1 or /needs/1.json
  def destroy
    @need = @family.needs.find(params[:id])
    @need.destroy

    respond_to do |format|
      format.html { redirect_to family_path(@family), notice: "Necessidade removida com sucesso." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_family
      @family = Family.find(params[:family_id])
    end

    def set_need
      @need = @family.needs.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def needs_params
      params.require(:needs).permit(:name, :beneficiary, :attended)
    end

    def need_params
      params.require(:need).permit(:name, :beneficiary, :attended)
    end
end
