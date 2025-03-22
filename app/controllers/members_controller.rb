class MembersController < ApplicationController
  before_action :set_family, only: [:new, :create]

  # GET /members or /members.json
  def index
    @family = Family.find(params[:family_id])
    @members = @family.members
    
    @rows = @members.map do |member|
      [
        { 
          header: 'Nome', 
          content: member.name.to_s + (member.firm_in_faith ? 
            "<span class='ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800'>
              <svg class='mr-1 h-3 w-3 text-green-500' fill='currentColor' viewBox='0 0 20 20'>
                <path fill-rule='evenodd' d='M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z' clip-rule='evenodd' />
              </svg>
              Aceitou Jesus
            </span>".html_safe : ""),
          id: "member-name-#{member.id}" 
        },
        { 
          header: 'Idade', 
          content: (member.age || (member.birth_date.present? ? ((Date.today - member.birth_date) / 365.25).floor : "Não informado")) +
            (member.birth_date.present? ? "<span class='text-xs text-gray-400 block'>#{member.birth_date.strftime("%d/%m/%Y")}</span>".html_safe : ""),
          id: "member-age-#{member.id}" 
        },
        { 
          header: 'Papel', 
          content: member.role.present? ? 
            "<span class='inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800'>#{member.role.capitalize}</span>".html_safe : 
            "<span class='text-gray-400'>Não definido</span>".html_safe,
          id: "member-role-#{member.id}" 
        },
        { 
          header: 'Detalhes', 
          content: render_to_string(partial: 'members/details', locals: { member: member }),
          id: "member-details-#{member.id}" 
        },
        { 
          header: 'Ações', 
          content: render_to_string(partial: 'members/actions', locals: { family: @family, member: member }),
          id: "member-actions-#{member.id}" 
        }
      ]
    end
  end

  # GET /members/1 or /members/1.json
  def show
  end

  # GET /members/new
  def new
    @family = Family.find(params[:family_id])
    @member = @family.members.build
    @hide_form = params[:hide_form]
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members or /members.json
  def create
    @family = Family.find(params[:family_id])
    @member = @family.members.build(member_params)

    respond_to do |format|
      if @member.save
        format.turbo_stream { 
          render turbo_stream: [
            turbo_stream.update('members-table', partial: 'members/table', locals: { family: @family }),
            turbo_stream.update('new_member', partial: 'members/form', locals: { family: @family, member: Member.new, hide_form: true })
          ]
        }
        format.html { redirect_to @family, notice: 'Membro adicionado com sucesso.' }
      else
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace('new_member', partial: 'members/form', locals: { family: @family, member: @member, hide_form: false })
        }
        format.html { render :new }
      end
    end
  end
  
  # PATCH/PUT /members/1 or /members/1.json
  def update
    @member = Member.find(params[:id])
    
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to @member, notice: "Membro atualizado com sucesso." }
        format.json { render json: { status: :ok } }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1 or /members/1.json
  def destroy
    @member.destroy!

    respond_to do |format|
      format.html { redirect_to members_path, status: :see_other, notice: "Member was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_family
      @family = Family.find(params[:family_id])
    end

    def set_member
      @member = Member.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def member_params
      params.require(:member).permit(:name, :age, :role, :birth_date, :firm_in_faith, 
                                    :profession, :employed, :income, :has_benefit, :benefit_value)
    end
end
