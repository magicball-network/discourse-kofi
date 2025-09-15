import { Input } from "@ember/component";
import { hash } from "@ember/helper";
import { htmlSafe } from "@ember/template";
import RouteTemplate from "ember-route-template";
import DButton from "discourse/components/d-button";
import { i18n } from "discourse-i18n";

export default RouteTemplate(
  <template>
    <div class="admin-content kofi-import">
      <p>{{htmlSafe (i18n "discourse_kofi.admin.import.information")}}</p>
      <form class="form-horizontal">
        <div class="control-group">
          <h4>{{i18n "discourse_kofi.admin.import.file"}}</h4>
          <input
            type="file"
            id="csvImport"
            accept=".csv"
            onchange={{@controller.updateFileSelected}}
          />
        </div>
        <div class="control-group">
          <label class="checkbox-label">
            <Input @type="checkbox" @checked={{@controller.makePrivate}} />
            {{i18n "discourse_kofi.admin.import.make_private"}}
          </label>
        </div>
        <DButton
          @action={{@controller.importPayments}}
          @disabled={{@controller.importButtonDisabled}}
          @icon="file-import"
          @label="discourse_kofi.admin.import.import"
          type="submit"
          class="btn-primary"
        />
      </form>

      {{#if @controller.saving}}
        <p>
          <div class="spinner small"></div>
          {{i18n "uploading"}}
        </p>
      {{/if}}

      {{#if @controller.results}}
        <hr />
        <h2>{{i18n "discourse_kofi.admin.import.results"}}</h2>
        <p>{{i18n
            "discourse_kofi.admin.import.summary"
            (hash count=@controller.results.payments.length)
          }}</p>

        {{#if @controller.results.invalid_rows}}
          <h3>{{i18n "discourse_kofi.admin.import.errors"}}</h3>
          <table>
            <thead>
              <tr>
                <th>{{i18n "discourse_kofi.admin.import.error.line"}}</th>
                <th>{{i18n "discourse_kofi.admin.import.error.message"}}</th>
              </tr>
            </thead>
            <tbody>
              {{#each @controller.results.invalid_rows as |error|}}
                <tr>
                  <td>{{error.line_number}}</td>
                  <td>{{error.message}}</td>
                </tr>
              {{/each}}
            </tbody>
          </table>
        {{/if}}
      {{/if}}
    </div>
  </template>
);
