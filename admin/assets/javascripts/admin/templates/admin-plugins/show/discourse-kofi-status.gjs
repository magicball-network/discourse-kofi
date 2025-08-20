import { htmlSafe } from "@ember/template";
import RouteTemplate from "ember-route-template";
import DButton from "discourse/components/d-button";
import icon from "discourse/helpers/d-icon";
import formatDate from "discourse/helpers/format-date";
import routeAction from "discourse/helpers/route-action";
import { i18n } from "discourse-i18n";

export default RouteTemplate(
  <template>
    <div class="admin-content kofi-status">
      <h1
        class="kofi-status-health"
        style="font-size: var(--font-up-6); padding: 1em;"
      >
        {{#if @model.healthy}}
          {{icon "far-face-smile" class="text-successful"}}
        {{else}}
          {{icon "far-face-frown" class="text-danger"}}
        {{/if}}
      </h1>

      <DButton
        @icon="arrows-rotate"
        @action={{routeAction "refreshStatus"}}
        @label="refresh"
      />

      <p class="kofi-status-item">
        {{#if @model.config.webhook_token_configured}}
          {{icon "circle-check" class="text-successful"}}
        {{else}}
          {{icon "circle-xmark" class="text-danger"}}
        {{/if}}
        {{i18n "discourse_kofi.admin.status.webhook-token-configured"}}
      </p>

      {{#if @model.success}}
        <p class="kofi-status-item">
          {{icon "circle-check" class="text-successful"}}
          {{i18n "discourse_kofi.admin.status.last-success-message"}}
          {{formatDate @model.success.timestamp leaveAgo="true"}}
        </p>
        <p class="kofi-status-detail">{{@model.success.message}}</p>
      {{else}}
        <p class="kofi-status-item">
          {{icon "circle-exclamation"}}
          {{htmlSafe (i18n "discourse_kofi.admin.status.webhook-test-hint")}}
        </p>
      {{/if}}

      {{#if @model.error}}
        <p class="kofi-status-item">
          {{icon "circle-xmark" class="text-danger"}}
          {{i18n "discourse_kofi.admin.status.last-error-message"}}
          {{formatDate @model.error.timestamp leaveAgo="true"}}
        </p>
        <p class="kofi-status-detail">{{@model.error.message}}</p>
      {{/if}}
    </div>
  </template>
);
