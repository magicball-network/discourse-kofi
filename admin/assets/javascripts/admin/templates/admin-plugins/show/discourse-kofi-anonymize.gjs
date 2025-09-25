import { concat, hash } from "@ember/helper";
import { LinkTo } from "@ember/routing";
import { htmlSafe } from "@ember/template";
import RouteTemplate from "ember-route-template";
import DButton from "discourse/components/d-button";
import TextField from "discourse/components/text-field";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default RouteTemplate(
  <template>
    <div class="admin-content discourse-kofi-admin">
      <p>{{htmlSafe (i18n "discourse_kofi.admin.anonymize.information")}}</p>
      <form class="form-horizontal">
        <div class="control-group">
          <h4>{{i18n "discourse_kofi.admin.anonymize.email"}}</h4>
          <TextField @value={{@controller.anonymizeEmail}} />
        </div>
        <DButton
          @action={{@controller.anonymizePayments}}
          @icon="user-secret"
          @label="discourse_kofi.admin.anonymize.anonymize"
          type="submit"
          class="btn-danger"
        />
      </form>

      {{#if @controller.accountId}}
        <hr />
        {{i18n "discourse_kofi.admin.anonymize.account_created"}}
        <LinkTo
          @route="adminPlugins.show.discourse-kofi-accounts"
          @query={{hash q=(concat "id:" @controller.accountId)}}
          title={{i18n "discourse_kofi.payments.actions.show_account.title"}}
          class="btn-flat btn-large"
        >
          {{icon "kofi"}}
          #{{@controller.accountId}}
        </LinkTo>
      {{/if}}
    </div>
  </template>
);
