class MembersController < ApplicationController
  before_action :set_family, only: [:new, :create]

  # GET /members or /members.json
  def index
    @members = Member.all
  end

  # GET /members/1 or /members/1.json
  def show
  end

  # GET /members/new
  def new
    @member = @family.members.build
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
    @member = @family.members.build(member_params)

    respond_to do |format|
      if @member.save
        format.turbo_stream
        format.html { redirect_to @family, notice: "Membro adicionado com sucesso." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace('new_member', partial: 'form', locals: { family: @family, member: @member }) }
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /members/1 or /members/1.json
  def update
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to @member, notice: "Member was successfully updated." }
        format.json { render :show, status: :ok, location: @member }
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
      params.require(:member).permit(:name, :age, :role, :firm_in_faith)
    end
end
