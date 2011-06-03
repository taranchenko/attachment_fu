module Technoweenie # :nodoc:
  module AttachmentFu # :nodoc:
    module Backends
      module FbGraphBackend
        class RequiredLibraryNotFoundError < StandardError;
        end
        class ConfigFileNotFoundError < StandardError;
        end

        def self.included(base) #:nodoc:
          verify_fb_graph_is_present
        end

        def self.verify_fb_graph_is_present
          begin
            begin
              FbGraph
            rescue
              require 'fb_graph'
            end
          rescue LoadError
            raise RequiredLibraryNotFoundError.new('FbGraph could not be loaded')
          end
        end

        attr_accessor :facebook_access_token

        def public_filename
          url
        end

        protected
        def destroy_file
          true # Facebook doesn't implement a destroy photo command
        end

        def rename_file
          true # Facebook doesn't implement a rename photo command
        end

        def save_to_storage
          unless @saved_to_storage

            if temp_path
              file = File.open(temp_path, 'rb')
            else
              file = StringIO.new(temp_data)
            end

            me = FbGraph::User.me(facebook_access_token)
            photo = me.photo!(
                :access_token => facebook_access_token,
                :image => file
            )

            @saved_to_storage = true

            update_attributes(:url => photo.source, :facebook_pid => photo.identifier)
          end
          true
        end
      end
    end
  end
end
