class ArticlesController < ApplicationController

  respond_to :json

  def index
    category = params[:category]
    @articles = category ? Article.where(category: category): Article.all
    authorize! :read, Article if @articles.empty?
    @articles.each do |article|
      authorize! :read, article
    end
    render json: @articles
  end

  # def create
  #   @article = Article.new(article_params)
  #   @article.save!
  #   render json: @article
  # end
  #
  # def update
  #   @article = Article.find(params[:id].to_i)
  #   @article.update_attributes(article_params)
  #   render json: @article
  # end
  #
  # def destroy
  #   @article = Article.find(params[:id].to_i)
  #   @article.destroy!
  #   head :ok
  # end

  def show
    @article = Article.find(params[:id].to_i)
    authorize! :read, @article
    render json: @article
  end

private

  def article_params
    params.permit(:category, :url)
  end

end
