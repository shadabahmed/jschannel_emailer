class RepositoriesController < ApplicationController
  before_action :set_repository, only: [:show, :edit, :update, :destroy, :crawl]

  # GET /repositories
  # GET /repositories.json
  def index
    @repositories = Repository.all
  end

  # GET /repositories/1
  # GET /repositories/1.json
  def show
  end
 
  def pull
    language = params[:language]
    repos = Repository.pull(language)
    render :text => "Added #{repos.size} repos for #{language}"
  rescue
    render :text => "Could not fetch repos for #{language}"
  end  

  # DELETE /repositories/1
  # DELETE /repositories/1.json
  def destroy
    @repository.destroy
    respond_to do |format|
      format.html { redirect_to repositories_url }
      format.json { head :no_content }
    end
  end

  def crawl
    @repository.crawl
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repository
      @repository = Repository.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def repository_params
      params.require(:repository).permit(:name, :url, :crawled)
    end
end
