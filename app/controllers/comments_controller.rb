# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ edit update destroy cancel_edit ]
  before_action :authorize, only: %i[ edit update destroy ]

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit; end

  # POST /comments or /comments.json
  def create
    @comment = Comment.new(comment_params)
    @comment.user_id = current_user.id

    respond_to do |format|
      if @comment.save
        format.turbo_stream
        format.html { redirect_to @comment.commentable, notice: "Comment was successfully created." }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1 or /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.turbo_stream
        format.html { redirect_to @comment.commentable, notice: "Comment was successfully updated." }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1 or /comments/1.json
  def destroy
    @comment.destroy!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @comment.commentable, notice: "Comment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def cancel_edit
    render partial: "comments/comment", locals: { comment: @comment, user: current_user }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.require(:comment).permit(:commentable_type, :commentable_id, :content, :organization_id)
    end

    def authorize
      redirect_to home_team_path(current_user.current_team), notice: "You are not authorized to edit this comment" if current_user != @comment.user
    end
end
