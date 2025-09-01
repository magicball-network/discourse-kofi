import { concat, fn, hash } from "@ember/helper";
import { LinkTo } from "@ember/routing";
import RouteTemplate from "ember-route-template";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import DButton from "discourse/components/d-button";
import LoadMore from "discourse/components/load-more";
import TableHeaderToggle from "discourse/components/table-header-toggle";
import TextField from "discourse/components/text-field";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import formatDate from "discourse/helpers/format-date";
import { i18n } from "discourse-i18n";
import PeriodChooser from "select-kit/components/period-chooser";
import ObscuredEmailAddress from "../../../components/obscured-email-address";

export default RouteTemplate(
  <template>
    <div class="admin-content">
      <p></p>
      <div class="admin-controls admin-site-settings-filter-controls">
        <div class="controls">
          <div class="inline-form">
            <PeriodChooser
              @fullDay={{false}}
              @period={{@controller.period}}
              @onChange={{@controller.updatePeriod}}
            />
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
            @placeholderKey="discourse_kofi.payments.search_placeholder"
            @onChange={{@controller.updateSearch}}
          />
        </div>
      </div>

      <LoadMore
        @selector=".discourse-kofi-payments-table tbody tr"
        @action={{@controller.loadMore}}
      >
        <div class="container">
          <table class="d-admin-table discourse-kofi-payments-table">
            <thead class="heading-container">
              <tr>
                <th class="col heading">
                  <TableHeaderToggle
                    @onToggle={{@controller.updateOrder}}
                    @field="timestamp"
                    @labelKey="discourse_kofi.payments.timestamp.title"
                    @order={{@controller.order}}
                    @asc={{@controller.asc}}
                    @automatic="true"
                  />
                </th>
                <th class="col heading">
                  <TableHeaderToggle
                    @onToggle={{@controller.updateOrder}}
                    @field="type"
                    @labelKey="discourse_kofi.payments.type.title"
                    @order={{@controller.order}}
                    @asc={{@controller.asc}}
                    @automatic="true"
                  />
                </th>
                <th class="col heading">
                  <TableHeaderToggle
                    @onToggle={{@controller.updateOrder}}
                    @field="tier_name"
                    @labelKey="discourse_kofi.payments.tier_name.title"
                    @order={{@controller.order}}
                    @asc={{@controller.asc}}
                    @automatic="true"
                  />
                </th>
                <th class="col heading">
                  <TableHeaderToggle
                    @onToggle={{@controller.updateOrder}}
                    @field="amount"
                    @labelKey="discourse_kofi.payments.amount.title"
                    @order={{@controller.order}}
                    @asc={{@controller.asc}}
                    @automatic="true"
                  />
                </th>
                <th class="col heading">
                  {{i18n "discourse_kofi.payments.from.title"}}
                </th>
                <th class="col heading">
                  {{i18n "discourse_kofi.payments.transaction_id.title"}}
                </th>
                <th class="col heading"></th>
                <th class="col heading"></th>
              </tr>
            </thead>

            <tbody>
              {{#each @controller.payments as |payment|}}
                <tr class="d-admin-row__content">
                  <td rowspan="2" class="d-admin-row__detail">
                    {{formatDate payment.timestamp leaveAgo="true"}}
                  </td>
                  <td rowspan="2" class="d-admin-row__detail">
                    {{payment.payment_type}}
                  </td>
                  <td rowspan="2" class="d-admin-row__detail">
                    {{payment.tier_name}}
                  </td>
                  <td rowspan="2" class="d-admin-row__detail">
                    {{payment.amount_currency}}
                  </td>
                  <td class="d-admin-row__detail kofi_payment_from">
                    {{#if payment.account_id}}
                      <LinkTo
                        @route="adminPlugins.show.discourse-kofi-accounts"
                        @query={{hash q=(concat "id:" payment.account_id)}}
                        title={{i18n
                          "discourse_kofi.payments.actions.show_account.title"
                        }}
                      >
                        {{icon "kofi"}}
                      </LinkTo>
                    {{/if}}
                    {{#if payment.user}}
                      <a
                        class="avatar"
                        href={{payment.user.path}}
                        data-user-card={{payment.user.username}}
                      >
                        {{avatar payment.user imageSize="small"}}
                      </a>
                    {{/if}}
                    <span
                      class="kofi_payment_from_name"
                      title={{i18n "discourse_kofi.payments.from_name.title"}}
                    >
                      {{payment.from_name}}
                    </span>
                    <div class="kofi_payment_email">
                      <ObscuredEmailAddress
                        @email={{payment.email}}
                        @show={{@controller.emailsVisible}}
                      />
                    </div>
                  </td>
                  <td class="d-admin-row__detail kofi_payment_transaction_id">
                    {{payment.kofi_transaction_id}}
                  </td>
                  <td rowspan="2" class="d-admin-row__detail">
                    {{#if payment.anonymized}}
                      {{icon
                        "user-secret"
                        class="text-danger"
                        title="discourse_kofi.payments.anonymized.description"
                      }}
                    {{else if payment.is_public}}
                      {{icon
                        "eye"
                        class="text-successful"
                        title="discourse_kofi.payments.public.description"
                      }}
                    {{else}}
                      {{icon
                        "eye-slash"
                        class="text-muted"
                        title="discourse_kofi.payments.private.description"
                      }}
                    {{/if}}
                  </td>
                  <td rowspan="2" class="d-admin-row__controls">
                    {{#if payment.is_public}}
                      <DButton
                        @icon="eye-slash"
                        @action={{fn @controller.hidePayment payment}}
                        @title="discourse_kofi.payments.actions.make_private.title"
                        class="btn-small"
                      />
                    {{/if}}
                  </td>
                </tr>
                <tr class="d-admin-row__content kofi_payment_message">
                  <td colspan="2" class="d-admin-row__detail">
                    {{payment.message}}
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
