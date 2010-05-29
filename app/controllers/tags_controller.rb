class TagsController < ApplicationController
  unloadable
  before_filter :require_admin, :except => [:complete_tags, :suggest, :filter]
  helper :projects

  layout 'admin', :except => :filter

  def index
    @tags = Tag.all
  end

  def show
    @tag = Tag.find params[:id]
  end

  # Action for showing unused tags.
  def unused
  end

  # Action for deleting unused tags.
  def del_unused
    if params[:tags_ids].nil?
      flash[:notice] = l('tags.no_tags_selected')
      redirect_to :action => "index"
    else
      @tags = Tag.find_all_by_id params[:tags_ids]
      @tags = @tags.to_a.map(&:name)
      Tag.destroy params[:tags_ids]
      flash[:notice] = "#{l('tags.deleted_tags')}: #{@tags.join(", ")}"
      redirect_to :action => "index"
    end
  end

  def edit
    @tag = Tag.find params[:id]
  end

  def update
    unless request.post?
      render_404
      return
    end
    @tag = Tag.find params[:tag][:id]
    existing_tag = Tag.find_by_name params[:tag][:name]
    if !existing_tag.nil? and @tag != existing_tag
      Tag.merge_tags existing_tag, @tag
    else
      unless @tag.update_attributes params[:tag]
        render 'edit'
        return
      end
    end
    flash[:notice]=l('tags.updated')
    redirect_to :action => 'show', :id => Tag.find_by_name(params[:tag][:name])
  end

  # Action for checking if tags already exists. Used in Tags > "Tag" > Edit
  def check
    unless request.post?
      render_404
      return
    end
    if t=Tag.find_by_name(params[:tag][:name])
      if t.id != params[:tag][:id].to_i
        render :text => 'true'
        return
      end
    end
    render :text =>'false'
  end

  # Filtering projects according to tags
  def filter
    tag_list=params[:tags].split(/,/)
    @projects = Project.visible.find_all_for_all_tags(tag_list)
    @tags = Tag.
      for_projects(@projects).
      reject { |tag| tag_list.include?(tag.name) }
    @tag_count = Hash.new(0)
    @projects.each do |project|
      project.tags.each do |tag|
        @tag_count[tag.name] += 1
      end
    end
    @tag_sum = 0
    @tags.each { |tag| @tag_sum += @tag_count[tag.name] }
    render :layout => 'base'
  end

  # Tags autocompletition. Used in Projects > New and in Tags > "Tag" > Edit
  def complete_tags
    unless request.post?
      render_404
      return
    end
    @tags = Tag.for_autocomplete params[:tag]
    render :partial => "auto_completed"
  end

  # Suggesting tags based on Project name and description.
  # Used in Projects > New and Projects > "Project" > Settings
  def suggest
    unless request.post?
      render :nothing=>true
      return
    end
    tags = Tag.all.to_a.map(&:name)
    current = params[:current].split(/,/)
    current.map!{|tag_name| tag_name.strip}
    current = Set.new(current)
    found = Set.new
    tags.each do |tag|
      if params[:name] =~ /#{Regexp.escape(tag)}/i \
        || params[:description] =~ /#{Regexp.escape(tag)}/i

        found << tag
      end
    end
    current.merge(found)
    @tags_list = current.to_a.sort.join(", ")
  end

  def delete
    Tag.find(params[:id]).destroy
    flash[:notice]=l "tags.deleted"
    redirect_to :action => "index"
  end

end
