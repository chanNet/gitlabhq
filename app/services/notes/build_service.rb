module Notes
  class BuildService < ::BaseService
    def execute
      in_reply_to_discussion_id = params.delete(:in_reply_to_discussion_id)

      if in_reply_to_discussion_id.present?
        discussion = find_discussion(in_reply_to_discussion_id)

        unless discussion
          note = Note.new
          note.errors.add(:base, 'Discussion to reply to cannot be found')
          return note
        end

        params.merge!(discussion.reply_attributes)
      end

      note = Note.new(params)
      note.project = project
      note.author = current_user

      note
    end

    def find_discussion(discussion_id)
      if project
        project.notes.find_discussion(discussion_id)
      else
        # only PersonalSnippets can have discussions without project association
        discussion = Note.find_discussion(discussion_id)
        noteable = discussion.noteable

        return nil unless noteable.is_a?(PersonalSnippet) && can?(current_user, :comment_personal_snippet, noteable)

        discussion
      end
    end
  end
end
