class FamiliesController < ApplicationController
  before_action :set_family, only: %i[ show edit update destroy add_member ]

  # GET /families or /families.json
  def index
    @families = Family.left_joins(:visits)
                      .select('families.*, 
                               MAX(visits.visit_date) as last_visit_date,
                               MAX(visits.id) as last_visit_id')
                      .group('families.id')
                      .order('last_visit_date DESC NULLS LAST')
                      .includes(:members, :observations, :pending_needs, visits: :region)
  end

  # GET /families/1 or /families/1.json
  def show
    @new_member = @family.members.build
  end

  # GET /families/new
  def new
    @family = Family.new
    @family.members.build  # Isso adiciona um membro em branco por padrão
  end

  # GET /families/1/edit
  def edit
  end

  # POST /families or /families.json
  def create
    @family = Family.new(family_params)

    respond_to do |format|
      if @family.save
        format.html { redirect_to @family, notice: "Family was successfully created." }
        format.json { render :show, status: :created, location: @family }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @family.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /families/1 or /families/1.json
  def update
    respond_to do |format|
      if @family.update(family_params)
        format.html { redirect_to @family, notice: "Family was successfully updated." }
        format.json { render :show, status: :ok, location: @family }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @family.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /families/1 or /families/1.json
  def destroy
    @family.destroy!

    respond_to do |format|
      format.html { redirect_to families_path, status: :see_other, notice: "Family was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def add_member
    @new_member = @family.members.build(member_params)

    respond_to do |format|
      if @new_member.save
        format.turbo_stream
        format.html { redirect_to @family, notice: "Membro adicionado com sucesso." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace('new_member_form', partial: 'members/form', locals: { family: @family, member: @new_member }) }
        format.html { render :show }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_family
      @family = Family.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def family_params
      params.require(:family).permit(
        :reference_name, :street, :house_number, :city, :state, :phone1, :phone2,
        members_attributes: [:id, :name, :age, :role, :birth_date, :firm_in_faith, :_destroy],
        needs_attributes: [:id, :name, :beneficiary, :attended, :_destroy]
      )
    end

    def member_params
      params.require(:member).permit(:name, :age, :role, :birth_date, :firm_in_faith)
    end
end
