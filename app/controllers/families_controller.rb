class FamiliesController < ApplicationController
  before_action :set_family, only: %i[ show edit update destroy add_member ]
  before_action :calculate_ages, only: %i[ show edit]
  before_action :prepare_form_data, only: %i[ show ]

  # GET /families or /families.json
  def index
    @families = Family.left_joins(:visits)
                      .select('families.*, 
                               MAX(visits.visit_date) as last_visit_date,
                               MAX(visits.id) as last_visit_id')
                      .group('families.id')
                      .order('last_visit_date DESC NULLS LAST')
                      .includes(:members, :observations, :pending_needs, visits: :region)
                      .page(params[:page])
                      .per(100)

    @rows = @families.map do |family|
      last_visit = family.visits.order(visit_date: :desc).first
      last_visit_region = last_visit.present? ? (last_visit&.region&.name || 'Sem região') : 'Sem região'
      last_visit_observation = last_visit.present? ? (last_visit.observations.last&.observation&.truncate(50) || 'Sem observações') : 'Sem observações'
      [
        { 
          header: 'Família', 
          content: helpers.link_to(
            if family.reference_name.present?
              "#{family.reference_name} (#{family.members.count} #{family.members.count == 1 ? 'pessoa' : 'pessoas'})"
            else
              "#{family.members.pluck(:name).join(', ')} (#{family.members.count} #{family.members.count == 1 ? 'pessoa' : 'pessoas'})"
            end,
            family_path(family), 
            class: "text-blue-600 hover:text-blue-800 hover:underline transition duration-300 ease-in-out"
          ), 
          id: "family-#{family.id}" 
        },
        { header: 'Endereço Completo', content: "#{family.street}, #{family.house_number} - #{family.city}/#{family.state}", id: "family-address-#{family.id}" },
        { 
          header: 'Telefones', 
          content: [
            helpers.phone_links(family.phone1),
            helpers.phone_links(family.phone2)
          ].reject(&:blank?).join(' / ').html_safe, 
          id: "family-phones-#{family.id}" 
        },
        { header: 'Última visita', content: last_visit.present? ? last_visit.visit_date.strftime('%d/%m/%Y') : 'Sem visitas', id: "family-last-visit-#{family.id}" },
        { header: 'Qtd. visitas', content: family.visits.count, id: "family-visits-count-#{family.id}" },
        { header: 'Região da última visita', content: last_visit_region, id: "family-last-visit-region-#{family.id}" },
        { header: 'Última Observação', content: last_visit_observation, id: "family-last-observation-#{family.id}", class: "px-6 py-4 text-sm text-gray-500 max-w-[450px] whitespace-normal break-words text-left" },
        { header: 'Necessidades Pendentes', content: family.needs.where(attended: false).pluck(:name).join(", "), id: "family-needs-#{family.id}", class: "max-w-[450px] whitespace-normal break-words text-left" },
        { header: 'Registrar nova visita', content: helpers.link_to('Nova visita', new_family_visit_path(family), class: 'text-blue-600 hover:text-blue-800 hover:underline transition duration-300 ease-in-out'), id: "family-new-visit-#{family.id}" },
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

  def search
    @families = Family.left_joins(:visits)
                      .left_joins(:members)
                      .select('families.*, 
                              MAX(visits.visit_date) as last_visit_date,
                              MAX(visits.id) as last_visit_id')
                      .where('families.reference_name ILIKE :query OR 
                             (families.reference_name IS NULL AND members.name ILIKE :query) OR
                             families.phone1 ILIKE :query OR 
                             families.phone2 ILIKE :query', 
                             query: "%#{params[:query]}%")
                      .group('families.id')
                      .order('last_visit_date DESC NULLS LAST')
                      .includes(:members, :observations, :pending_needs, visits: :region)
                      .page(params[:page])
                      .per(100)

    @rows = build_rows(@families)

    respond_to do |format|
      format.turbo_stream { 
        render turbo_stream: turbo_stream.replace('families_table', partial: 'families/table', locals: { rows: @rows })
      }
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
      case action_name
      when 'index'
        @families.each do |family|
          family.members.each do |member|
            member.age = member.calculate_age
          end
        end
      when 'show', 'edit'
        @family.members.each do |member|
          member.age = member.calculate_age
        end
      end
    end

    def prepare_form_data
      @projects = Project.all
      @regions = Region.all
    end

    # Move a lógica de construção das rows para um método separado
    def build_rows(families)
      families.map do |family|
        last_visit = family.visits.order(visit_date: :desc).first
        last_visit_region = last_visit.present? ? (last_visit&.region&.name || 'Sem região') : 'Sem região'
        last_visit_observation = last_visit.present? ? (last_visit.observations.last&.observation&.truncate(50) || 'Sem observações') : 'Sem observações'
        [
          { 
            header: 'Família', 
            content: helpers.link_to(
              if family.reference_name.present?
                "#{family.reference_name} (#{family.members.count} #{family.members.count == 1 ? 'pessoa' : 'pessoas'})"
              else
                "#{family.members.pluck(:name).join(', ')} (#{family.members.count} #{family.members.count == 1 ? 'pessoa' : 'pessoas'})"
              end,
              family_path(family), 
              class: "text-blue-600 hover:text-blue-800 hover:underline transition duration-300 ease-in-out"
            ), 
            id: "family-#{family.id}" 
          },
          { 
            header: 'Telefones', 
            content: [
              helpers.phone_links(family.phone1),
              helpers.phone_links(family.phone2)
            ].reject(&:blank?).join(' / ').html_safe, 
            id: "family-phones-#{family.id}" 
          },
          { header: 'Endereço Completo', content: "#{family.street}, #{family.house_number} - #{family.city}/#{family.state}", id: "family-address-#{family.id}" },
          { header: 'Última visita', content: last_visit.present? ? last_visit.visit_date.strftime('%d/%m/%Y') : 'Sem visitas', id: "family-last-visit-#{family.id}" },
          { header: 'Qtd. visitas', content: family.visits.count, id: "family-visits-count-#{family.id}" },
          { header: 'Região da última visita', content: last_visit_region, id: "family-last-visit-region-#{family.id}" },
          { header: 'Última Observação', content: last_visit_observation, id: "family-last-observation-#{family.id}", class: "px-6 py-4 text-sm text-gray-500 max-w-[450px] whitespace-normal break-words text-left" },
          { header: 'Necessidades Pendentes', content: family.needs.where(attended: false).pluck(:name).join(", "), id: "family-needs-#{family.id}", class: "max-w-[450px] whitespace-normal break-words text-left" },
          { header: 'Registrar nova visita', content: helpers.link_to('Nova visita', new_family_visit_path(family), class: 'text-blue-600 hover:text-blue-800 hover:underline transition duration-300 ease-in-out'), id: "family-new-visit-#{family.id}" },
          { header: 'Ações', content: render_to_string(partial: 'families/actions', locals: { family: family }), id: "family-actions-#{family.id}" }
        ]
      end
    end
end
