# frozen_string_literal: true

class AttachmentsController < ApplicationController
  before_action :set_attachment, only: %i[ destroy ]

  # GET /attachments/new
  def new
    @attachment = Attachment.new
  end

  # POST /attachments or /attachments.json
  def create
    @attachment = Attachment.new(attachment_params)

    respond_to do |format|
      if @attachment.save
        OrderAttachmentPrintJob.perform_later(@attachment) if @attachment.attachable_type == "Order"
        format.html { redirect_to @attachment.attachable, notice: "Attachment was successfully added." }
        format.json { render :show, status: :created, location: @attachment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attachments/1 or /attachments/1.json
  def destroy
    @attachment.file.purge
    @attachment.destroy!

    respond_to do |format|
      format.html { redirect_to @attachment.attachable, notice: "Attachment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attachment
      @attachment = Attachment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def attachment_params
      params.require(:attachment).permit(:attachable_id, :attachable_type, :organization_id, :attach_file)
    end
end
