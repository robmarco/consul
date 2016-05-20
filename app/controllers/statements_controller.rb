class StatementsController < ApplicationController

  skip_authorization_check

  def new
    @audit = Audit.find(params[:audit_id])
    @statement = @audit.statements.new
  end

  def create
    @audit = Audit.find(params[:audit_id])
    @statement = @statement = @audit.statements.new(filename: params[:statement][:attachment].original_filename)
    if @statement.save
      attachment_tmp_path = File.absolute_path(params[:statement][:attachment].tempfile)
      Mailer.debt_audit_document(attachment_tmp_path).deliver_later
      redirect_to [@audit, @statement], notice: "Muchas gracias. Hemos recibido tu documento."
    end
  end

  def show
    @statement = Statement.find(params[:id])
  end

end