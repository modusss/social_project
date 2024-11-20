class RegionsController < ApplicationController
  before_action :set_region, only: %i[ show edit update destroy ]

  # GET /regions or /regions.json
  def index
    @regions = Region.all
    @regions_data = build_regions_data(@regions)
  end

  # GET /regions/1 or /regions/1.json
  def show
  end

  # GET /regions/new
  def new
    @region = Region.new
  end

  # GET /regions/1/edit
  def edit
  end

  # POST /regions or /regions.json
  def create
    @region = Region.new(region_params)

    respond_to do |format|
      if @region.save
        format.html { redirect_to @region, notice: "Region was successfully created." }
        format.json { render :show, status: :created, location: @region }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @region.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /regions/1 or /regions/1.json
  def update
    respond_to do |format|
      if @region.update(region_params)
        format.html { redirect_to regions_path, notice: "Região atualizada com sucesso." }
        format.json { render :show, status: :ok, location: @region }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @region.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /regions/1 or /regions/1.json
  def destroy
    @region.destroy!

    respond_to do |format|
      format.html { redirect_to regions_path, status: :see_other, notice: "Region was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_region
      @region = Region.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def region_params
      params.require(:region).permit(:name, :description)
    end

    def build_regions_data(regions)
      regions.map do |region|
        [
          { header: 'Nome', content: region.name, id: "region-name-#{region.id}" },
          { header: 'Descrição', content: region.description, id: "region-description-#{region.id}" },
          { header: 'Projetos', content: region.projects.distinct.count, id: "region-projects-#{region.id}" },
          { header: 'Famílias', content: region.families.count, id: "region-families-#{region.id}" },
          { 
            header: 'Ações', 
            content: helpers.safe_join([
              helpers.link_to(
                "Editar", 
                edit_region_path(region), 
                class: "rounded-lg py-2 px-3 bg-gray-100 text-gray-700 hover:bg-gray-200 inline-block font-medium mr-2"
              ),
              helpers.link_to(
                "Excluir", 
                region_path(region), 
                method: :delete, 
                data: { confirm: 'Tem certeza?' },
                class: "rounded-lg py-2 px-3 bg-red-100 text-red-700 hover:bg-red-200 inline-block font-medium"
              )
            ]),
            id: "region-actions-#{region.id}" 
          }
        ]
      end
    end
end
