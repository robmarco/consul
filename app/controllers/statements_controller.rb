class StatementsController < ApplicationController

  skip_authorization_check

  def new
    @audit = Audit.find(params[:audit_id])
    @statement = @audit.statements.new
  end

  def create
    @audit = Audit.find(params[:audit_id])
    filename = params[:statement][:attachment].original_filename
    @statement = @statement = @audit.statements.new(filename: filename)
    if @statement.save
      path = File.absolute_path(params[:statement][:attachment].tempfile)
      Mailer.debt_audit_document(path, filename).deliver_later
      redirect_to [@audit, @statement], notice: "Muchas gracias. Hemos recibido tu documento."
    end
  end

  def show
    @statement = Statement.find(params[:id])
  end

end