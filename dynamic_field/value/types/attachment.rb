module DynamicField
  module ValueType
    class Attachment < Base
      extend_json( [ files: [:active_attached_units] ] )

      def put_value files;
        field_record.main_value = nil
      end

      def pull_value
        field_record.files.empty? ? nil : true
      end

      def attachment?
        true
      end

      def attach_file(author, file, att_category_name=:all, linked_attachments_parent=false)
        res = field_record.attachments_container.attach_file(file, att_category_name, false, author, linked_attachments_parent)
        file_name = res.content.original_filename
        post_upload_event(author, file_name, att_category_name) if res && need_upload_event?
        res
      end

      def display_value
        field_record.files.map(&:instance).map(&:content_file_name) * ', '
      end

      def approvement_value
        display_value
      end

      def active_attached_units
        field_record.active_attached_units
      end

      protected

      def need_upload_event?
        field_record.device.submission && field_record.device.submission.active?
      end
    end
  end
end