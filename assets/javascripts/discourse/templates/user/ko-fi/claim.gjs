import { htmlSafe } from "@ember/template";
import RouteTemplate from "ember-route-template";
import DButton from "discourse/components/d-button";
import TextField from "discourse/components/text-field";
import { i18n } from "discourse-i18n";

export default RouteTemplate(
  <template>
    <p>
      {{htmlSafe (i18n "discourse_kofi.user.claim.information")}}
    </p>

    <div class="inline-form full-width">
      <TextField
        @value={{@controller.txid}}
        @placeholderKey="discourse_kofi.user.claim.input_placeholder"
      />
      <DButton
        @icon="kofi-color"
        @action={{@controller.claim}}
        @label="discourse_kofi.user.claim.action"
        class="btn-default"
      />
    </div>
  </template>
);
