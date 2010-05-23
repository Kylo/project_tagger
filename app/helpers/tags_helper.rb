module TagsHelper
  # Method used to specify font size for tag in the cloud.
  def font_size_for_filtered_tag(tag)
    100+(200/@tag_sum)*@tag_count[tag.name]
  end

  def tag_name_for_complete(tag, stag)
    tag.sub(/(#{Regexp.escape(stag)})/i, '<strong>\1</strong>')
  end
end