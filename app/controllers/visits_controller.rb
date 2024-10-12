class VisitsController < ApplicationController
  before_action :set_visit, only: %i[ show edit update destroy ]

  # GET /visits or /visits.json
  def index
    @visits = Visit.all
  end

  # GET /visits/1 or /visits/1.json
  def show
  end

  # GET /visits/new
  def new
    @visit = Visit.new
    prepare_form_data
  end

  # GET /visits/1/edit
  def edit
    prepare_form_data
  end

  # POST /visits or /visits.json
  def create
    @visit = Visit.new(visit_params)
    @visit.user = current_user # Assuming you have a current_user method

    respond_to do |format|
      if @visit.save
        format.html { redirect_to @visit, notice: "Visit was successfully created." }
        format.json { render :show, status: :created, location: @visit }
      else
        prepare_form_data
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @visit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /visits/1 or /visits/1.json
  def update
    respond_to do |format|
      if @visit.update(visit_params)
        format.html { redirect_to @visit, notice: "Visit was successfully updated." }
        format.json { render :show, status: :ok, location: @visit }
      else
        prepare_form_data
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @visit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /visits/1 or /visits/1.json
  def destroy
    @visit.destroy!

    respond_to do |format|
      format.html { redirect_to visits_path, status: :see_other, notice: "Visit was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_visit
      @visit = Visit.find(params[:id])
    end

    def visit_params
      params.require(:visit).permit(
        :visit_date,
        family_attributes: [:id, :reference_name, :street, :house_number, :city, :state, :phone1, :phone2,
          members_attributes: [:id, :name, :age, :role, :birth_date, :firm_in_faith, :_destroy]
        ],
        observations_attributes: [:id, :observation, :_destroy],
        pending_needs_attributes: [:id, :description, :_destroy],
        visited_project_attributes: [:id, :project_id, :region_id, :_destroy]
      )
    end

    def prepare_form_data
      @visit.build_family unless @visit.family
      @visit.family.members.build if @visit.family.members.empty?
      @visit.observations.build if @visit.observations.empty?
      @visit.pending_needs.build if @visit.pending_needs.empty?
      @visit.build_visited_project unless @visit.visited_project
      @projects = Project.all
      @regions = Region.all
    end
end
