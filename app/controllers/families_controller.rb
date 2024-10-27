class FamiliesController < ApplicationController
  before_action :set_family, only: %i[ show edit update destroy add_member ]
  before_action :calculate_ages, only: %i[ show edit]

  # GET /families or /families.json
  def index
    @families = Family.left_joins(:visits)
                      .select('families.*, 
                               MAX(visits.visit_date) as last_visit_date,
                               MAX(visits.id) as last_visit_id')
                      .group('families.id')
                      .order('last_visit_date DESC NULLS LAST')
                      .includes(:members, :observations, :pending_needs, visits: :region)

    @rows = @families.map do |family|
      [
        { header: 'Nome de Referência', content: family.reference_name, id: "family-name-#{family.id}" },
        { header: 'Endereço Completo', content: "#{family.street}, #{family.house_number} - #{family.city}/#{family.state}", id: "family-address-#{family.id}" },
        { header: 'Telefones', content: [family.phone1, family.phone2].compact.join(' / '), id: "family-phones-#{family.id}" },
        { header: 'Qtd. Membros', content: family.members.count, id: "family-members-count-#{family.id}" },
        { header: 'Última visita', content: family.last_visit_date ? family.last_visit_date.strftime('%d/%m/%Y') : 'Sem visitas', id: "family-last-visit-#{family.id}" },
        { header: 'Qtd. visitas', content: family.visits.count, id: "family-visits-count-#{family.id}" },
        { header: 'Região da última visita', content: family.visits.find { |v| v.id == family.last_visit_id }&.region&.name || 'Sem região', id: "family-last-visit-region-#{family.id}" },
        { header: 'Última Observação', content: family.observations.last&.observation&.truncate(50) || 'Sem observações', id: "family-last-observation-#{family.id}" },
        { header: 'Necessidades Pendentes', content: family.pending_needs.map { |need| need.description.truncate(30) }.join(', '), id: "family-pending-needs-#{family.id}" },
        { header: 'Ações', content: render_to_string(partial: 'families/actions', locals: { family: family }), id: "family-actions-#{family.id}" }
      ]
    end
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

    def calculate_ages
      if action_name == 'index'
        @families.each do |family|
          family.members.each do |member|
            member.age = member.calculate_age
          end
        end
      elsif action_name == 'show'
        @family.members.each do |member|
          member.age = member.calculate_age
        end
      end
    end
end
