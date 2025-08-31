import { concat, fn, hash } from "@ember/helper";
import { LinkTo } from "@ember/routing";
import RouteTemplate from "ember-route-template";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import DButton from "discourse/components/d-button";
import DropdownMenu from "discourse/components/dropdown-menu";
import LoadMore from "discourse/components/load-more";
import TableHeaderToggle from "discourse/components/table-header-toggle";
import TextField from "discourse/components/text-field";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import formatDate from "discourse/helpers/format-date";
import { i18n } from "discourse-i18n";
import DMenu from "float-kit/components/d-menu";
import ObscuredEmailAddress from "../../../components/obscured-email-address";

export default RouteTemplate(
  <template>
    <div class="admin-content">
      <p></p>
      <div class="admin-controls admin-site-settings-filter-controls">
        <div class="controls">
          <div class="inline-form">
            <DButton
              @icon="envelope"
              @action={{@controller.toggleEmailVisible}}
              @label={{if
                @controller.emailsVisible
                "discourse_kofi.actions.hide_emails.title"
                "discourse_kofi.actions.show_emails.title"
              }}
              class="btn-default"
            />
          </div>
        </div>
        <div class="search controls">
          <TextField
            @value={{@controller.search}}
            @placeholderKey="discourse_kofi.accounts.search_placeholder"
            @onChange={{@controller.updateSearch}}
          />
        </div>
      </div>

      <LoadMore
        @selector=".discourse-kofi-accounts-table tbody tr"
        @action={{@controller.loadMore}}
      >
        <div class="container">
          <table class="d-admin-table discourse-kofi-accounts-table">
            <thead class="heading-container">
              <tr>
                <th class="col heading">{{i18n
                    "discourse_kofi.accounts.id.title"
                  }}</th>
                <th class="col heading">
                  <TableHeaderToggle
                    @onToggle={{@controller.updateOrder}}
                    @field="user"
                    @labelKey="discourse_kofi.accounts.user.title"
                    @order={{@controller.order}}
                    @asc={{@controller.asc}}
                    @automatic="true"
                  />
                </th>
                <th class="col heading">
                  <TableHeaderToggle
                    @onToggle={{@controller.updateOrder}}
                    @field="email"
                    @labelKey="discourse_kofi.accounts.email.title"
                    @order={{@controller.order}}
                    @asc={{@controller.asc}}
                    @automatic="true"
                  />
                </th>
                <th
                  class="col heading"
                  title={{i18n
                    "discourse_kofi.accounts.always_hide.description"
                  }}
                >
                  {{i18n "discourse_kofi.accounts.always_hide.title"}}
                </th>
                <th class="col heading">
                  <TableHeaderToggle
                    @onToggle={{@controller.updateOrder}}
                    @field="created_at"
                    @labelKey="discourse_kofi.accounts.created_at.title"
                    @order={{@controller.order}}
                    @asc={{@controller.asc}}
                    @automatic="true"
                  />
                </th>
                <th class="col heading">
                  {{i18n "discourse_kofi.accounts.latest_payment.title"}}
                </th>
                <th class="col heading"></th>
              </tr>
            </thead>

            <tbody>
              {{#each @controller.accounts as |account|}}
                <tr>
                  <td class="d-admin-row__detail">{{account.id}}</td>
                  <td class="row__detail">
                    {{#if account.anonymized}}
                      {{icon
                        "user-secret"
                        title="discourse_kofi.accounts.anonymized.description"
                      }}
                      {{i18n "anonymous"}}
                    {{else}}
                      <a
                        class="avatar"
                        href={{account.user.path}}
                        data-user-card={{account.user.username}}
                      >
                        {{avatar account.user imageSize="small"}}
                        {{account.user.username}}
                      </a>
                    {{/if}}
                  </td>
                  <td class="row__detail">
                    {{#unless account.anonymized}}
                      <ObscuredEmailAddress
                        @email={{account.email}}
                        @show={{@controller.emailsVisible}}
                      />
                    {{/unless}}
                  </td>
                  <td class="d-admin-row__detail">
                    {{#if account.always_hide}}
                      {{icon
                        "eye-slash"
                        title="discourse_kofi.accounts.always_hide.description"
                      }}
                    {{/if}}
                  </td>
                  <td class="d-admin-row__detail">
                    {{formatDate account.created_at leaveAgo="true"}}
                  </td>
                  <td class="d-admin-row__detail">
                    <LinkTo
                      @route="adminPlugins.show.discourse-kofi-payments"
                      @query={{hash q=(concat "aid:" account.id)}}
                    >
                      {{formatDate
                        account.latest_payment.timestamp
                        leaveAgo="true"
                      }}
                    </LinkTo>
                  </td>
                  <td class="d-admin-row__controls">
                    <DMenu
                      @identifier="discourse-kofi-account-item-menu"
                      @title={{i18n "more_options"}}
                      @icon="ellipsis-vertical"
                      class="btn-default btn-small"
                    >
                      <:content>
                        <DropdownMenu as |dropdown|>
                          <dropdown.item>
                            <DButton
                              @icon={{if account.always_hide "eye" "eye-slash"}}
                              @action={{fn
                                @controller.toggleAlwaysHide
                                account
                              }}
                              @label={{if
                                account.always_hide
                                "discourse_kofi.accounts.actions.not_always_hide.title"
                                "discourse_kofi.accounts.actions.always_hide.title"
                              }}
                              class="btn-default"
                            />
                          </dropdown.item>
                          <dropdown.item>
                            <DButton
                              @icon="eye-slash"
                              @action={{fn
                                @controller.makePaymentsNotPublic
                                account
                              }}
                              @label="discourse_kofi.accounts.actions.hide_payment_details.title"
                              class="btn-default"
                            />
                          </dropdown.item>
                          <dropdown.item><hr /></dropdown.item>
                          <dropdown.item>
                            <DButton
                              @icon="user-secret"
                              @action={{fn @controller.makeAnonymous account}}
                              @disabled={{account.anonymized}}
                              @label="discourse_kofi.accounts.actions.anonymize.title"
                              class="btn-danger"
                            />
                          </dropdown.item>
                          <dropdown.item>
                            <DButton
                              @icon="trash-can"
                              @action={{fn @controller.delete account}}
                              @label="discourse_kofi.accounts.actions.delete.title"
                              class="btn-danger"
                            />
                          </dropdown.item>
                        </DropdownMenu>
                      </:content>
                    </DMenu>
                  </td>
                </tr>
              {{/each}}
            </tbody>
          </table>
        </div>
      </LoadMore>

      <ConditionalLoadingSpinner @condition={{@controller.loading}} />
    </div>
  </template>
);
