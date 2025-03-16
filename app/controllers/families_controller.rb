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

    # Apply food basket status filter if present
    if params[:food_basket_status].present?
      @families = @families.where(food_basket_status: params[:food_basket_status])
    end

    @rows = build_rows(@families)
  end

  # GET /families/1 or /families/1.json
  def show
    @new_member = @family.members.build
  end

  # GET /families/new
  def new
    @family = Family.new
    @family.members.build  # Isso adiciona um membro em branco por padrão
    set_member_indices
  end

  # GET /families/1/edit
  def edit
    set_member_indices
  end

  # POST /families or /families.json
  def create
    @family = Family.new(family_params)

    # Auto-update status based on dates if requested
    if params[:family][:auto_update_status] == "1"
      @family.update_food_basket_status!
    end

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
        # Auto-update status based on dates if requested
        if params[:family][:auto_update_status] == "1"
          @family.update_food_basket_status!
        end
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
    @search_type = params[:search_type] || 'Nome'
    @query = params[:query]

    if @query.present?
      case @search_type
      when 'Nome'
        @families = Family.joins(:members)
                         .where('families.reference_name ILIKE :query OR members.name ILIKE :query', 
                                query: "%#{@query}%")
                         .distinct
      when 'Telefone'
        @families = Family.where('phone1 ILIKE ? OR phone2 ILIKE ?', "%#{@query}%", "%#{@query}%")
      when 'Necessidade'
        @families = Family.joins(:needs)
                         .where('needs.name ILIKE ?', "%#{@query}%")
                         .distinct
      when 'CPF'
        normalized_cpf = normalize_cpf(@query)
        @families = Family.joins(:members)
                         .where("REGEXP_REPLACE(members.cpf, '[^0-9]', '', 'g') LIKE ?", "%#{normalized_cpf}%")
                         .distinct
      end
    else
      @families = Family.all
    end

    @families = @families.presence || Family.none
    
    @families = @families.order(created_at: :desc).page(params[:page])

    @rows = build_rows(@families)

    respond_to do |format|
      format.turbo_stream { 
        render turbo_stream: turbo_stream.replace('families_table', 
               partial: 'families/table', 
               locals: { rows: @rows })
      }
    end
  end

  def set_member_indices
    @family.members.each_with_index do |member, index|
      member.index = index + 1
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
        :neighborhood, :housing_type, :financed_house, :financing_value,
        :rent_value, :has_loan, :loan_value, :family_income,
        :food_basket_start_date, :food_basket_duration_months,
        :food_basket_status,
        members_attributes: [:id, :name, :age, :role, :birth_date, :firm_in_faith, 
                            :profession, :employed, :income, :has_benefit, :benefit_value, 
                            :can_read, :lives_in_house, :lives_with_partner, :cpf,
                            :attends_church, :disability, :shirt_size, :pants_size, :shoe_size, :_destroy],
                            needs_attributes: [:id, :name, :beneficiary, :attended, :_destroy]
      ).tap do |whitelisted|
        whitelisted[:members_attributes]&.each do |_, member_attrs|
          member_attrs[:role] = nil if member_attrs[:role].blank?
        end
      end
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
              if family.members.count == 1
                family.members.first.name
              else
                if family.reference_name.present?
                  "#{family.reference_name} (#{family.members.count} pessoas)"
                else
                  "#{family.members.first.name} (#{family.members.count} pessoas)"
                end
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
          { 
            header: 'Status da Cesta', 
            content: helpers.food_basket_status_badge(family.food_basket_status), 
            id: "family-food-basket-status-#{family.id}" 
          },
          { header: 'Última visita', content: last_visit.present? ? last_visit.visit_date.strftime('%d/%m/%Y') : 'Sem visitas', id: "family-last-visit-#{family.id}" },
          { header: 'Qtd. visitas', content: family.visits.count, id: "family-visits-count-#{family.id}" },
          { header: 'Região da última visita', content: last_visit_region, id: "family-last-visit-region-#{family.id}" },
          { header: 'Última Observação', content: last_visit_observation, id: "family-last-observation-#{family.id}", class: "px-6 py-4 text-sm text-gray-500 max-w-[450px] whitespace-normal break-words text-left" },
          { header: 'Necessidades Pendentes', content: family.needs.where(attended: false).pluck(:name).join(", "), id: "family-needs-#{family.id}", class: "max-w-[450px] whitespace-normal break-words text-left" },
          { header: 'Registrar nova visita', content: helpers.link_to('Nova visita', new_family_visit_path(family), class: 'text-blue-600 hover:text-blue-800 hover:underline transition duration-300 ease-in-out'), id: "family-new-visit-#{family.id}" }
        ]
      end
    end

    # Helper method to normalize CPF by removing non-digit characters
    def normalize_cpf(cpf)
      cpf.to_s.gsub(/[^0-9]/, '')
    end
end
