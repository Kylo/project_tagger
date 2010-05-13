module TagsHelper
  def font_size_for_filtered_tag(tag)
    100+(200/@tag_sum)*@tag_count[tag.name]
  end
end