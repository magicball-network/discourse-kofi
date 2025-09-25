import { concat, fn, hash } from "@ember/helper";
import { LinkTo } from "@ember/routing";
import RouteTemplate from "ember-route-template";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import DButton from "discourse/components/d-button";
import LoadMore from "discourse/components/load-more";
import TableHeaderToggle from "discourse/components/table-header-toggle";
import TextField from "discourse/components/text-field";
import icon from "discourse/helpers/d-icon";
import formatDate from "discourse/helpers/format-date";
import { i18n } from "discourse-i18n";
import PeriodChooser from "select-kit/components/period-chooser";

export default RouteTemplate(
  <template>
    <div class="">
      <div class="controls">
        <div class="inline-form">
          <PeriodChooser
            @fullDay={{false}}
            @period={{@controller.period}}
            @onChange={{@controller.updatePeriod}}
          />
        </div>
      </div>
      <div class="user-additional-controls">
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
        <table class="table discourse-kofi-payments-table">
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
              <tr class="">
                <td rowspan="2" class="">
                  {{formatDate payment.timestamp leaveAgo="true"}}
                </td>
                <td rowspan="2" class="">
                  {{payment.payment_type}}
                </td>
                <td rowspan="2" class="">
                  {{payment.tier_name}}
                </td>
                <td rowspan="2" class="">
                  {{payment.amount_currency}}
                </td>
                <td class="kofi_payment_from">
                  {{#if payment.account_id}}
                    <LinkTo
                      @route="user.ko-fi.accounts"
                      @query={{hash q=(concat "id:" payment.account_id)}}
                      title={{i18n
                        "discourse_kofi.payments.actions.show_account.title"
                      }}
                      class="btn-flat btn-large"
                    >
                      {{icon "kofi"}}
                    </LinkTo>
                  {{/if}}
                  <span
                    class="kofi_payment_from_name"
                    title={{i18n "discourse_kofi.payments.from_name.title"}}
                  >
                    {{payment.from_name}}
                  </span>
                </td>
                <td class="kofi_payment_transaction_id">
                  {{payment.kofi_transaction_id}}
                </td>
                <td rowspan="2" class="">
                  {{#if payment.is_public}}
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
                <td rowspan="2" class="">
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
              <tr class="kofi_payment_message">
                <td colspan="2" class="">
                  {{payment.message}}
                </td>
              </tr>
            {{/each}}
          </tbody>
        </table>
      </div>
    </LoadMore>

    <ConditionalLoadingSpinner @condition={{@controller.loading}} />
  </template>
);
