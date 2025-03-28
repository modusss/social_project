class VisitsController < ApplicationController
  before_action :set_visit, only: %i[ show edit update destroy ]

  # GET /visits or /visits.json
  def index
    @visits = Visit.includes(:user, :family, :pending_needs, :observations, visited_project: [:region, :project])
                   .order(visit_date: :desc)
                   .page(params[:page])
                   .per(100)

    # Apply food basket status filter if present
    if params[:food_basket_status].present?
      @visits = @visits.joins(:family).where(families: { food_basket_status: params[:food_basket_status] })
    end

    # Set card view as default if no view parameter is provided
    params[:view] = 'card' if params[:view].blank?

    @visits_data = build_visits_data(@visits)
  end

  # GET /visits/1 or /visits/1.json
  def show
  end

  # GET /visits/new
  def new
    @family = Family.find(params[:family_id])
    @visit = Visit.new
    prepare_form_data
  end

  # GET /visits/1/edit
  def edit
    @family = Family.find(params[:family_id])
    @visit = @family.visits.find(params[:id])
    @projects = Project.all
    @regions = Region.all
    prepare_form_data
  end

  # POST /visits or /visits.json
  def create
    @family = Family.find(params[:family_id])
    @visit = @family.visits.build(visit_params)
    @visit.user = current_user

    respond_to do |format|
      if @visit.save
        format.html { redirect_to @family, notice: "Visita foi criada com sucesso." }
        format.json { render :show, status: :created, location: @visit }
      else
        prepare_form_data
        format.html { render 'families/show', status: :unprocessable_entity }
        format.json { render json: @visit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /visits/1 or /visits/1.json
  def update
    respond_to do |format|
      @family = Family.find(params[:family_id])
      if @visit.update(visit_params)
        format.html { redirect_to @family, notice: "Visita foi atualizada com sucesso." }
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

  def search
    base_query = Visit.select('DISTINCT visits.*')
                     .includes(:user, :family, :pending_needs, :observations, visited_project: [:region, :project])
                     .joins(:family)
                     .joins('LEFT JOIN members ON members.family_id = families.id')

    @visits = case params[:search_type]
             when 'Nome'
               base_query.where('families.reference_name ILIKE :query OR 
                               members.name ILIKE :query', 
                              query: "%#{params[:query]}%")
             when 'Telefone'
               base_query.where('families.phone1 ILIKE :query OR 
                               families.phone2 ILIKE :query', 
                              query: "%#{params[:query]}%")
             when 'Tipo de necessidade'
               base_query.joins(family: :needs)
                        .where('needs.name ILIKE :query AND needs.attended = false', 
                              query: "%#{params[:query]}%")
             when 'CPF'
               # Normalize CPF by removing dots and dashes
               normalized_cpf = normalize_cpf(params[:query])
               
               # Use a database function to normalize stored CPFs for comparison
               # This approach works with PostgreSQL
               base_query.where("REGEXP_REPLACE(members.cpf, '[^0-9]', '', 'g') LIKE ?", "%#{normalized_cpf}%")
             else
               base_query.none
             end

    # Apply food basket status filter if present
    if params[:food_basket_status].present?
      @visits = @visits.where(families: { food_basket_status: params[:food_basket_status] })
    end

    @visits = @visits.order(visit_date: :desc)
                     .page(params[:page])
                     .per(100)

    @visits_data = build_visits_data(@visits)

    respond_to do |format|
      format.turbo_stream { 
        if params[:view] == 'card'
          render turbo_stream: turbo_stream.replace('visits_content', 
                 partial: 'visits/card_view', 
                 locals: { visits: @visits, visits_data: @visits_data })
        else
          render turbo_stream: turbo_stream.replace('visits_content', 
                 partial: 'visits/table_index', 
                 locals: { visits_data: @visits_data })
        end
      }
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
      if @visit.new_record?
        @visit.build_family unless @visit.family
        @visit.family.members.build if @visit.family.members.empty?
        @visit.observations.build if @visit.observations.empty?
        @visit.pending_needs.build if @visit.pending_needs.empty?
        @visit.build_visited_project unless @visit.visited_project
      end
      @projects = Project.all
      @regions = Region.all
    end

    def build_visits_data(visits)
      visits.map do |visit|
        [
          { 
            header: 'Família', 
            content: helpers.link_to(
              if visit.family.members.count == 1
                visit.family.members.first.name
              else
                if visit.family.reference_name.present?
                  "#{visit.family.reference_name} (#{visit.family.members.count} pessoas)"
                else
                  "#{visit.family.members.first.name} (#{visit.family.members.count} pessoas)"
                end
              end,
              family_path(visit.family), 
              class: "text-blue-600 hover:text-blue-800 hover:underline transition duration-300 ease-in-out"
            ), 
            id: "family-#{visit.id}" 
          },
          { 
            header: 'Telefones', 
              content: [
                helpers.phone_links(visit.family.phone1),
                helpers.phone_links(visit.family.phone2)
              ].reject(&:blank?).join(' / ').html_safe, 
              id: "family-phones-#{visit.family.id}" 
            },
          { 
            header: 'Status da Cesta', 
            content: helpers.food_basket_status_badge(visit.family.food_basket_status), 
            id: "family-food-basket-status-#{visit.family.id}" 
          },
          { header: 'Data da visita', content: visit.visit_date.strftime('%d/%m/%Y'), id: "visit-date-#{visit.id}" },
          { header: 'Nome do visitante', content: visit.user.name, id: "visitor-name-#{visit.id}" },
          { header: 'Região', content: visit.visited_project&.region&.name, id: "region-#{visit.id}" },
          { header: 'Projeto', content: visit.visited_project&.project&.name, id: "project-#{visit.id}" },
          { header: 'Necessidades pendentes', content: visit.family.needs.where(attended: false).pluck(:name).join(", "), id: "needs-#{visit.id}", class: "max-w-[450px] whitespace-normal break-words text-left" },
          { 
            header: 'Observações', 
            content: visit.observations.first&.observation || "N/A", 
            id: "observations-#{visit.id}",
            class: "px-6 py-4 text-sm text-gray-500 max-w-[450px] whitespace-normal break-words text-left"
          }
        ]
      end
    end

    # Helper method to normalize CPF by removing non-digit characters
    def normalize_cpf(cpf)
      cpf.to_s.gsub(/[^0-9]/, '')
    end
end
