# This file was auto-generated by lib/tasks/web.rake

module Slack
  module Web
    module Api
      module Endpoints
        module Usergroups
          #
          # This method is used to create a User Group.
          #
          # @option options [Object] :name
          #   A name for the User Group. Must be unique among User Groups.
          # @option options [Object] :handle
          #   A mention handle. Must be unique among channels, users and User Groups.
          # @option options [Object] :description
          #   A short description of the User Group.
          # @option options [Object] :channels
          #   A comma separated string of encoded channel IDs for which the User Group uses as a default.
          # @option options [Object] :include_count
          #   Include the number of users in each User Group.
          # @see https://api.slack.com/methods/usergroups.create
          # @see https://github.com/dblock/slack-api-ref/blob/master/methods/usergroups/usergroups.create.json
          def usergroups_create(options = {})
            throw ArgumentError.new('Required arguments :name missing') if options[:name].nil?
            post('usergroups.create', options)
          end

          #
          # This method disables an existing User Group.
          #
          # @option options [Object] :usergroup
          #   The encoded ID of the User Group to disable.
          # @option options [Object] :include_count
          #   Include the number of users in the User Group.
          # @see https://api.slack.com/methods/usergroups.disable
          # @see https://github.com/dblock/slack-api-ref/blob/master/methods/usergroups/usergroups.disable.json
          def usergroups_disable(options = {})
            throw ArgumentError.new('Required arguments :usergroup missing') if options[:usergroup].nil?
            post('usergroups.disable', options)
          end

          #
          # This method enables a User Group which was previously disabled.
          #
          # @option options [Object] :usergroup
          #   The encoded ID of the User Group to enable.
          # @option options [Object] :include_count
          #   Include the number of users in the User Group.
          # @see https://api.slack.com/methods/usergroups.enable
          # @see https://github.com/dblock/slack-api-ref/blob/master/methods/usergroups/usergroups.enable.json
          def usergroups_enable(options = {})
            throw ArgumentError.new('Required arguments :usergroup missing') if options[:usergroup].nil?
            post('usergroups.enable', options)
          end

          #
          # This method returns a list of all User Groups in the team. This can optionally include disabled User Groups.
          #
          # @option options [Object] :include_disabled
          #   Include disabled User Groups.
          # @option options [Object] :include_count
          #   Include the number of users in each User Group.
          # @option options [Object] :include_users
          #   Include the list of users for each User Group.
          # @see https://api.slack.com/methods/usergroups.list
          # @see https://github.com/dblock/slack-api-ref/blob/master/methods/usergroups/usergroups.list.json
          def usergroups_list(options = {})
            post('usergroups.list', options)
          end

          #
          # This method updates the properties of an existing User Group.
          #
          # @option options [Object] :usergroup
          #   The encoded ID of the User Group to update.
          # @option options [Object] :name
          #   A name for the User Group. Must be unique among User Groups.
          # @option options [Object] :handle
          #   A mention handle. Must be unique among channels, users and User Groups.
          # @option options [Object] :description
          #   A short description of the User Group.
          # @option options [Object] :channels
          #   A comma separated string of encoded channel IDs for which the User Group uses as a default.
          # @option options [Object] :include_count
          #   Include the number of users in the User Group.
          # @see https://api.slack.com/methods/usergroups.update
          # @see https://github.com/dblock/slack-api-ref/blob/master/methods/usergroups/usergroups.update.json
          def usergroups_update(options = {})
            throw ArgumentError.new('Required arguments :usergroup missing') if options[:usergroup].nil?
            post('usergroups.update', options)
          end
        end
      end
    end
  end
end
