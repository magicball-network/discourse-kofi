import { concat, fn, hash } from "@ember/helper";
import { LinkTo } from "@ember/routing";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import DButton from "discourse/components/d-button";
import LoadMore from "discourse/components/load-more";
import TableHeaderToggle from "discourse/components/table-header-toggle";
import TextField from "discourse/components/text-field";
import icon from "discourse/helpers/d-icon";
import formatDate from "discourse/helpers/format-date";
import { i18n } from "discourse-i18n";

export default <template>
  <div class="discourse-kofi-user-controls">
    <div class="controls user-additional-controls">
      <div class="inline-form">
        <TextField
          @value={{@controller.search}}
          @placeholderKey="discourse_kofi.payments.search_placeholder"
          @onChange={{@controller.updateSearch}}
        />
        <DButton
          @icon="eraser"
          @action={{@controller.clearSearch}}
          title={{i18n "discourse_kofi.actions.clear_input"}}
          class="btn-default"
        />
      </div>
    </div>
  </div>

  <LoadMore
    @selector=".discourse-kofi-payments-table tbody tr"
    @action={{@controller.loadMore}}
  >
    <div class="container">
      <table class="d-table discourse-kofi-user discourse-kofi-payments-table">
        <thead class="d-table__header">
          <tr class="d-table__row">
            <th class="d-table__header-cell">
              <TableHeaderToggle
                @onToggle={{@controller.updateOrder}}
                @field="timestamp"
                @labelKey="discourse_kofi.payments.timestamp.title"
                @order={{@controller.order}}
                @asc={{@controller.asc}}
                @automatic="true"
              />
            </th>
            <th class="d-table__header-cell">
              <TableHeaderToggle
                @onToggle={{@controller.updateOrder}}
                @field="type"
                @labelKey="discourse_kofi.payments.type.title"
                @order={{@controller.order}}
                @asc={{@controller.asc}}
                @automatic="true"
              />
            </th>
            <th class="d-table__header-cell">
              <TableHeaderToggle
                @onToggle={{@controller.updateOrder}}
                @field="tier_name"
                @labelKey="discourse_kofi.payments.tier_name.title"
                @order={{@controller.order}}
                @asc={{@controller.asc}}
                @automatic="true"
              />
            </th>
            <th class="d-table__header-cell">
              <TableHeaderToggle
                @onToggle={{@controller.updateOrder}}
                @field="amount"
                @labelKey="discourse_kofi.payments.amount.title"
                @order={{@controller.order}}
                @asc={{@controller.asc}}
                @automatic="true"
              />
            </th>
            <th class="d-table__header-cell">
              {{i18n "discourse_kofi.payments.from.title"}}
            </th>
            <th class="d-table__header-cell">
              {{i18n "discourse_kofi.payments.transaction_id.title"}}
            </th>
            <th class="d-table__header-cell"></th>
            <th class="d-table__header-cell"></th>
          </tr>
        </thead>

        <tbody class="d-table__body">
          {{#each @controller.payments as |payment|}}
            <tr class="d-table__row kofi_payment_overview">
              <td rowspan="2" class="d-table__cell --overview">
                {{formatDate payment.timestamp leaveAgo="true"}}
              </td>
              <td rowspan="2" class="d-table__cell --detail">
                <div class="d-table__mobile-label">{{i18n
                    "discourse_kofi.payments.type.title"
                  }}</div>
                {{payment.payment_type}}
              </td>
              <td rowspan="2" class="d-table__cell --detail">
                <div class="d-table__mobile-label">{{i18n
                    "discourse_kofi.payments.tier_name.title"
                  }}</div>{{payment.tier_name}}
              </td>
              <td rowspan="2" class="d-table__cell --detail">
                <div class="d-table__mobile-label">{{i18n
                    "discourse_kofi.payments.amount.title"
                  }}</div>
                {{payment.amount_currency}}
              </td>
              <td class="d-table__cell --detail">
                <div class="d-table__mobile-label">{{i18n
                    "discourse_kofi.payments.from.title"
                  }}</div>
                <div class="d-table__value-wrapper">
                  {{#if payment.account_id}}
                    <LinkTo
                      @route="user.ko-fi.accounts"
                      @query={{hash q=(concat "id:" payment.account_id)}}
                      title={{i18n
                        "discourse_kofi.payments.actions.show_account.title"
                      }}
                      class="btn-flat btn-large"
                    >
                      {{icon "address-book"}}
                    </LinkTo>
                  {{/if}}
                  <span
                    class="kofi_payment_from_name"
                    title={{i18n "discourse_kofi.payments.from_name.title"}}
                  >
                    {{payment.from_name}}
                  </span>
                </div>
              </td>
              <td class="d-table__cell --overview">
                <div class="d-table__mobile-label">{{i18n
                    "discourse_kofi.payments.transaction_id.title"
                  }}</div>
                <div class="d-table__value-wrapper kofi_payment_transaction_id">
                  {{payment.kofi_transaction_id}}
                </div>
              </td>
              <td rowspan="2" class="d-table__cell --overview">
                {{#if payment.is_public}}
                  {{icon
                    "eye"
                    class="text-successful"
                    title="discourse_kofi.payments.public.description"
                  }}
                  <div class="d-table__mobile-label">{{i18n
                      "discourse_kofi.payments.public.description"
                    }}</div>
                {{else}}
                  {{icon
                    "eye-slash"
                    class="text-muted"
                    title="discourse_kofi.payments.private.description"
                  }}
                  <div class="d-table__mobile-label">{{i18n
                      "discourse_kofi.payments.private.description"
                    }}</div>
                {{/if}}
              </td>
              <td rowspan="2" class="d-table__cell --controls">
                <div class="d-table__cell-actions">
                  {{#if payment.is_public}}
                    <DButton
                      @icon="eye-slash"
                      @action={{fn @controller.hidePayment payment}}
                      @title="discourse_kofi.payments.actions.make_private.title"
                      class="btn-small"
                    />
                  {{/if}}
                </div>
              </td>
            </tr>
            <tr class="d-table__row kofi_payment_message">
              <td colspan="2" class="d-table__cell --overview">
                <div class="d-table__mobile-label">{{i18n
                    "discourse_kofi.payments.message.title"
                  }}</div>
                <div class="d-table__value-wrapper">
                  {{payment.message}}
                </div>
              </td>
            </tr>
          {{/each}}
        </tbody>
      </table>
    </div>
  </LoadMore>

  <ConditionalLoadingSpinner @condition={{@controller.loading}} />
</template>
